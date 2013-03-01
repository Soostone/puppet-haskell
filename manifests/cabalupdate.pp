
class haskell::cabalupdate {
  $user = $haskell::user
  $home = $haskell::home

  # cabal update
  exec { 'cabal update' :
    user        => $user,
    environment => "HOME=$home",
    path        => ['/bin', '/usr/bin', '/usr/local/bin'],
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

}

