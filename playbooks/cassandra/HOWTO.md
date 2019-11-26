# Cassandra

## Single Instance

To start one instance of Cassandra on an allocated storage node:

```shell
$ ssh nid000XX
$ module load sarus
$ sarus pull cassandra
$ export JAVA_HOME=
$ sarus run cassandra
```

## Distributed Server

To create a cluster of Cassandra instances, we need at least two storage nodes
and start the containers like described below.

On the "master" node:

```shell
$ ssh nid000XX
$ module load sarus
$ export JAVA_HOME=
$ export CASSANDRA_BROADCAST_ADDRESS="nid000XX"
$ export CASSANDRA_START_RPC=true
$ export LOCAL_JMX=no
$ sarus run --entrypoint
--mount=type=bind,bind-propagation=recursive,source=/mnt/nvme0n1/cassandra,destination=/var/lib/cassandra
cassandra bash -c 'echo "cassandra cassandra" > /etc/cassandra/jmxremote.password; docker-entrypoint.sh cassandra -f'
```

On the "slaves" nodes:

```shell
$ ssh nid000YY
$ module load sarus
$ export JAVA_HOME=
$ export CASSANDRA_BROADCAST_ADDRESS="nid000YY"
$ export CASSANDRA_SEEDS="nid000XX"
$ sarus run cassandra
```

## Client

To get the status of the Cassandra cluster, it is possible to use the
`nodetool` command available in the same container. From a node:

```shell
$ module load sarus
$ sarus run cassandra nodetool -pw cassandra -u cassandra -p 7199 -h nid000XX status
```
