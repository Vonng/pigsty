# pigsty building environment with 5 EL / Deb nodes

Specs = [

  { "name" => "build-el7"     , "ip" => "10.10.10.7"    , "cpu" => "8"    , "mem" => "32768"    , "image" =>  "generic/centos7"    },
  { "name" => "build-el8"     , "ip" => "10.10.10.8"    , "cpu" => "8"    , "mem" => "32768"    , "image" =>  "generic/rocky8"     },
  { "name" => "build-el9"     , "ip" => "10.10.10.9"    , "cpu" => "8"    , "mem" => "32768"    , "image" =>  "generic/rocky9"     },
  { "name" => "debian12"      , "ip" => "10.10.10.12"   , "cpu" => "8"    , "mem" => "32768"    , "image" =>  "generic/debian12"   },
  { "name" => "ubuntu22"      , "ip" => "10.10.10.22"   , "cpu" => "8"    , "mem" => "32768"    , "image" =>  "generic/ubuntu2204" },

]
