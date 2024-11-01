# oss: pigsty building environment templates： RockyLinux 8.9 / RockyLinux 9.3 / Debian 12.4 / Ubuntu 22.04

Specs = [

  # RockyLinux 8.9
  { "name" => "el8",    "ip" => "10.10.10.8" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/rocky8"         },

  # RockyLinux 9.3
  { "name" => "el9",    "ip" => "10.10.10.9" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/rocky9"         },

  # Debian 12.4
  { "name" => "d12",    "ip" => "10.10.10.12",  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/debian12"       },

  # Ubuntu 22.04
  { "name" => "u22",    "ip" => "10.10.10.22",  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/ubuntu2204"     },

  # Ubuntu 24.04
  { "name" => "u24",    "ip" => "10.10.10.24",  "cpu" => "1",  "mem" => "2048",  "image" =>  "bento/ubuntu-24.04"     },

]
