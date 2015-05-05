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
            comm.sudo("rm -f /etc/systemd/network/50-vagrant-*.network")

            # Read network interface names
            interfaces = []
            comm.sudo("ifconfig -a | grep '^eth' | cut -f1 -d' '") do |_, result|
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

              unit_name = "50-vagrant-%s.network" % [iface]

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
              comm.sudo("chmod +r /etc/systemd/network/#{unit_name}")
            end

            comm.sudo("systemctl restart systemd-networkd.service")
          end
        end
      end
    end
  end
end
