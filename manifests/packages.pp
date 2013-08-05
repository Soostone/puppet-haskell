
class haskell::packages {
  # package { 'curl'          : }

  package { 'libgmp3-dev'   : }
  # package { 'libgmp10'      : }
  file { "/usr/lib/libgmp.so.3" :
    ensure => link,
    target => "/usr/lib/x86_64-linux-gnu/libgmp.so.10",
  }

  package { 'freeglut3'     : }
  package { 'freeglut3-dev' : }
}

