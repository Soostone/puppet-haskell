
define haskell::cabal(
  $package = $name,
  $version = 'latest',
  $creates = false
) {

  $cabal = 'cabal'

  $spec = $package
  if $version != 'latest' {
    $spec = "$spec-$version"
  }

  if $creates {
    exec { "cabal: $package" :
      command => "$cabal install $spec",
      path    => ["/usr/bin", "/usr/sbin", "/usr/local/bin", "~/.cabal/bin"],
      creates => $creates,
    }
  } else {
    exec { "cabal: $package" :
      command => "$cabal install $spec",
      path    => ["/usr/bin", "/usr/sbin", "/usr/local/bin", "~/.cabal/bin"],
    }
  }

}

