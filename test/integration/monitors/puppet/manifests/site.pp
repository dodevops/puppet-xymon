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
    monitors          => {
      'test'  => {
        script_source => 'puppet:///modules/files/testscript.sh',
        files         => {
          'testfile1' => {
            source => 'puppet:///modules/files/testfile1',
          }
        },
        sudo          => {
          'testsudo' => {
            content => 'xymon ALL=(ALL) NOPASSWD: /usr/bin/rootcheck'
          }
        },
        packages      => {
          'curl' => {
            ensure => 'installed'
          },
          'mc'   => {
            ensure => 'installed'
          }
        }
      },
      'test2' => {
        script_source => 'puppet:///modules/files/testscript2.sh',
        files         => {
          'testfile2' => {
            source => 'puppet:///modules/files/testfile2',
          }
        },
        sudo          => {
          'testsudo2' => {
            content => 'xymon ALL=(ALL) NOPASSWD: /usr/bin/rootcheck2'
          }
        },
        packages      => {
          'curl'    => {
            ensure => 'installed'
          },
          'sysstat' => {
            ensure => 'installed'
          }
        }
      },
      'test3' => {
        ensure        => 'absent',
        script_source => 'puppet:///modules/files/testscript2.sh',
        files         => {
          'testfile3' => {
            source => 'puppet:///modules/files/testfile2',
          }
        },
        sudo          => {
          'testsudo3' => {
            content => 'xymon ALL=(ALL) NOPASSWD: /usr/bin/rootcheck3'
          }
        },
      }
    }
}
