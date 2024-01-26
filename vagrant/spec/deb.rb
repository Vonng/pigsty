# pigsty building environment with 4 Deb nodes: Debian11 Debian12 Ubuntu20 Ubuntu22

Specs = [

  # Debian 11/12
  { "name" => "debian11"      , "ip" => "10.10.10.11"   , "cpu" => "16"    , "mem" => "32768"    , "image" =>  "generic/debian11"   },
  { "name" => "debian12"      , "ip" => "10.10.10.12"   , "cpu" => "16"    , "mem" => "32768"    , "image" =>  "generic/debian12"   },

  # Ubuntu 20.04/22.04
  { "name" => "ubuntu20"      , "ip" => "10.10.10.20"   , "cpu" => "16"    , "mem" => "32768"    , "image" =>  "generic/ubuntu2004" },
  { "name" => "ubuntu22"      , "ip" => "10.10.10.22"   , "cpu" => "16"    , "mem" => "32768"    , "image" =>  "generic/ubuntu2204" },

]
