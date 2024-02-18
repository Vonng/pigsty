# pigsty building environment with 3 EL nodes: centos7.9 / rocky8.9 / rocky9.3

Specs = [

  { "name" => "build-el7"     , "ip" => "10.10.10.7"    , "cpu" => "16"    , "mem" => "32768"    , "image" =>  "generic/centos7"    },
  { "name" => "build-el8"     , "ip" => "10.10.10.8"    , "cpu" => "16"    , "mem" => "32768"    , "image" =>  "generic/rocky8"     },
  { "name" => "build-el9"     , "ip" => "10.10.10.9"    , "cpu" => "16"    , "mem" => "32768"    , "image" =>  "generic/rocky9"     },

]
