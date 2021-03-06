# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`xymon::client`](#xymonclient): Installs Xymon client, configures it and optionally sets up monitors
* [`xymon::repository::apt`](#xymonrepositoryapt): Install the APT repository, key (optionally) and the pacakge
* [`xymon::repository::yum`](#xymonrepositoryyum): Install the YUM repository, key (optionally) and the pacakge
* [`xymon::repository::zypper`](#xymonrepositoryzypper): Install the Zypper repository, key (optionally) and the pacakge

### Defined types

* [`xymon::client::monitor`](#xymonclientmonitor): Sets up a xymon monitor

## Classes

### <a name="xymonclient"></a>`xymon::client`

Installs Xymon client, configures it and optionally sets up monitors

* **See also**
  * xymon::client::test

#### Examples

##### 

```puppet
class {
  'xymon::client':
    repository_url = 'https://my.repository.company.com/repo',
    xymon_server = 'xymon.company.com',
    gpg_url = 'https://my.repository.company.com/gpg',
    gpg_id = '6688A3782BBFE5A4',
    monitors = {
        'mycheck' => {
          script_source => 'puppet:///my/script.sh'
          arguments => [
            '--yellow=80',
            '--red=90',
            '--check-values=/etc/xymon/files/rootcheck.cfg
          ],
          sudo: {
            'rootcheck' => {
              content => 'xymon ALL=(ALL) NOPASSWD: /usr/bin/rootcheck',
            }
          },
          packages => {
            'rootcheck' => { ensure => 'latest' },
          },
          files => {
            'rootcheck.cfg' => {
               source => 'puppet:///my/rootcheck.cfg',
               mode => '0600',
             },
            'mysql_connection.mycfg => {
               template => 'my/mysql_connection/mysql_connection.cfg.epp,
               mode => '0600',
               vars => {
                 host => 'foo.bar.com',
                 user => 'fancydbuser',
                 password => 'fancypassword', # eyaml recommended here!
               }
            }
          },
          logrotate => {
            path   => '/var/log/xymon/script.log',
            size   => '20M',
            rotate => 5,
          }
        }
    }
```

#### Parameters

The following parameters are available in the `xymon::client` class:

* [`xymon_server`](#xymon_server)
* [`manage_repository`](#manage_repository)
* [`config_file`](#config_file)
* [`package`](#package)
* [`service_name`](#service_name)
* [`xymon_config_dir`](#xymon_config_dir)
* [`xymon_user`](#xymon_user)
* [`xymon_group`](#xymon_group)
* [`repository_url`](#repository_url)
* [`gpg_url`](#gpg_url)
* [`gpg_id`](#gpg_id)
* [`monitors`](#monitors)
* [`client_name`](#client_name)
* [`clientlaunch_config`](#clientlaunch_config)
* [`files_path`](#files_path)

##### <a name="xymon_server"></a>`xymon_server`

Data type: `String`

The xymon server to use

##### <a name="manage_repository"></a>`manage_repository`

Data type: `Boolean`

Manage the repository for package installation

Default value: ``true``

##### <a name="config_file"></a>`config_file`

Data type: `String`

Path to the xymon-client configuration file

Default value: `'/etc/default/xymon-client'`

##### <a name="package"></a>`package`

Data type: `String`

Package name

Default value: `'xymon-client'`

##### <a name="service_name"></a>`service_name`

Data type: `String`

Service name

Default value: `'xymon-client'`

##### <a name="xymon_config_dir"></a>`xymon_config_dir`

Data type: `String`

Directory where the xymon configs are stored

Default value: `'/etc/xymon'`

##### <a name="xymon_user"></a>`xymon_user`

Data type: `String`

The system user that is used by xymon

Default value: `'xymon'`

##### <a name="xymon_group"></a>`xymon_group`

Data type: `String`

The system group that is used by xymon

Default value: `'xymon'`

##### <a name="repository_url"></a>`repository_url`

Data type: `Optional[String]`

URL of the repository that contains the xymon-client

Default value: ``undef``

##### <a name="gpg_url"></a>`gpg_url`

Data type: `Optional[String]`

URL of the GPG key

Default value: ``undef``

##### <a name="gpg_id"></a>`gpg_id`

Data type: `Optional[String]`

Key id of the gpg key (Required by apt)

Default value: ``undef``

##### <a name="monitors"></a>`monitors`

Data type: `Optional[Hash]`

A hash of tests to configure
@option monitors :script_source A Puppet file source to the script for the monitor
@option monitors :clientlaunch_config Path to the Xymon clientlaunch path.
@option monitors :files_path Path to the a path for additional files.
@option monitors :xymon_user Xymon user.
@option monitors :xymon_group Xymon group.
@option monitors :xymon_service Xymon service name.
@option monitors :interval A valid Xymon client interval string when to run the script
@option monitors :arguments A list of command line arguments to start the script with
@option monitors :require_fqdn Require that the agent has the specified FQDN for the monitor to be installed
@option monitors :files A hash of filenames as key and sources as values to add to the xymon files
 @option files :source A Puppet file source for the additional file for the monitor
 @option files :template A Puppet template for the additional file for the monitor
 @option files :vars A hash of variables used in the template
 @option files :mode file mode of the additional file for the monitor
 @option files :owner owner of the additional file for the monitor
 @option files :group group of the additional file for the monitor
@option monitors :sudo A sudo::conf hash with sudo definitions the xymon user should be allowed to use
@option monitors :packages A puppet package hash with packages that are required for the monitor to work
@option monitors :logrotate A hash containing definitions to configure logfile rotation
 @option logrotate :path path for the file to logrotate
 @option logrotate :size file size threshold when to rotate (human readable format accepted)
 @option logrotate :rotate how many times the log is rotated until it is deleted

Default value: ``undef``

##### <a name="client_name"></a>`client_name`

Data type: `Optional[String]`

Name of the client (defaults to the FQDN)

Default value: ``undef``

##### <a name="clientlaunch_config"></a>`clientlaunch_config`

Data type: `Optional[String]`

Path ot the clientlaunch configuration directory
(defaults to $xymon_config_dir/clientlaunch.d)

Default value: ``undef``

##### <a name="files_path"></a>`files_path`

Data type: `Optional[String]`

A path where to store additional files required by the monitors (defaults to
($xymon_config_dir/files)

Default value: ``undef``

### <a name="xymonrepositoryapt"></a>`xymon::repository::apt`

Install the APT repository, key (optionally) and the pacakge

#### Parameters

The following parameters are available in the `xymon::repository::apt` class:

* [`repository_url`](#repository_url)
* [`package`](#package)
* [`gpg_url`](#gpg_url)
* [`gpg_id`](#gpg_id)

##### <a name="repository_url"></a>`repository_url`

Data type: `String`

URL of the repository that contains the xymon-client

##### <a name="package"></a>`package`

Data type: `String`

Package name

##### <a name="gpg_url"></a>`gpg_url`

Data type: `Optional[String]`

URL of the GPG key

Default value: ``undef``

##### <a name="gpg_id"></a>`gpg_id`

Data type: `Optional[String]`

Key id of the gpg key

Default value: ``undef``

### <a name="xymonrepositoryyum"></a>`xymon::repository::yum`

Install the YUM repository, key (optionally) and the pacakge

#### Parameters

The following parameters are available in the `xymon::repository::yum` class:

* [`repository_url`](#repository_url)
* [`package`](#package)
* [`gpg_url`](#gpg_url)

##### <a name="repository_url"></a>`repository_url`

Data type: `String`

URL of the repository that contains the xymon-client

##### <a name="package"></a>`package`

Data type: `String`

Package name

##### <a name="gpg_url"></a>`gpg_url`

Data type: `Optional[String]`

URL of the GPG key for Debian repositories

Default value: ``undef``

### <a name="xymonrepositoryzypper"></a>`xymon::repository::zypper`

Install the Zypper repository, key (optionally) and the pacakge

#### Parameters

The following parameters are available in the `xymon::repository::zypper` class:

* [`repository_url`](#repository_url)
* [`package`](#package)
* [`gpg_url`](#gpg_url)

##### <a name="repository_url"></a>`repository_url`

Data type: `String`

URL of the repository that contains the xymon-client

##### <a name="package"></a>`package`

Data type: `String`

Package name

##### <a name="gpg_url"></a>`gpg_url`

Data type: `Optional[String]`

URL of the GPG key

Default value: ``undef``

## Defined types

### <a name="xymonclientmonitor"></a>`xymon::client::monitor`

Sets up a xymon monitor

* **See also**
  * https://forge.puppet.com/saz/sudo
    * Sudo component package used

#### Parameters

The following parameters are available in the `xymon::client::monitor` defined type:

* [`clientlaunch_config`](#clientlaunch_config)
* [`files_path`](#files_path)
* [`xymon_user`](#xymon_user)
* [`xymon_group`](#xymon_group)
* [`xymon_service`](#xymon_service)
* [`interval`](#interval)
* [`arguments`](#arguments)
* [`require_fqdn`](#require_fqdn)
* [`script_source`](#script_source)
* [`script_template`](#script_template)
* [`script_vars`](#script_vars)
* [`files`](#files)
* [`sudo`](#sudo)
* [`packages`](#packages)
* [`logrotate`](#logrotate)

##### <a name="clientlaunch_config"></a>`clientlaunch_config`

Data type: `String`

Path to the Xymon clientlaunch path. Will be provided by xymon::client automatically

##### <a name="files_path"></a>`files_path`

Data type: `String`

Path to the a path for additional files. Will be provided by xymon::client automatically

##### <a name="xymon_user"></a>`xymon_user`

Data type: `String`

Xymon user. Will be provided by xymon::client automatically

##### <a name="xymon_group"></a>`xymon_group`

Data type: `String`

Xymon group. Will be provided by xymon::client automatically

##### <a name="xymon_service"></a>`xymon_service`

Data type: `String`

Xymon service name. Will be provided by xymon::client automatically

##### <a name="interval"></a>`interval`

Data type: `String`

A valid Xymon client interval string when to run the script

Default value: `'5m'`

##### <a name="arguments"></a>`arguments`

Data type: `Array[String]`

A list of command line arguments to start the script with

Default value: `[]`

##### <a name="require_fqdn"></a>`require_fqdn`

Data type: `Optional[String]`

Require that the agent has the specified FQDN for the monitor to be installed

Default value: ``undef``

##### <a name="script_source"></a>`script_source`

Data type: `Optional[String]`

A Puppet file source to the script for the monitor (mutually exclusive with script_template)

Default value: ``undef``

##### <a name="script_template"></a>`script_template`

Data type: `Optional[String]`

A Puppet file source to the script for the monitor (mutually exclusive with script_source)

Default value: ``undef``

##### <a name="script_vars"></a>`script_vars`

Data type: `Optional[Hash]`

A hash of variables for script_template (if used)

Default value: ``undef``

##### <a name="files"></a>`files`

Data type: `Optional[Hash]`

A hash of filenames as key and sources as values to add to the xymon files
@option files :source A Puppet file source for the additional file for the monitor (mutually exclusive with template)
@option files :template A Puppet template for the additional file for the monitor (mutually exclusive with source)
@option files :vars A hash of variables used in the template
@option files :mode file mode of the additional file for the monitor
@option files :owner owner of the additional file for the monitor
@option files :group group of the additional file for the monitor

Default value: ``undef``

##### <a name="sudo"></a>`sudo`

Data type: `Optional[Hash]`

A sudo::conf hash with sudo definitions the xymon user should be allowed to use

Default value: ``undef``

##### <a name="packages"></a>`packages`

Data type: `Optional[Hash]`

A puppet package hash with packages that are required for the monitor to work

Default value: ``undef``

##### <a name="logrotate"></a>`logrotate`

Data type: `Optional[Hash]`

A hash containing definitions to configure logfile rotation
@option logrotate :path path for the file to logrotate
@option logrotate :size file size threshold when to rotate (human readable format accepted)
@option logrotate :rotate how many times the log is rotated until it is deleted

Default value: ``undef``

