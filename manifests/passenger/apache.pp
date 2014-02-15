class rbenv::passenger::apache(
  $user,
  $ruby_version,
  $gem_version,
  $version,
  $rbenv_prefix = '/home/',
  $mininstances = '1',
  $maxpoolsize = '6',
  $poolidletime = '300',
  $maxinstancesperapp = '0',
  $spawnmethod = 'smart-lv2'
) {

  case $::operatingsystem {
    Ubuntu,Debian: { include rbenv::passenger::apache::ubuntu::pre }
  }

  class {
    'rbenv::passenger::gems':
      ruby_version => $ruby_version,
      version => $version,
      user    => $user,
  }

  # TODO: How can we get the gempath automatically using the ruby version
  # Can we read the output of a command into a variable?
  # e.g. $gempath = `rbenv ${ruby_version} exec rvm gemdir`
  $gempath = "${rbenv_prefix}/.rbenv/versions/${ruby_version}/lib/ruby/gems/${gem_version}/gems"

  case $::operatingsystem {
    Ubuntu,Debian: {
      if !defined(Class['rbenv::passenger::apache::ubuntu::post']) {
        class { 'rbenv::passenger::apache::ubuntu::post':
          user               => $user,
          ruby_version       => $ruby_version,
          version            => $version,
          rbenv_prefix       => $rbenv_prefix,
          mininstances       => $mininstances,
          maxpoolsize        => $maxpoolsize,
          poolidletime       => $poolidletime,
          maxinstancesperapp => $maxinstancesperapp,
          spawnmethod        => $spawnmethod,
          gempath            => $gempath,
        }
      }
    }
  }
}
