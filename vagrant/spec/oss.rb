# oss: pigsty open-source building environment templates： RockyLinux 8.9 / Debian 12.4 / Ubuntu 22.04

Specs = [

  # RockyLinux 8.9
  { "name" => "el8",    "ip" => "10.10.10.8" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/rocky8"         },

  # Debian 12.4
  { "name" => "d12",    "ip" => "10.10.10.12",  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/debian12"       },

  # Ubuntu 22.04
  { "name" => "u22",    "ip" => "10.10.10.22",  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/ubuntu2204"     },

]
