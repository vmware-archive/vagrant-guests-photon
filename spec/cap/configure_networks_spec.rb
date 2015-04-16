# encoding: UTF-8
# Copyright (c) 2015 VMware, Inc. All Rights Reserved.

require 'vagrant-guests-photon/cap/configure_networks'
require 'spec_helper'

describe VagrantPlugins::GuestPhoton::Cap::ConfigureNetworks do
  include_context 'machine'

  it 'should configure networks' do
    networks = [
      { :type => :static, :ip => '192.168.10.10', :netmask => '255.255.255.0', :interface => 1, :name => 'eth0' },
      { :type => :dhcp, :interface => 2, :name => 'eth1' },
      { :type => :static, :ip => '10.168.10.10', :netmask => '255.255.0.0', :interface => 3, :name => 'docker0' }
    ]
    communicate.should_receive(:sudo).with("ifconfig | grep 'eth' | cut -f1 -d' '")
    communicate.should_receive(:sudo).with('ifconfig  192.168.10.10 netmask 255.255.255.0')
    communicate.should_receive(:sudo).with('ifconfig   netmask ')
    communicate.should_receive(:sudo).with('ifconfig  10.168.10.10 netmask 255.255.0.0')

    allow_message_expectations_on_nil
    machine.should_receive(:env).at_least(5).times
    machine.env.should_receive(:active_machines).at_least(:twice)
    machine.env.active_machines.should_receive(:first)
    machine.env.should_receive(:machine)

    described_class.configure_networks(machine, networks)
  end
end
