# ETCD



## Parameters

There are 10 parameters about [`ETCD`](PARAM#etcd) module.

| Parameter                                                  | Type   | Level| Comment                                            |
| ---------------------------------------------------------- |:------:|:----:| -------------------------------------------------- |
| [`etcd_seq`](PARAM#etcd_seq)                               | int    | I     | etcd instance identifier, REQUIRED           |
| [`etcd_cluster`](PARAM#etcd_cluster)                       | string | C     | etcd cluster & group name, etcd by default   |
| [`etcd_safeguard`](PARAM#etcd_safeguard)                   | bool   | G/C/A | prevent purging running etcd instance?       |
| [`etcd_clean`](PARAM#etcd_clean)                           | bool   | G/C/A | purging existing etcd during initialization? |
| [`etcd_data`](PARAM#etcd_data)                             | path   | C     | etcd data directory, /data/etcd by default   |
| [`etcd_port`](PARAM#etcd_port)                             | port   | C     | etcd client port, 2379 by default            |
| [`etcd_peer_port`](PARAM#etcd_peer_port)                   | port   | C     | etcd peer port, 2380 by default              |
| [`etcd_init`](PARAM#etcd_init)                             | enum   | C     | etcd initial cluster state, new or existing  |
| [`etcd_election_timeout`](PARAM#etcd_election_timeout)     | int    | C     | etcd election timeout, 1000ms by default     |
| [`etcd_heartbeat_interval`](PARAM#etcd_heartbeat_interval) | int    | C     | etcd heartbeat interval, 100ms by default    |
