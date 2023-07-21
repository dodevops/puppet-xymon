# @summary
#   Sets up a xymon monitor
#
# @see https://forge.puppet.com/saz/sudo Sudo component package used
# @see https://forge.puppet.com/modules/puppet/logrotate Logrotate component package used
#
# @param clientlaunch_config
#   Path to the Xymon clientlaunch path. Will be provided by xymon::client automatically
#
# @param files_path
#   Path to the a path for additional files. Will be provided by xymon::client automatically
#
# @param xymon_user
#   Xymon user. Will be provided by xymon::client automatically
#
# @param xymon_group
#   Xymon group. Will be provided by xymon::client automatically
#
# @param xymon_service
#   Xymon service name. Will be provided by xymon::client automatically
#
# @param ensure
#   Ensure if monitor is either present or absent
#
# @param arguments
#   A list of command line arguments to start the script with
#
# @param interval
#   A valid Xymon client interval string when to run the script. If neither interval nor
#   crondate is set, interval is set to a default of 5m
#
# @param crondate
#   A cron time expression as an alternative to the interval parameter
#
# @param require_fqdn
#   Require that the agent has the specified FQDN for the monitor to be installed
#
# @param script_source
#   A Puppet file source to the script for the monitor (mutually exclusive with script_template)
#
# @param script_template
#   A Puppet file source to the script for the monitor (mutually exclusive with script_source)
#
# @param script_vars
#   A hash of variables for script_template (if used)
#
# @param files
#   A hash of filenames as key and sources as values to add to the xymon files
# @option files :source [String]
#   A Puppet file source for the additional file for the monitor (mutually exclusive with template)
# @option files :template [String]
#   A Puppet template for the additional file for the monitor (mutually exclusive with source)
# @option files :vars [Hash]
#   A hash of variables used in the template
# @option files :mode [String]
#   file mode of the additional file for the monitor
# @option files :owner [String]
#   owner of the additional file for the monitor
# @option files :group [String]
#   group of the additional file for the monitor
#
# @param sudo
#   A sudo::conf hash with sudo definitions the xymon user should be allowed to use
#
# @param packages
#   A puppet package hash with packages that are required for the monitor to work
#
# @param logrotate
#   A hash containing definitions to configure logfile rotation
# @option logrotate :path [String]
#   path for the file to logrotate
# @option logrotate :size [String]
#   file size threshold when to rotate (human readable format accepted)
# @option logrotate :rotate [Integer]
#   how many times the log is rotated until it is deleted
#
# @param ensure_packages
#   Ensure that installed packages from the packages repository are present or absent (defaults to the value of the
#   ensure-parameter)
define xymon::client::monitor (
  String $clientlaunch_config                          = $xymon::client::actual_clientlaunch_config,
  String $files_path                                   = $xymon::client::actual_files_path,
  String $xymon_user                                   = $xymon::client::xymon_user,
  String $xymon_group                                  = $xymon::client::xymon_group,
  String $xymon_service                                = $xymon::client::service_name,
  Enum['present', 'absent'] $ensure                    = 'present',
  Array[String] $arguments                             = [],
  Optional[String] $interval                           = undef,
  Optional[String] $cron_date                          = undef,
  Optional[String] $require_fqdn                       = undef,
  Optional[String] $script_source                      = undef,
  Optional[String] $script_template                    = undef,
  Optional[Hash] $script_vars                          = undef,
  Optional[Hash] $files                                = undef,
  Optional[Hash] $sudo                                 = undef,
  Optional[Hash] $packages                             = undef,
  Optional[Hash] $logrotate                            = undef,
  Optional[Enum['present', 'absent']] $ensure_packages = undef,
) {
  if (!$require_fqdn or $facts['fqdn'] == $require_fqdn) {
    $_ensure_packages = $ensure_packages ? {
      undef   => $ensure,
      default => $ensure_packages
    }
    $_interval = $interval ? {
      undef   => $cron_date ? {
        undef   => '5m',
        default => undef,
      },
      default => $interval,
    }
    if ($files) {
      $files.each |String $key, Hash $value| {
        $mode = empty($value[mode]) ? {
          false   => $value[mode],
          default => '0644'
        }
        $group = empty($value[group]) ? {
          false   => $value[group],
          default => 'xymon'
        }
        $owner = empty($value[owner]) ? {
          false   => $value[owner],
          default => 'xymon'
        }
        # Replace the '@' in the key with the script identifier to create the filename
        if $key =~ /(.*)@(.*)/ {
          $filename = "${1}${name}${2}"
        } else {
          $filename = $key
        }
        if ($value[source]) {
          ensure_resource(
            'file',
            "${files_path}/${filename}",
            {
              ensure => $ensure,
              owner  => $owner,
              group  => $group,
              mode   => $mode,
              source => $value[source],
              before => File["${clientlaunch_config}/${name}.sh"]
            }
          )
        } elsif ($value[template]) {
          ensure_resource(
            'file',
            "${files_path}/${filename}",
            {
              ensure  => $ensure,
              owner   => $owner,
              group   => $group,
              mode    => $mode,
              content => epp($value[template], $value[vars]),
              before  => File["${clientlaunch_config}/${name}.sh"]
            }
          )
        } else {
          fail('unknown additional file configuration')
        }
      }

    }

    if ($sudo) {
      ensure_resources(
        'sudo::conf',
        $sudo,
        {
          ensure => $ensure,
          before => Service[$xymon_service]
        }
      )
    }

    if ($packages) {
      ensure_packages(
        $packages,
        {
          ensure => $_ensure_packages,
          before => Service[$xymon_service]
        }
      )
    }

    if ($script_source) {
      file {
        "${clientlaunch_config}/${name}.sh":
          ensure => $ensure,
          source => $script_source,
          owner  => $xymon_user,
          group  => $xymon_group,
          mode   => '0755',
          before => File["${clientlaunch_config}/${name}.cfg"],
      }
    } elsif ($script_template) {
      file {
        "${clientlaunch_config}/${name}.sh":
          ensure  => $ensure,
          content => epp($script_template, $script_vars),
          owner   => $xymon_user,
          group   => $xymon_group,
          mode    => '0755',
          before  => File["${clientlaunch_config}/${name}.cfg"],
      }
    } else {
      fail('please set either script_source or script_template')
    }

    file {
      "${clientlaunch_config}/${name}.cfg":
        ensure  => $ensure,
        content => epp(
          'xymon/monitor-config.epp',
          {
            name      => $name,
            script    => "${clientlaunch_config}/${name}.sh",
            arguments => join($arguments, ' '),
            interval  => $_interval,
            cron_date => $cron_date,
          }
        )
    } ~> Service[$xymon_service]
  }

  if $logrotate {
    logrotate::rule { "${name}.monitor":
      ensure        => $ensure,
      path          => $logrotate['path'],
      compress      => true,
      delaycompress => true,
      missingok     => true,
      size          => $logrotate['size'],
      rotate        => $logrotate['rotate'],
      dateformat    => '.%Y-%m-%d.log',
    }
  }
}
