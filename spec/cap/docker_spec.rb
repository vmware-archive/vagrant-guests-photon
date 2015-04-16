# encoding: UTF-8
# Copyright (c) 2015 VMware, Inc. All Rights Reserved.

require 'vagrant-guests-photon/cap/docker'
require 'spec_helper'

describe VagrantPlugins::GuestPhoton::Cap::Docker do
  include_context 'machine'

  it 'should check docker' do
    expect(communicate).to receive(:test).with('test -S /run/docker.sock')
    described_class.docker_daemon_running(machine)
  end
end
