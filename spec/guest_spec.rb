# encoding: UTF-8
# Copyright (c) 2015 VMware, Inc. All Rights Reserved.

require 'spec_helper'
require 'vagrant-guests-photon/guest'

describe VagrantPlugins::GuestPhoton::Guest do
  include_context 'machine'

  it 'should be detected with Photon' do
    expect(communicate).to receive(:test).with("grep 'VMware Photon' /etc/photon-release")
    guest.detect?(machine)
  end
end
