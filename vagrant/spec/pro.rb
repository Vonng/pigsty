# pro: pigsty 5-node pro building environment templates: RockyLinux 8.9/9.3 / Debian 12 / Ubuntu 20.4/22.04

Specs = [

  # EL 8/9
  { "name" => "el8",    "ip" => "10.10.10.8" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/rocky8"         },
  { "name" => "el9",    "ip" => "10.10.10.9" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/rocky9"         },

  # Debian 12
  { "name" => "d12",    "ip" => "10.10.10.12",  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/debian12"       },

  # Ubuntu 20.04/22.04
  { "name" => "u20",    "ip" => "10.10.10.20",  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/ubuntu2004"     },
  { "name" => "u22",    "ip" => "10.10.10.22",  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/ubuntu2204"     },

]
