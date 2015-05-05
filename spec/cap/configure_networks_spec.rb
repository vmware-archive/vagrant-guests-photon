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

    interfaces = "eth0\neth1\neth2\neth3\neth4\n"

    before do
      communicate.stub(:sudo).with("ifconfig -a | grep '^eth' | cut -f1 -d' '")
        .and_yield(nil, interfaces)
    end

    it 'should configure networks' do
      communicate.should_receive(:sudo).with("rm -f /etc/systemd/network/50-vagrant-*.network")
      communicate.should_receive(:sudo).with("ifconfig -a | grep '^eth' | cut -f1 -d' '")

      # eth1
      communicate.should_receive(:upload) do |src, dst|
        contents = (File.readlines src).join("")
        contents.should eq "[Match]\nName=eth1\n\n[Network]\nAddress=192.168.10.10/24\n"
        dst.should eq "/tmp/50-vagrant-eth1.network"
      end
      communicate.should_receive(:sudo)
        .with("mv /tmp/50-vagrant-eth1.network /etc/systemd/network/")
      communicate.should_receive(:sudo)
        .with("chown root:root /etc/systemd/network/50-vagrant-eth1.network")
      communicate.should_receive(:sudo)
        .with("chmod +r /etc/systemd/network/50-vagrant-eth1.network")

      # eth2
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

      # eth3
      communicate.should_receive(:upload) do |src, dst|
        contents = (File.readlines src).join("")
        contents.should eq "[Match]\nName=eth3\n\n[Network]\nDHCP=yes\n"
        dst.should eq "/tmp/50-vagrant-eth3.network"
      end
      communicate.should_receive(:sudo)
        .with("mv /tmp/50-vagrant-eth3.network /etc/systemd/network/")
      communicate.should_receive(:sudo)
        .with("chown root:root /etc/systemd/network/50-vagrant-eth3.network")
      communicate.should_receive(:sudo)
        .with("chmod +r /etc/systemd/network/50-vagrant-eth3.network")

      # eth4
      communicate.should_receive(:upload) do |src, dst|
        contents = (File.readlines src).join("")
        contents.should eq "[Match]\nName=eth4\n\n[Network]\nAddress=192.168.1.201/24\n"
        dst.should eq "/tmp/50-vagrant-eth4.network"
      end
      communicate.should_receive(:sudo)
        .with("mv /tmp/50-vagrant-eth4.network /etc/systemd/network/")
      communicate.should_receive(:sudo)
        .with("chown root:root /etc/systemd/network/50-vagrant-eth4.network")
      communicate.should_receive(:sudo)
        .with("chmod +r /etc/systemd/network/50-vagrant-eth4.network")

      communicate.should_receive(:sudo).with("systemctl restart systemd-networkd.service")

      described_class.configure_networks(machine, networks)
    end
  end

  context 'configure 2 kinds of networks without eth2' do
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

    interfaces = "eth0\neth1\n"

    before do
      communicate.stub(:sudo).with("ifconfig -a | grep '^eth' | cut -f1 -d' '")
        .and_yield(nil, interfaces)
      @@logger = Log4r::Logger.new("vagrant::guest::photon::configure_networks") 
    end

    it 'should configure networks without eth2' do
      communicate.should_receive(:sudo).with("rm -f /etc/systemd/network/50-vagrant-*.network")
      communicate.should_receive(:sudo).with("ifconfig -a | grep '^eth' | cut -f1 -d' '")

      # eth1
      communicate.should_receive(:upload) do |src, dst|
        contents = (File.readlines src).join("")
        contents.should eq "[Match]\nName=eth1\n\n[Network]\nAddress=192.168.10.10/24\n"
        dst.should eq "/tmp/50-vagrant-eth1.network"
      end
      communicate.should_receive(:sudo)
        .with("mv /tmp/50-vagrant-eth1.network /etc/systemd/network/")
      communicate.should_receive(:sudo)
        .with("chown root:root /etc/systemd/network/50-vagrant-eth1.network")
      communicate.should_receive(:sudo)
        .with("chmod +r /etc/systemd/network/50-vagrant-eth1.network")

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
