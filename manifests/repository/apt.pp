# @summary Install the APT repository, key (optionally) and the pacakge
# @param repository_url URL of the repository that contains the xymon-client
# @param package Package name
# @param gpg_url URL of the GPG key
# @param gpg_id Key id of the gpg key
class xymon::repository::apt (
  String $repository_url,
  String $package,
  Optional[String] $gpg_url = undef,
  Optional[String] $gpg_id  = undef,
) {
  apt::source {
    'xymon':
      location => $repository_url,
      before => Package[$package]
  }

  if ($gpg_url) {
    apt::key {
      $gpg_id:
        source => $gpg_url,
        before => Apt::Source['xymon']
    }
  }
}
