
define haskell::cabal(
  $package = $name,
  $version = 'latest',
  $dev     = false,
  $creates = false
) {

  $cabal = 'cabal'

  if ($dev) {
    $cabal = 'cabal-dev'
  }

  $spec = $package
  if $version != 'latest' {
    $spec = "$spec-$version"
  }

  if $creates {
    exec { "cabal: $package" :
      command => "$cabal install $spec",
      path    => ["/usr/bin", "/usr/sbin"],
      creates => $creates
    }
  } else {
    exec { "cabal: $package" :
      command => "$cabal install $spec",
      path    => ["/usr/bin", "/usr/sbin"]
    }
  }

  # Install the package.

  if ($dev) {
    Exec['cabal: cabal-dev'] -> Exec["cabal: $package"]
  }

}

