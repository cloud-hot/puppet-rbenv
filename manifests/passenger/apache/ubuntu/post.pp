class rbenv::passenger::apache::ubuntu::post(
  $user,
  $ruby_version,
  $version,
  $rbenv_prefix = '/home/',
  $mininstances = '1',
  $maxpoolsize = '6',
  $poolidletime = '300',
  $maxinstancesperapp = '0',
  $spawnmethod = 'smart-lv2',
  $gempath,
) {

  $bin         = "${rbenv_prefix}/.rbenv/bin"
  $shims       = "${rbenv_prefix}/.rbenv/shims"
  $path        = [ $shims, $bin, '/bin', '/usr/bin' ]

  exec {
    'passenger-install-apache2-module':
      command   => "rbenv global ${ruby_version}; rbenv rehash; exec passenger-install-apache2-module -a",
      creates   => "${gempath}/passenger-${version}/buildout/apache2/mod_passenger.so",
      logoutput => 'on_failure',
      require   => [Rbenvgem["${user}/${ruby_version}/passenger/${version}"], Package['apache2', 'build-essential', 'apache2-prefork-dev', 'libapr-dev', 'libaprutil-dev', 'libcurl4-openssl-dev']],
      path      => $path,
  }

  file {
    '/etc/apache2/mods-available/passenger.load':
      ensure  => file,
      content => "LoadModule passenger_module ${gempath}/passenger-${version}/buildout/apache2/mod_passenger.so",
      require => Exec['passenger-install-apache2-module'];

    '/etc/apache2/mods-available/passenger.conf':
      ensure  => file,
      content => template('rbenv/passenger-apache.conf.erb'),
      require => Exec['passenger-install-apache2-module'];

    '/etc/apache2/mods-enabled/passenger.load':
      ensure  => 'link',
      target  => '../mods-available/passenger.load',
      require => File['/etc/apache2/mods-available/passenger.load'];

    '/etc/apache2/mods-enabled/passenger.conf':
      ensure  => 'link',
      target  => '../mods-available/passenger.conf',
      require => File['/etc/apache2/mods-available/passenger.conf'];
  }

  # Add Apache restart hooks
  if defined(Service['apache']) {
    File['/etc/apache2/mods-available/passenger.load'] ~> Service['apache']
    File['/etc/apache2/mods-available/passenger.conf'] ~> Service['apache']
    File['/etc/apache2/mods-enabled/passenger.load']   ~> Service['apache']
    File['/etc/apache2/mods-enabled/passenger.conf']   ~> Service['apache']
  }
  if defined(Service['apache2']) {
    File['/etc/apache2/mods-available/passenger.load'] ~> Service['apache2']
    File['/etc/apache2/mods-available/passenger.conf'] ~> Service['apache2']
    File['/etc/apache2/mods-enabled/passenger.load']   ~> Service['apache2']
    File['/etc/apache2/mods-enabled/passenger.conf']   ~> Service['apache2']
  }
  if defined(Service['httpd']) {
    File['/etc/apache2/mods-available/passenger.load'] ~> Service['httpd']
    File['/etc/apache2/mods-available/passenger.conf'] ~> Service['httpd']
    File['/etc/apache2/mods-enabled/passenger.load']   ~> Service['httpd']
    File['/etc/apache2/mods-enabled/passenger.conf']   ~> Service['httpd']
  }
}
