# Disable modifying configuration to not irritate Kitchen

class {
  'sudo':
    purge               => false,
    config_file_replace => false,
}

class {
  'xymon::client':
    manage_repository => false,
    xymon_server      => '127.0.0.1',
    config_file       => '/etc/xymon/config',
}
