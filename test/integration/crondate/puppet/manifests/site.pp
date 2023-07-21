# Disable modifying configuration to not irritate Kitchen

class {
  'xymon::client':
    manage_repository => false,
    xymon_server      => '127.0.0.1',
    config_file       => '/etc/xymon/config',
    monitors          => {
      'test'  => {
        script_source => 'puppet:///modules/files/testscript.sh',
      },
      'test2' => {
        script_source => 'puppet:///modules/files/testscript2.sh',
        interval      => '10m',
      },
      'test3' => {
        script_source => 'puppet:///modules/files/testscript2.sh',
        cron_date     => '0 0 * * *',
      }
    }
}
