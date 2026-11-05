# @summary Install the APT repository, key (optionally) and the pacakge
# @param repository_url URL of the repository that contains the xymon-client
# @param package Package name
# @param gpg_url URL of the GPG key, stored as keyring in /etc/apt/keyrings
class xymon::repository::apt (
  String $repository_url,
  String $package,
  Optional[String] $gpg_url = undef,
) {
  # apt reads binary keys only from *.gpg and ASCII armored keys only from *.asc
  $_key = $gpg_url ? {
    undef   => undef,
    default => {
      'name'   => $gpg_url ? { /\.gpg\z/ => 'xymon.gpg', default => 'xymon.asc' },
      'source' => $gpg_url,
    },
  }

  apt::source { 'xymon':
    location => $repository_url,
    key      => $_key,
    before   => Package[$package],
  }
}
