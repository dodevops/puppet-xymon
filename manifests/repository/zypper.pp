# @summary Install the APT repository, key (optionally) and the pacakge
# @param repository_url URL of the repository that contains the xymon-client
# @param package Package name
# @param gpg_url URL of the GPG key
class xymon::repository::zypper (
  String $repository_url,
  String $package,
  Optional[String] $gpg_url = undef,
) {
  $_gpgcheck = $gpg_url ? {
    undef   => 0,
    default => 1
  }
  zypprepo {
    'xymon':
      baseurl  => $repository_url,
      gpgkey   => $gpg_url,
      gpgcheck => $_gpgcheck
  }
  -> package {
    $package:
      ensure => 'latest',
  }
}
