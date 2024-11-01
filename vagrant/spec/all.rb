# deb: pigsty 7-node rocky/debian/ubuntu building environment templates:

Specs = [

  # EL 7/8/9
  { "name" => "el7",    "ip" => "10.10.10.7" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/centos7"        },
  { "name" => "el8",    "ip" => "10.10.10.8" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/rocky8"         },
  { "name" => "el9",    "ip" => "10.10.10.9" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/rocky9"         },

  # Debian 11/12
  { "name" => "d11",    "ip" => "10.10.10.11",  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/debian11"       },
  { "name" => "d12",    "ip" => "10.10.10.12",  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/debian12"       },

  # Ubuntu 20.04/22.04
  { "name" => "u20",    "ip" => "10.10.10.20",  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/ubuntu2004"     },
  { "name" => "u22",    "ip" => "10.10.10.22",  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/ubuntu2204"     },
  { "name" => "u24",    "ip" => "10.10.10.24",  "cpu" => "1",  "mem" => "2048",  "image" =>  "bento/ubuntu-24.04"     },

]
