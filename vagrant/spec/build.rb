# pigsty building environment with 7 EL / Deb nodes

Specs = [

  # EL 8/9
  { "name" => "build-el8"     , "ip" => "10.10.10.8"    , "cpu" => "8"    , "mem" => "32768"    , "image" =>  "generic/rocky8"     },
  { "name" => "build-el9"     , "ip" => "10.10.10.9"    , "cpu" => "8"    , "mem" => "32768"    , "image" =>  "generic/rocky9"     },

  # Debian 12 / Ubuntu 20.04 / Ubuntu 22.04
  { "name" => "debian12"      , "ip" => "10.10.10.12"   , "cpu" => "8"    , "mem" => "32768"    , "image" =>  "generic/debian12"   },
  { "name" => "ubuntu20"      , "ip" => "10.10.10.20"   , "cpu" => "8"    , "mem" => "32768"    , "image" =>  "generic/ubuntu2004" },
  { "name" => "ubuntu22"      , "ip" => "10.10.10.22"   , "cpu" => "8"    , "mem" => "32768"    , "image" =>  "generic/ubuntu2204" },

]
