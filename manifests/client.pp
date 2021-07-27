# @summary
#   Installs Xymon client, configures it and optionally sets up monitors
#
# @param xymon_server
#   The xymon server to use
#
# @param manage_repository
#   Manage the repository for package installation
#
# @param config_file
#   Path to the xymon-client configuration file
#
# @param package
#   Package name
#
# @param service_name
#   Service name
#
# @param xymon_config_dir
#   Directory where the xymon configs are stored
#
# @param xymon_user
#   The system user that is used by xymon
#
# @param xymon_group
#   The system group that is used by xymon
#
# @param repository_url
#   URL of the repository that contains the xymon-client
#
# @param gpg_url
#   URL of the GPG key
#
# @param gpg_id
#   Key id of the gpg key (Required by apt)
#
# @param monitors
#   A hash of tests to configure
# @option monitors :script_source
#   A Puppet file source to the script for the monitor
# @option monitors :clientlaunch_config
#   Path to the Xymon clientlaunch path.
# @option monitors :files_path
#   Path to the a path for additional files.
# @option monitors :xymon_user
#   Xymon user.
# @option monitors :xymon_group
#   Xymon group.
# @option monitors :xymon_service
#   Xymon service name.
# @option monitors :interval
#   A valid Xymon client interval string when to run the script
# @option monitors :arguments
#   A list of command line arguments to start the script with
# @option monitors :require_fqdn
#   Require that the agent has the specified FQDN for the monitor to be installed
# @option monitors :files
#   A hash of filenames as key and sources as values to add to the xymon files
# @option files :source
#   A Puppet file source for the additional file for the monitor
# @option files :template
#   A Puppet template for the additional file for the monitor
# @option files :vars
#   A hash of variables used in the template
# @option files :mode
#   file mode of the additional file for the monitor
# @option files :owner
#   owner of the additional file for the monitor
# @option files :group
#   group of the additional file for the monitor
# @option monitors :sudo
#   A sudo::conf hash with sudo definitions the xymon user should be allowed to use
# @option monitors :packages
#   A puppet package hash with packages that are required for the monitor to work
# @option monitors :logrotate
#   A hash containing definitions to configure logfile rotation
# @option logrotate :path
#   path for the file to logrotate
# @option logrotate :size
#   file size threshold when to rotate (human readable format accepted)
# @option logrotate :rotate
#   how many times the log is rotated until it is deleted
#
# @param client_name
#   Name of the client (defaults to the FQDN)
#
# @param clientlaunch_config
#   Path ot the clientlaunch configuration directory (defaults to $xymon_config_dir/clientlaunch.d)
#
# @param files_path
#   A path where to store additional files required by the monitors (defaults to $xymon_config_dir/files)
#
# @example
#    class {
#      'xymon::client':
#        repository_url = 'https://my.repository.company.com/repo',
#        xymon_server = 'xymon.company.com',
#        gpg_url = 'https://my.repository.company.com/gpg',
#        gpg_id = '6688A3782BBFE5A4',
#        monitors = {
#            'mycheck' => {
#              script_source => 'puppet:///my/script.sh'
#              arguments => [
#                '--yellow=80',
#                '--red=90',
#                '--check-values=/etc/xymon/files/rootcheck.cfg
#              ],
#              sudo: {
#                'rootcheck' => {
#                  content => 'xymon ALL=(ALL) NOPASSWD: /usr/bin/rootcheck',
#                }
#              },
#              packages => {
#                'rootcheck' => { ensure => 'latest' },
#              },
#              files => {
#                'rootcheck.cfg' => {
#                   source => 'puppet:///my/rootcheck.cfg',
#                   mode => '0600',
#                 },
#                'mysql_connection.mycfg => {
#                   template => 'my/mysql_connection/mysql_connection.cfg.epp,
#                   mode => '0600',
#                   vars => {
#                     host => 'foo.bar.com',
#                     user => 'fancydbuser',
#                     password => 'fancypassword', # eyaml recommended here!
#                   }
#                }
#              },
#              logrotate => {
#                path   => '/var/log/xymon/script.log',
#                size   => '20M',
#                rotate => 5,
#              }
#            }
#        }
class xymon::client (
  String $xymon_server,
  Boolean $manage_repository            = true,
  String $config_file                   = '/etc/default/xymon-client',
  String $package                       = 'xymon-client',
  String $service_name                  = 'xymon-client',
  String $xymon_config_dir              = '/etc/xymon',
  String $xymon_user                    = 'xymon',
  String $xymon_group                   = 'xymon',
  Optional[String] $repository_url      = undef,
  Optional[String] $gpg_url             = undef,
  Optional[String] $gpg_id              = undef,
  Optional[Hash] $monitors              = undef,
  Optional[String] $client_name         = undef,
  Optional[String] $clientlaunch_config = undef,
  Optional[String] $files_path          = undef,
) {

  $actual_clientlaunch_config = $clientlaunch_config ? {
    undef   => "${xymon_config_dir}/clientlaunch.d",
    default => $clientlaunch_config
  }

  $actual_files_path = $files_path ? {
    undef   => "${xymon_config_dir}/files",
    default => $files_path
  }

  $_client_name = $client_name ? {
    undef   => $facts['fqdn'],
    default => $client_name
  }

  if ($manage_repository) {
    if (!$repository_url) {
      fail('Repository URL for xymon-client required, when manage_repository is true')
    }

    case $facts['os']['family'] {
      'Debian': {
        if ($gpg_url and !$gpg_id) {
          fail('GPG-URL specified, but no GPG ID given')
        }

        class {
          'xymon::repository::apt':
            repository_url => $repository_url,
            package        => $package,
            gpg_url        => $gpg_url,
            gpg_id         => $gpg_id,
        }
      }
      'RedHat': {
        class {
          'xymon::repository::yum':
            repository_url => $repository_url,
            package        => $package,
            gpg_url        => $gpg_url
        }
      }
      'Suse': {
        class {
          'xymon::repository::zypper':
            repository_url => $repository_url,
            package        => $package,
            gpg_url        => $gpg_url
        }
      }
      default: {
        notify { "The xymon::client profile doesn't support os family ${facts['os']['family']}": }
      }
    }
  }

  package {
    $package:
      ensure  => 'latest',
  }

  file {
    $config_file:
      content => epp(
        'xymon/xymon-client.epp',
        {
          client_hostname => $_client_name,
          xymon_server    => $xymon_server,
        }
      ),
      require => Package[$package]
  }

  -> file {
    $actual_files_path:
      ensure => 'directory',
  }

  -> file {
    $actual_clientlaunch_config:
      ensure => 'directory',
  }

  -> service {
    $service_name:
      ensure => 'running'
  }

  if ($monitors) {
    create_resources(
      'xymon::client::monitor',
      $monitors,
      {
        require             => Package[$package],
      }
    )
  }

  Package[$package] -> Xymon::Client::Monitor<||>
}
