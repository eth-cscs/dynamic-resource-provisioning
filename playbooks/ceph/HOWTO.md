# Ceph

## Ceph Object Storage

Deploying a Ceph Object Storage consists in starting several
[daemons](https://docs.ceph.com/docs/master/start/intro/): a Ceph Monitor
(_ceph-mon_), a Ceph Manager (_ceph-mgr_) and an object storage daemon
(_ceph-osd_). To run a containerized version of those services, we will use
the official [ceph/daemon](https://hub.docker.com/r/ceph/daemon) container. 

```shell
$ module load sarus
$ sarus pull ceph/daemon
```


