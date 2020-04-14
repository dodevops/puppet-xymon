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
define xymon::client::monitor (
  String $script_source,
  String $clientlaunch_config,
  String $files_path,
  String $xymon_user,
  String $xymon_group,
  String $xymon_service,
  String $interval                 = '5m',
  Array[String] $arguments         = [],
  Optional[String] $require_fqdn   = undef,
  Optional[Hash] $files = undef,
  Optional[Hash] $sudo             = undef,
  Optional[Hash] $packages         = undef,
) {
  if (!$require_fqdn or $facts['fqdn'] == $require_fqdn) {
    if ($files) {
      $files.each |$value| {
        file {
          "${files_path}/${value[0]}":
            owner  => $xymon_user,
            group  => $xymon_group,
            source => $value[1],
            before => File["${clientlaunch_config}/${name}.sh"]
        }
      }
    }

    if ($sudo) {
      create_resources(
        'sudo::conf',
        $sudo,
        {
          before => File["${clientlaunch_config}/${name}.sh"]
        }
      )
    }

    if ($packages) {
      create_resources(
        'package',
        $packages,
        {
          before => File["${clientlaunch_config}/${name}.sh"]
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
}
