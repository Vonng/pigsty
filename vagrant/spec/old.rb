# deb: pigsty 3-node legacy building environment templates:

Specs = [

  # EL 7/8/9
  { "name" => "el7",    "ip" => "10.10.10.7" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/centos7"        },
  { "name" => "d11",    "ip" => "10.10.10.11",  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/debian11"       },
  { "name" => "u20",    "ip" => "10.10.10.20",  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/ubuntu2004"     },

]
