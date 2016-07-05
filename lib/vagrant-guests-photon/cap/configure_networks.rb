# encoding: UTF-8
# Copyright (c) 2015 VMware, Inc. All Rights Reserved.

require 'tempfile'
require 'ipaddr'
require 'log4r'

# Borrowed from http://stackoverflow.com/questions/1825928/netmask-to-cidr-in-ruby
IPAddr.class_eval do
  def to_cidr
    self.to_i.to_s(2).count("1")
  end
end

STATIC_NETWORK = <<EOF
[Match]
Name=%s

[Network]
Address=%s
EOF

DHCP_NETWORK = <<EOF
[Match]
Name=%s

[Network]
DHCP=yes
EOF

module VagrantPlugins
  module GuestPhoton
    module Cap
      class ConfigureNetworks
        @@logger = Log4r::Logger.new("vagrant::guest::photon::configure_networks")

        def self.configure_networks(machine, networks)
          machine.communicate.tap do |comm|

            # Read network interface names
            interfaces = []
            comm.sudo("ifconfig -a | grep -E '^enp|^eth' | cut -f1 -d' '") do |_, result|
              interfaces = result.split("\n")
            end

            # Configure interfaces
            networks.each do |network|
              interface = network[:interface].to_i

              iface = interfaces[interface]
              if iface.nil?
                @@logger.warn("Could not find match rule for network #{network.inspect}")
                next
              end

              unit_name = find_network_file comm, iface
              comm.sudo("rm -f /etc/systemd/network/#{unit_name}")

	      if network[:type] == :static
                cidr = IPAddr.new(network[:netmask]).to_cidr
                address = "%s/%s" % [network[:ip], cidr]
                unit_file = STATIC_NETWORK % [iface, address]
              elsif network[:type] == :dhcp
                unit_file = DHCP_NETWORK % [iface]
              end

              temp = Tempfile.new("vagrant")
              temp.binmode
              temp.write(unit_file)
              temp.close

              comm.upload(temp.path, "/tmp/#{unit_name}")
              comm.sudo("mv /tmp/#{unit_name} /etc/systemd/network/")
              comm.sudo("chown root:root /etc/systemd/network/#{unit_name}")
              comm.sudo("chmod a+r /etc/systemd/network/#{unit_name}")
            end

            comm.sudo("systemctl restart systemd-networkd.service")
          end
        end

        def self.find_network_file(comm, iface)
         comm.sudo("grep #{iface} /etc/systemd/network/* | awk -F\: '{print $1}' | head -n1") do |_, result|
           puts result
           return File.basename(result.strip)
         end
	 return "50-vagrant-%s.network" % [iface]
        end
      end
    end
  end
end
