# encoding: UTF-8
# Copyright (c) 2015 VMware, Inc. All Rights Reserved.

require 'spec_helper'
require 'vagrant-guests-photon/plugin'
require 'vagrant-guests-photon/cap/change_host_name'
require 'vagrant-guests-photon/cap/configure_networks'
require 'vagrant-guests-photon/cap/docker'

describe VagrantPlugins::GuestPhoton::Plugin do
  it 'should be loaded with photon' do
    expect(described_class.components.guests[:photon].first).to eq(VagrantPlugins::GuestPhoton::Guest)
  end

  {
    :docker_daemon_running => VagrantPlugins::GuestPhoton::Cap::Docker,
    :change_host_name      => VagrantPlugins::GuestPhoton::Cap::ChangeHostName,
    :configure_networks    => VagrantPlugins::GuestPhoton::Cap::ConfigureNetworks
  }.each do |cap, cls|
    it "should be capable of #{cap} with photon" do
      expect(described_class.components.guest_capabilities[:photon][cap])
        .to eq(cls)
    end
  end
end
