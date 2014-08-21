
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

}

