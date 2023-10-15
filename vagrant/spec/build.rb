# pigsty building environment with 3 EL nodes: centos7.9 / rocky8.7 / rocky9.1 and 4 debian nodes: debian11 / debian12 / ubuntu20.04 / ubuntu22.04

Specs = [

  # EL 7/8/9
  { "name" => "build-el7"     , "ip" => "10.10.10.7"    , "cpu" => "4"    , "mem" => "8182"    , "image" =>  "generic/centos7"    },
  { "name" => "build-el8"     , "ip" => "10.10.10.8"    , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/rocky8"     },
  { "name" => "build-el9"     , "ip" => "10.10.10.9"    , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/rocky9"     },

  # Debian 11/12
  { "name" => "debian11"      , "ip" => "10.10.10.11"   , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/debian11"   },
  { "name" => "debian12"      , "ip" => "10.10.10.12"   , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/debian12"   },

  # Ubuntu 20.04/22.04
  { "name" => "ubuntu20"      , "ip" => "10.10.10.20"   , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/ubuntu2004" },
  { "name" => "ubuntu22"      , "ip" => "10.10.10.22"   , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/ubuntu2204" },

]
