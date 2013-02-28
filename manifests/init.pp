# == Class: haskell
#
# Full description of class haskell here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { haskell:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2011 Your name here, unless otherwise noted.
#
class haskell(
  $dev              = false,
  $ghc_version      = '7.4.2',
  $ghc_arch         = 'x86_64',
  $platform_version = '2012.4.0.0',
  $user             = 'root'
) {
  $home = $user ? {
    'root'  => '/root',
    default => "/home/$user"
  }

  package { 'curl'        : }
  package { 'libgmp3-dev' : }
  package { 'libgmp3c2'   : }

  # GHC
  # http://www.haskell.org/ghc/dist/7.4.2/ghc-7.4.2-x86_64-unknown-linux.tar.bz2
  $ghc_file    = "ghc-$ghc_version-$ghc_arch-unknown-linux.tar.bz2"
  $ghc_url     = "http://www.haskell.org/ghc/dist/$ghc_version/$ghc_file"
  $ghc_dirname = "ghc-$ghc_version"

  exec { "curl $ghc_file" :
    command => "curl $ghc_url > /tmp/$ghc_file",
    path    => ['/usr/bin'],
    require => Package['curl']
  }

  exec { "tar $ghc_file" :
    command => "tar xfj $ghc_file",
    path    => ['/bin', '/usr/bin'],
    cwd     => '/tmp',
    require => Exec["curl $ghc_file"],
    creates => "/tmp/$ghc_dirname"
  }

  exec { 'ghc configure' :
    command => "/tmp/$ghc_dirname/configure",
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    cwd     => "/tmp/$ghc_dirname",
    require => [Exec["tar $ghc_file"], Package['libgmp3-dev'], Package['libgmp3c2']]
  }

  exec { 'ghc make install' :
    command => 'make install',
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    cwd     => "/tmp/$ghc_dirname",
    require => Exec['ghc configure'],
    creates => '/usr/local/bin/ghc'
  }

  # Haskell Platform
  # http://lambda.haskell.org/platform/download/2012.4.0.0/haskell-platform-2012.4.0.0.tar.gz
  package { 'freeglut3'     : }
  package { 'freeglut3-dev' : }

  $hp_file    = "haskell-platform-$platform_version.tar.gz"
  $hp_url     = "http://lambda.haskell.org/platform/download/$platform_version/$hp_file"
  $hp_dirname = "haskell-platform-$platform_version"

  exec { "curl $hp_file" :
    command => "curl $hp_url > /tmp/$hp_file",
    path    => ['/usr/bin'],
    require => Package['curl']
  }

  exec { "tar $hp_file" :
    command => "tar xfz $hp_file",
    path    => ['/bin', '/usr/bin'],
    cwd     => '/tmp',
    require => Exec["curl $hp_file"],
    creates => "/tmp/$hp_dirname"
  }

  exec { "haskell platform configure" :
    command => "/tmp/$hp_dirname/configure --prefix=/usr/local --disable-user-install",
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    cwd     => "/tmp/$hp_dirname",
    require => [Exec["tar $hp_file"], Exec['ghc make install']]
  }

  exec { "haskell platform install" :
    command => 'make install',
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    cwd     => "/tmp/$hp_dirname",
    timeout => 0,
    require => [Exec['haskell platform configure'], Package['freeglut3'], Package['freeglut3-dev']],
    creates => '/usr/local/bin/cabal'
  }

  # cabal update
  exec { 'cabal update' :
    user        => $user,
    environment => "HOME=$home",
    path        => ['/bin', '/usr/bin', '/usr/local/bin'],
    require     => Exec['haskell platform install']
  }

  # cabal upgrade
  exec { 'cabal install cabal-install' :
    user        => $user,
    environment => "HOME=$home",
    path        => ['/bin', '/usr/bin', '/usr/local/bin'],
    require     => Exec['cabal update']
  }

  # # cabal-dev
  if $dev {
    exec { 'cabal install cabal-dev' :
      # Need to extra packages listed to get around breaking versions and
      # dependencies.
      command     => "$home/.cabal/bin/cabal install cabal-dev",
      user        => $user,
      environment => "HOME=$home",
      path        => ["$home/.cabal/bin", '/usr', '/usr/bin', '/usr/local/bin'],
      require     => Exec['cabal install cabal-install']
    }
  }

  ## TODO break the three sections out into separate classes

}
