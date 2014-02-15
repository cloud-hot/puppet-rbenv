class rbenv::passenger::gems($ruby_version, $version, $user) {
  rbenv::gem { 'passenger':
    user   => "$user",
    ruby   => "$ruby_version",
    ensure => "$version",
  }
}
