# @summary Installs Xymon client, configures it and optionally sets up monitors
# @see xymon::client::test
# @param repository_url URL of the repository that contains the xymon-client
# @param xymon_server The xymon server to use
# @param config_file Path to the xymon-client configuration file
# @param package Package name
# @param service_name Service name
# @param xymon_config_dir Directory where the xymon configs are stored
# @param xymon_user The system user that is used by xymon
# @param xymon_group The system group that is used by xymon
# @param gpg_url URL of the GPG key
# @param gpg_id Key id of the gpg key (Required by apt)
# @param monitors A hash of tests to configure
# @param client_name Name of the client (defaults to the FQDN)
# @param clientlaunch_config Path ot the clientlaunch configuration directory
#                            (defaults to $xymon_config_dir/clientlaunch.d)
# @param files_path A path where to store additional files required by the monitors (defaults to
#                   ($xymon_config_dir/files)
#
# @example
#    class {
#      'xymon::client':
#        repository_url = 'https://my.repository.company.com/repo',
#        xymon_server = 'xymon.company.com',
#        gpg_url = 'https://my.repository.company.com/gpg',
#        gpg_id = '6688A3782BBFE5A4',
#        monitors = {
#            'mycheck': {
#              script_source: 'puppet:///my/script.sh'
#              arguments: [
#                '--yellow=80',
#                '--red=90',
#                '--check-values=/etc/xymon/files/rootcheck.cfg
#              ],
#              sudo: {
#                'rootcheck': {
#                  content: 'xymon ALL=(ALL) NOPASSWD: /usr/bin/rootcheck',
#                }
#              },
#              packages: {
#                'rootcheck': { ensure: 'latest' },
#              },
#              files: {
#                'rootcheck.cfg': 'puppet:///my/rootcheck.cfg',
#              }
#            }
#        }
class xymon::client (
  String $repository_url,
  String $xymon_server,
  String $config_file                   = '/etc/default/xymon-client',
  String $package                       = 'xymon-client',
  String $service_name                  = 'xymon-client',
  String $xymon_config_dir              = '/etc/xymon',
  String $xymon_user                    = 'xymon',
  String $xymon_group                   = 'xymon',
  Optional[String] $gpg_url             = undef,
  Optional[String] $gpg_id              = undef,
  Optional[Hash] $monitors              = undef,
  Optional[String] $client_name         = undef,
  Optional[String] $clientlaunch_config = undef,
  Optional[String] $files_path          = undef,
) {

  $_clientlaunch_config = $clientlaunch_config ? {
    undef   => "${xymon_config_dir}/clientlaunch.d",
    default => $clientlaunch_config
  }

  $_files_path = $files_path ? {
    undef   => "${xymon_config_dir}/files",
    default => $files_path
  }

  $_client_name = $client_name ? {
    undef   => $facts['fqdn'],
    default => $client_name
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
    $_files_path:
      ensure => 'directory',
  }

  -> file {
    $_clientlaunch_config:
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
        clientlaunch_config => $_clientlaunch_config,
        files_path          => $_files_path,
        xymon_user          => $xymon_user,
        xymon_group         => $xymon_group,
        xymon_service       => $service_name,
        require             => Package[$package],
        notify              => Service[$service_name]
      }
    )
  }
}
