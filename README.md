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

### Creating a release

* Configure the target version in metadata.json
* Run `bundler exec puppet strings generate --format markdown --out REFERENCE.md` to update the reference 
  documentation
* Run `CHANGELOG_GITHUB_TOKEN=<github-token> bundler exec rake changelog` to update the changelog
* Push the changes and create a release in GitHub
* Travis will test the release and push the new version to Puppet Forge
