# @summary Sets up a xymon monitor
# @see https://forge.puppet.com/saz/sudo Sudo component package used
# @param script_source A Puppet file source to the script for the monitor
# @param clientlaunch_config Path to the Xymon clientlaunch path. Will be provided by xymon::client automatically
# @param files_path Path to the a path for additional files. Will be provided by xymon::client automatically
# @param xymon_user Xymon user. Will be provided by xymon::client automatically
# @param xymon_group Xymon group. Will be provided by xymon::client automatically
# @param xymon_service Xymon service name. Will be provided by xymon::client automatically
# @param interval A valid Xymon client interval string when to run the script
# @param arguments A list of command line arguments to start the script with
# @param require_fqdn Require that the agent has the specified FQDN for the monitor to be installed
# @param files A hash of filenames as key and sources as values to add to the xymon files
# @param sudo A sudo::conf hash with sudo definitions the xymon user should be allowed to use
# @param packages A puppet package hash with packages that are required for the monitor to work
# @param logrotate A hash containing definitions to configure logfile rotation
define xymon::client::monitor (
  String $script_source,
  String $clientlaunch_config,
  String $files_path,
  String $xymon_user,
  String $xymon_group,
  String $xymon_service,
  String $interval                        = '5m',
  Array[String] $arguments                = [],
  Optional[String] $require_fqdn          = undef,
  Optional[Hash] $files                   = undef,
  Optional[Hash] $sudo                    = undef,
  Optional[Hash] $packages                = undef,
  Optional[Hash] $logrotate               = undef,
) {
  if (!$require_fqdn or $facts['fqdn'] == $require_fqdn) {
    if ($files) {
      $files.each |String $key, Hash $value| {
        $mode = !empty($value[mode]) ? {
          true    => $value[mode],
          default => '0644'
        }
        $group = !empty($value[group]) ? {
          true    => $value[group],
          default => 'xymon'
        }
        $owner = !empty($value[owner]) ? {
          true    => $value[owner],
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
              owner  => $owner,
              group  => $group,
              mode   => $mode,
              source => $value[content],
              before => File["${clientlaunch_config}/${name}.sh"]
            }
          )
        } elsif ($value[template]) {
          ensure_resource(
            'file',
            "${files_path}/${filename}",
            {
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
          before => Service[$xymon_service]
        }
      )
    }

    if ($packages) {
      ensure_resources(
        'package',
        $packages,
        {
          before => Service[$xymon_service]
        }
      )
    }

    file {
      "${clientlaunch_config}/${name}.sh":
        source => $script_source,
        owner  => $xymon_user,
        group  => $xymon_group,
        mode   => '0755',
    }
    -> file {
      "${clientlaunch_config}/${name}.cfg":
        content => epp(
          'xymon/monitor-config.epp',
          {
            name      => $name,
            script    => "${clientlaunch_config}/${name}.sh",
            interval  => $interval,
            arguments => join($arguments, ' ')
          }
        )
    } ~> Service[$xymon_service]
  }

  if $logrotate {
    logrotate::rule { "${name}.monitor":
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
