$url = $facts['os']['family'] ? {
  'Debian' => "https://files.blueocean-net.de/repositories/xymon-deb ${facts['os']['distro']['codename']} main",
  'RedHat' => "https://files.blueocean-net.de/repositories/xymon-rpm/centos/${facts['os']['release']['major']}",
  'Suse'   => "https://files.blueocean-net.de/repositories/xymon-rpm/sles/${facts['os']['release']['major']}",
  default  => ''
}

$gpg_url = $facts['os']['family'] ? {
  'Debian' => 'https://files.blueocean-net.de/gpg.key',
  default => undef
}

if ($url == '') {
  fail("OS family ${facts['os']['family']} is not supported")
}

# Disable modifying configuration to not irritate Kitchen

class {
  'sudo':
    purge               => false,
    config_file_replace => false,
}

class {
  'xymon::client':
    repository_url => $url,
    xymon_server   => '127.0.0.1',
    gpg_url        => $gpg_url,
    gpg_id         => '6688A3782BBFE5A4',
    config_file    => '/etc/xymon/config',
}
