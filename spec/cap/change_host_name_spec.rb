# encoding: UTF-8
# Copyright (c) 2015 VMware, Inc. All Rights Reserved.

require 'vagrant-guests-photon/cap/change_host_name'
require 'spec_helper'

describe VagrantPlugins::GuestPhoton::Cap::ChangeHostName do
  include_context 'machine'

  it 'should change hostname when hostname is differ from current' do
    hostname = 'vagrant-photon'
    expect(communicate).to receive(:test).with("sudo hostname --fqdn | grep 'vagrant-photon'")
    communicate.should_receive(:sudo).with("hostname #{hostname.split('.')[0]}")
    described_class.change_host_name(machine, hostname)
  end

  it 'should not change hostname when hostname equals current' do
    hostname = 'vagrant-photon'
    communicate.stub(:test).and_return(true)
    communicate.should_not_receive(:sudo)
    described_class.change_host_name(machine, hostname)
  end
end
