# pigsty building environment with 3 nodes: centos7.9 / rocky8.7 / rocky9.1 , 3 x 4C8G

Specs = [
  { "name" => "build-el7"     , "ip" => "10.10.10.7"    , "cpu" => "4"    , "mem" => "8182"    , "image" =>  "generic/centos7" },
  { "name" => "build-el8"     , "ip" => "10.10.10.8"    , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/rocky8"  },
  { "name" => "build-el9"     , "ip" => "10.10.10.9"    , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/rocky9"  },
]

