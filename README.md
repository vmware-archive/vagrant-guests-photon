# vagrant-guests-photon

This is a [Vagrant](http://www.vagrantup.com/) [plugin](http://docs.vagrantup.com/v2/plugins/index.html) that adds VMware Photon guest support.

## Installation

```
$ vagrant plugin install vagrant-guests-photon
```

## Development

To build and install the plugin directly from this repo:

```
$ rake build
$ vagrant plugin install pkg/vagrant-guests-photon-1.0.0.gem
```

You can run RSpec with:

```
$ rake
```