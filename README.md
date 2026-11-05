# Puppet Xymon module

## Introduction

This module manages several aspects of the [Xymon Monitoring Suite](https://xymon.org).

Current features include:

* Xymon agent installation and configuration for Debian, RedHat and SuSE Linux distributions
* Installation and configuration of custom Xymon monitors and prerequisites

## Usage

See the [REFERENCE](REFERENCE.md) page for details on the available classes.

## Development

If you've found any bugs or require new features, please don't hesitate to open an issue in this repository.

If you can fix the issue yourself, please open a Pull Request as well. Thanks for your support.

### Running the tests

```sh
bundle install
bundle exec rake test rubocop
```

The integration tests apply the module with OpenVox 8 in Docker containers (Debian 12/13, Ubuntu 24.04)
and check the result with serverspec:

```sh
bundle exec kitchen test
```

### Creating a release

* Configure the target version in metadata.json
* Run `bundle exec rake strings:generate:reference` to update the reference documentation
* Add the changes to CHANGELOG.md
* Push the changes and create a release in GitHub
* The deploy workflow pushes the new version to Puppet Forge
