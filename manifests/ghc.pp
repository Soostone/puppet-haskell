
class haskell::ghc {

  # http://www.haskell.org/ghc/dist/7.4.2/ghc-7.4.2-x86_64-unknown-linux.tar.bz2
  $ghc_version = $haskell::ghc_version
  $ghc_arch    = $haskell::ghc_arch
  $ghc_file    = "ghc-$ghc_version-$ghc_arch-unknown-linux.tar.bz2"
  $ghc_url     = "http://www.haskell.org/ghc/dist/$ghc_version/$ghc_file"
  $ghc_dirname = "ghc-$ghc_version"

  exec { "curl $ghc_file" :
    command => "curl $ghc_url > /tmp/$ghc_file",
    path    => ['/usr/bin'],
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
    require => Exec["tar $ghc_file"],
  }

  exec { 'ghc make install' :
    command => 'make install',
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    cwd     => "/tmp/$ghc_dirname",
    require => Exec['ghc configure'],
    creates => '/usr/local/bin/ghc'
  }

}

