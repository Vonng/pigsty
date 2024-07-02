# pigsty building environment with 7 EL / Deb nodes

Specs = [

  # EL 8/9
  { "name" => "build-el8"     , "ip" => "10.10.10.8"    , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/rocky8"     },
  { "name" => "build-el9"     , "ip" => "10.10.10.9"    , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/rocky9"     },

  # Debian 11/12
  { "name" => "debian11"      , "ip" => "10.10.10.11"   , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/debian11"   },
  { "name" => "debian12"      , "ip" => "10.10.10.12"   , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/debian12"   },

  # Ubuntu 20.04/22.04
  { "name" => "ubuntu20"      , "ip" => "10.10.10.20"   , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/ubuntu2004" },
  { "name" => "ubuntu22"      , "ip" => "10.10.10.22"   , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/ubuntu2204" },

]
