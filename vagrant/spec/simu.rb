# simu: pigsty complex 36-node simubox for production simulation & complete testing

Specs = [

  # 2 x infra nodes
  { "name" => "meta1"       , "ip" => "10.10.10.10" , "cpu" => "8" , "mem" => "32768" ,  "image" => "generic/rocky9"  },
  { "name" => "meta2"       , "ip" => "10.10.10.11" , "cpu" => "8" , "mem" => "32768" ,  "image" => "generic/rocky9"  },

  # 6 x pgsql ad hoc version singleton
  { "name" => "pg12"        , "ip" => "10.10.10.12" , "cpu" => "2" , "mem" => "4096"  ,  "image" => "generic/rocky9"  },
  { "name" => "pg13"        , "ip" => "10.10.10.13" , "cpu" => "2" , "mem" => "4096"  ,  "image" => "generic/rocky9"  },
  { "name" => "pg14"        , "ip" => "10.10.10.14" , "cpu" => "2" , "mem" => "4096"  ,  "image" => "generic/rocky9"  },
  { "name" => "pg15"        , "ip" => "10.10.10.15" , "cpu" => "2" , "mem" => "4096"  ,  "image" => "generic/rocky9"  },
  { "name" => "pg16"        , "ip" => "10.10.10.16" , "cpu" => "2" , "mem" => "4096"  ,  "image" => "generic/rocky9"  },
  { "name" => "pg17"        , "ip" => "10.10.10.17" , "cpu" => "2" , "mem" => "4096"  ,  "image" => "generic/rocky9"  },

  # 2 x haproxy (vip 10.10.10.20)
  { "name" => "proxy1"      , "ip" => "10.10.10.18" , "cpu" => "2" , "mem" => "4096"  ,  "image" => "generic/rocky9"  },
  { "name" => "proxy2"      , "ip" => "10.10.10.19" , "cpu" => "2" , "mem" => "4096"  ,  "image" => "generic/rocky9"  },

  # 5 x etcd + minio (+ redis sentinel)
  { "name" => "minio1"      , "ip" => "10.10.10.21" , "cpu" => "2" , "mem" => "4096"  ,  "image" => "generic/rocky9"  },
  { "name" => "minio2"      , "ip" => "10.10.10.22" , "cpu" => "2" , "mem" => "4096"  ,  "image" => "generic/rocky9"  },
  { "name" => "minio3"      , "ip" => "10.10.10.23" , "cpu" => "2" , "mem" => "4096"  ,  "image" => "generic/rocky9"  },
  { "name" => "minio4"      , "ip" => "10.10.10.24" , "cpu" => "2" , "mem" => "4096"  ,  "image" => "generic/rocky9"  },
  { "name" => "minio5"      , "ip" => "10.10.10.25" , "cpu" => "2" , "mem" => "4096"  ,  "image" => "generic/rocky9"  },

  # 20 pgsql / redis / citus nodes for any purpose
  { "name" => "node40"      , "ip" => "10.10.10.40" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node41"      , "ip" => "10.10.10.41" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node42"      , "ip" => "10.10.10.42" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node43"      , "ip" => "10.10.10.43" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node44"      , "ip" => "10.10.10.44" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node45"      , "ip" => "10.10.10.45" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node46"      , "ip" => "10.10.10.46" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node47"      , "ip" => "10.10.10.47" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node48"      , "ip" => "10.10.10.48" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node49"      , "ip" => "10.10.10.49" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node50"      , "ip" => "10.10.10.50" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node51"      , "ip" => "10.10.10.51" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node52"      , "ip" => "10.10.10.52" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node53"      , "ip" => "10.10.10.53" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node54"      , "ip" => "10.10.10.54" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node55"      , "ip" => "10.10.10.55" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node56"      , "ip" => "10.10.10.56" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node57"      , "ip" => "10.10.10.57" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node58"      , "ip" => "10.10.10.58" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },
  { "name" => "node59"      , "ip" => "10.10.10.59" , "cpu" => "1" , "mem" => "2048"  ,  "image" => "generic/rocky9"  },

  # 1 x test node
  { "name" => "test"        , "ip" => "10.10.10.88" , "cpu" => "4" , "mem" => "8192"  ,  "image" => "generic/rocky9"  },

]
