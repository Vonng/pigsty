# pigsty production simulation spec with 45 nodes

Specs = [

  # admin & infra nodes
  { "name" => "meta-1"        , "ip" => "10.10.10.10"   , "cpu" => "8"    , "mem" => "32768"   , "image" =>  "generic/rocky8"  },
  { "name" => "meta-2"        , "ip" => "10.10.10.11"   , "cpu" => "8"    , "mem" => "32768"   , "image" =>  "generic/rocky8"  },

  # pg singleton cluster with different major versions
  { "name" => "pg-v12-1"      , "ip" => "10.10.10.12"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-v13-1"      , "ip" => "10.10.10.13"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-v14-1"      , "ip" => "10.10.10.14"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-v15-1"      , "ip" => "10.10.10.15"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-v16-1"      , "ip" => "10.10.10.16"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },

  # 5 x etcd (redis-sentinel),  3 x minio, 2 x haproxy
  { "name" => "etcd-1"        , "ip" => "10.10.10.21"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "etcd-2"        , "ip" => "10.10.10.22"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "etcd-3"        , "ip" => "10.10.10.23"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "etcd-4"        , "ip" => "10.10.10.24"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "etcd-5"        , "ip" => "10.10.10.25"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "minio-1"       , "ip" => "10.10.10.26"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "minio-2"       , "ip" => "10.10.10.27"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "minio-3"       , "ip" => "10.10.10.28"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "proxy-1"       , "ip" => "10.10.10.29"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "proxy-2"       , "ip" => "10.10.10.30"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },

  # 3 pg clusters: pg-test (4) , pg-src (3), pg-dst (2)
  { "name" => "pg-test-1"     , "ip" => "10.10.10.41"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-test-2"     , "ip" => "10.10.10.42"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-test-3"     , "ip" => "10.10.10.43"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-test-4"     , "ip" => "10.10.10.44"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-src-1"      , "ip" => "10.10.10.45"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-src-2"      , "ip" => "10.10.10.46"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-src-3"      , "ip" => "10.10.10.47"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-dst-1"      , "ip" => "10.10.10.48"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-dst-2"      , "ip" => "10.10.10.49"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },

  # 5 x 1p1s citus cluster
  { "name" => "pg-citus0-1"   , "ip" => "10.10.10.50"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-citus0-2"   , "ip" => "10.10.10.51"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-citus1-1"   , "ip" => "10.10.10.52"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-citus1-2"   , "ip" => "10.10.10.53"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-citus2-1"   , "ip" => "10.10.10.54"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-citus2-2"   , "ip" => "10.10.10.55"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-citus3-1"   , "ip" => "10.10.10.56"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-citus3-2"   , "ip" => "10.10.10.57"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-citus4-1"   , "ip" => "10.10.10.58"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "pg-citus4-2"   , "ip" => "10.10.10.59"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },

  # redis primary-replica(2) & native cluster(4)
  { "name" => "redis-test-1"  , "ip" => "10.10.10.81"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "redis-test-2"  , "ip" => "10.10.10.82"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "redis-test-3"  , "ip" => "10.10.10.83"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "redis-test-4"  , "ip" => "10.10.10.84"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "redis-test-5"  , "ip" => "10.10.10.85"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },
  { "name" => "redis-test-6"  , "ip" => "10.10.10.86"   , "cpu" => "1"    , "mem" => "2048"    , "image" =>  "generic/rocky8"  },

  # run client tools, misc
  { "name" => "test"          , "ip" => "10.10.10.88"   , "cpu" => "4"    , "mem" => "8192"    , "image" =>  "generic/rocky8"  },

]
