# vagrant-guests-photon [![Build Status](https://travis-ci.org/vmware/vagrant-guests-photon.svg)](https://travis-ci.org/vmware/vagrant-guests-photon) [![Coverage Status](https://coveralls.io/repos/vmware/vagrant-guests-photon/badge.svg?branch=master&service=github)](https://coveralls.io/github/vmware/vagrant-guests-photon?branch=master)[![Gem Version](https://badge.fury.io/rb/vagrant-guests-photon.svg)](https://badge.fury.io/rb/vagrant-guests-photon)
This is a [Vagrant](http://www.vagrantup.com/) [plugin](http://docs.vagrantup.com/v2/plugins/index.html) that adds VMware Photon guest support.

## Installation

```shell
$ vagrant plugin install vagrant-guests-photon
```

## Development
To build and install the plugin directly from this repo:

```shell
$ bundle install
$ bundle exec rake build
$ vagrant plugin install pkg/vagrant-guests-photon-1.0.2.gem
```

You can run RSpec with:

```shell
$ bundle install
$ bundle exec rake
```
