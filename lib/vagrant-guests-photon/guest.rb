# encoding: UTF-8
# Copyright (c) 2015 VMware, Inc. All Rights Reserved.

require 'vagrant'

module VagrantPlugins
  module GuestPhoton
    class Guest < Vagrant.plugin('2', :guest)
      def detect?(machine)
        machine.communicate.test("grep 'VMware Photon' /etc/photon-release")
      end
    end
  end
end
