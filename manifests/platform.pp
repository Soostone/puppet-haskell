
class haskell::platform {
  # http://lambda.haskell.org/platform/download/2012.4.0.0/haskell-platform-2012.4.0.0.tar.gz
  $platform_version = $haskell::platform_version
  $hp_file          = "haskell-platform-$platform_version.tar.gz"
  $hp_url           = "http://lambda.haskell.org/platform/download/$platform_version/$hp_file"
  $hp_dirname       = "haskell-platform-$platform_version"

  exec { "curl $hp_file" :
    command => "curl $hp_url > /tmp/$hp_file",
    path    => ['/usr/bin'],
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
    require => Exec["tar $hp_file"],
  }

  exec { "haskell platform install" :
    command => 'make install',
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    cwd     => "/tmp/$hp_dirname",
    timeout => 0,
    require => Exec['haskell platform configure'],
    creates => '/usr/local/bin/cabal'
  }

}

