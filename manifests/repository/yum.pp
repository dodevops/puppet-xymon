# @summary Install the YUM repository, key (optionally) and the pacakge
# @param repository_url URL of the repository that contains the xymon-client
# @param package Package name
# @param gpg_url URL of the GPG key for Debian repositories
class xymon::repository::yum (
  String $repository_url,
  String $package,
  Optional[String] $gpg_url = undef,
) {
  $_gpgcheck = $gpg_url ? {
    undef   => false,
    default => true
  }
  yumrepo {
    'xymon':
      ensure   => 'present',
      baseurl  => $repository_url,
      gpgkey   => $gpg_url,
      gpgcheck => $_gpgcheck,
      before   => Package[$package],
  }
}
