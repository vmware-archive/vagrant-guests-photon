# encoding: UTF-8
# Copyright (c) 2015 VMware, Inc. All Rights Reserved.

require 'vagrant-guests-photon/cap/configure_networks'
require 'spec_helper'

describe VagrantPlugins::GuestPhoton::Cap::ConfigureNetworks do
  include_context 'machine'

  context 'configure 4 kinds of networks' do
    networks = [
      # config.vm.network :private_network, ip: "192.168.33.10"
      {
        :type => :static,
        :adapter_ip => '192.168.10.1',
        :ip => '192.168.10.10',
        :netmask => '255.255.255.0',
        :auto_config => true,
        :interface => 1
      },
      # config.vm.network :private_network, type: "dhcp"
      {
        :type => :dhcp,
        :adapter_ip => "172.28.128.1",
        :ip => "172.28.128.1",
        :netmask => "255.255.255.0",
        :auto_config => true,
        :interface => 2
      },
      # config.vm.network :public_network, bridge: "en0: Wi-Fi (AirPort)"
      {
        :type => :dhcp,
        :use_dhcp_assigned_default_route => false,
        :auto_config => true,
        :interface => 3
      },
      # config.vm.network :public_network, bridge: "en0: Wi-Fi (AirPort)", ip: "192.168.1.201"
      {
        :type=>:static,
        :bridge => "en0: Wi-Fi (AirPort)",
        :ip => "192.168.1.201",
        :netmask => "255.255.255.0",
        :use_dhcp_assigned_default_route => false,
        :auto_config => true,
        :interface => 4
      }
    ]

    interfaces = "enp0s3\nenp0s8\neth2\nenp1s5\nenp1s6\n"

    before do
      communicate.stub(:sudo).with("ifconfig -a | grep -E '^enp|^eth' | cut -f1 -d' '")
        .and_yield(nil, interfaces)
    end

    it 'should configure networks' do
      communicate.should_receive(:sudo).with("ifconfig -a | grep -E '^enp|^eth' | cut -f1 -d' '")

      # enp0s8
      communicate.should_receive(:sudo).with("grep enp0s8 /etc/systemd/network/* | awk -F: '{print $1}' | head -n1")
      communicate.should_receive(:sudo).with("rm -f /etc/systemd/network/50-vagrant-enp0s8.network")
      communicate.should_receive(:upload) do |src, dst|
        contents = (File.readlines src).join("")
        contents.should eq "[Match]\nName=enp0s8\n\n[Network]\nAddress=192.168.10.10/24\n"
        dst.should eq "/tmp/50-vagrant-enp0s8.network"
      end
      communicate.should_receive(:sudo)
        .with("mv /tmp/50-vagrant-enp0s8.network /etc/systemd/network/")
      communicate.should_receive(:sudo)
        .with("chown root:root /etc/systemd/network/50-vagrant-enp0s8.network")
      communicate.should_receive(:sudo)
        .with("chmod +r /etc/systemd/network/50-vagrant-enp0s8.network")

      # eth2
      communicate.should_receive(:sudo).with("grep eth2 /etc/systemd/network/* | awk -F: '{print $1}' | head -n1")
      communicate.should_receive(:sudo).with("rm -f /etc/systemd/network/50-vagrant-eth2.network")
      communicate.should_receive(:upload) do |src, dst|
        contents = (File.readlines src).join("")
        contents.should eq "[Match]\nName=eth2\n\n[Network]\nDHCP=yes\n"
        dst.should eq "/tmp/50-vagrant-eth2.network"
      end
      communicate.should_receive(:sudo)
        .with("mv /tmp/50-vagrant-eth2.network /etc/systemd/network/")
      communicate.should_receive(:sudo)
        .with("chown root:root /etc/systemd/network/50-vagrant-eth2.network")
      communicate.should_receive(:sudo)
        .with("chmod +r /etc/systemd/network/50-vagrant-eth2.network")

      # enp1s5
      communicate.should_receive(:sudo).with("grep enp1s5 /etc/systemd/network/* | awk -F: '{print $1}' | head -n1")
      communicate.should_receive(:sudo).with("rm -f /etc/systemd/network/50-vagrant-enp1s5.network")
      communicate.should_receive(:upload) do |src, dst|
        contents = (File.readlines src).join("")
        contents.should eq "[Match]\nName=enp1s5\n\n[Network]\nDHCP=yes\n"
        dst.should eq "/tmp/50-vagrant-enp1s5.network"
      end
      communicate.should_receive(:sudo)
        .with("mv /tmp/50-vagrant-enp1s5.network /etc/systemd/network/")
      communicate.should_receive(:sudo)
        .with("chown root:root /etc/systemd/network/50-vagrant-enp1s5.network")
      communicate.should_receive(:sudo)
        .with("chmod +r /etc/systemd/network/50-vagrant-enp1s5.network")

      # enp1s6
      communicate.should_receive(:sudo).with("grep enp1s6 /etc/systemd/network/* | awk -F: '{print $1}' | head -n1")
      communicate.should_receive(:sudo).with("rm -f /etc/systemd/network/50-vagrant-enp1s6.network")
      communicate.should_receive(:upload) do |src, dst|
        contents = (File.readlines src).join("")
        contents.should eq "[Match]\nName=enp1s6\n\n[Network]\nAddress=192.168.1.201/24\n"
        dst.should eq "/tmp/50-vagrant-enp1s6.network"
      end
      communicate.should_receive(:sudo)
        .with("mv /tmp/50-vagrant-enp1s6.network /etc/systemd/network/")
      communicate.should_receive(:sudo)
        .with("chown root:root /etc/systemd/network/50-vagrant-enp1s6.network")
      communicate.should_receive(:sudo)
        .with("chmod +r /etc/systemd/network/50-vagrant-enp1s6.network")

      communicate.should_receive(:sudo).with("systemctl restart systemd-networkd.service")

      described_class.configure_networks(machine, networks)
    end
  end

  context 'configure 2 kinds of networks without enp0s8' do
    networks = [
      # config.vm.network :private_network, ip: "192.168.33.10"
      {
        :type => :static,
        :adapter_ip => '192.168.10.1',
        :ip => '192.168.10.10',
        :netmask => '255.255.255.0',
        :auto_config => true,
        :interface => 1
      },
      # config.vm.network :private_network, type: "dhcp"
      {
        :type => :dhcp,
        :adapter_ip => "172.28.128.1",
        :ip => "172.28.128.1",
        :netmask => "255.255.255.0",
        :auto_config => true,
        :interface => 2
      }
    ]

    interfaces = "enp0s3\nenp0s8\n"

    before do
      communicate.stub(:sudo).with("ifconfig -a | grep -E '^enp|^eth' | cut -f1 -d' '")
        .and_yield(nil, interfaces)
      @@logger = Log4r::Logger.new("vagrant::guest::photon::configure_networks") 
    end

    it 'should configure networks without enp0s9' do
      communicate.should_receive(:sudo).with("ifconfig -a | grep -E '^enp|^eth' | cut -f1 -d' '")
      communicate.should_receive(:sudo).with("grep enp0s8 /etc/systemd/network/* | awk -F: '{print $1}' | head -n1")
      communicate.should_receive(:sudo).with("rm -f /etc/systemd/network/50-vagrant-enp0s8.network")

      # enp0s8
      communicate.should_receive(:upload) do |src, dst|
        contents = (File.readlines src).join("")
        contents.should eq "[Match]\nName=enp0s8\n\n[Network]\nAddress=192.168.10.10/24\n"
        dst.should eq "/tmp/50-vagrant-enp0s8.network"
      end
      communicate.should_receive(:sudo)
        .with("mv /tmp/50-vagrant-enp0s8.network /etc/systemd/network/")
      communicate.should_receive(:sudo)
        .with("chown root:root /etc/systemd/network/50-vagrant-enp0s8.network")
      communicate.should_receive(:sudo)
        .with("chmod +r /etc/systemd/network/50-vagrant-enp0s8.network")

      # eth2
      @@logger.should_receive(:warn).with(
        "Could not find match rule for network " +
        "{:type=>:dhcp, :adapter_ip=>\"172.28.128.1\", :ip=>\"172.28.128.1\", " +
        ":netmask=>\"255.255.255.0\", :auto_config=>true, :interface=>2}"
      )

      communicate.should_receive(:sudo).with("systemctl restart systemd-networkd.service")

      described_class.configure_networks(machine, networks)
    end
  end
end
