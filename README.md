# Ansible-powered Dynamic Storage Resource Provisioning (DSRP)

It is common for HPC systems to provide dynamic access to compute nodes
through a batch scheduler. However, little has been done for dynamically
provisioned storage resources. Such resources are traditionally shared among
all users. A dynamic provisioning mechanism allows to allocate dedicated
resources to an application or a workflow and deploy an appropriate data
manager on top of it.

We introduce here an [Ansible](https://www.ansible.com/)-powered dynamic storage resource provisioning
(DSRP) mechanism that can use intermediate storage to set up on-demand a data
manager like, for instance, a parallel file system, an object store or a
database. As Ansible has been designed for flexible deployment of services, 
we use this software to manager clients and servers of the requested data
manager. A job-scheduler-agnostic script associated with a configuration file
describing how to use the storage resources is in charge of the deployment
process. To minimize the footprint on the target resources (privileges), all
the data managers we support are containerized and launched with a container
engine for HPC systems. The figure below presents the general functioning of
DSRP.

![DSRP](docs/img/DSRP.png)

## Requirements

### Install Ansible and python packages without root acccess

DSRP requires a quite recent version of Ansible installed on the HPC system's
login nodes. In case your version of Ansible is too old (<2.x.x), it is
necessary to set up a virtual environment and install all the Python packages
required for DSRP. While being in the DSRP root directory, you can proceed like this:

``` shell
pip install --user virtualenv
mkdir ENV
virtualenv -p python3 ENV
source ./ENV/bin/activate
pip install ansible python-hostlist
```

Now, a call to `ansible --version` should show a more recent release of the
automation tool (on Nov. 19th 2019: v. 2.9.1). Please keep in mind that in
case you need to run things manually using this virtual environment, a call to
`source ./ENV/bin/activate` is necessary for each newly open session.

The script in charge of deploying the configured data manager across the
storage resources dynamically loads this virtual environment.

## Using DSRP

### Heterogenous allocation


SLURM can do that (https://slurm.schedmd.com/heterogeneous_jobs.html). The
following examples will use SLURM to illustrate how to use DSRP.

For an interactive session:

``` shel
salloc -N2 -C mc -t 02:00:00 : -N2 -C storage
```

An example using a batch script will follow.

``` shell
#!/bin/bash

# sbatch -N1 -n1 -C mc : -N1 -n1 -C gpu ./dyn_pro.sh

deploy start config
#srun --label --pack-group=0 hostname && date +%s.%N && sleep 30
#srun --label --pack-group=1 hostname && date +%s.%N && sleep 120
deploy stop config
```

### DSRP configuration file

It is the heart of our tool. An example using a small-scale development
platform based on Piz Daint, our XC50 supercomputer, and BeeGFS, a parallel
file system, as a data manager is shown below:

``` yaml
dsrp:
  root_dir: /users/ftessier/dynamic-resource-provisioning
resources:
  system: dom
  job_id_env: SLURM_JOB_ID
  inventory_file: inventory.yml
  compute_nodes:
    scheduler_nodelist_env: SLURM_NODELIST_PACK_GROUP_0
  storage_nodes:
    scheduler_nodelist_env: SLURM_NODELIST_PACK_GROUP_1
    disks_per_node: 3
data_manager:
  type: beegfs
  server:
    start: start_beegfs_servers.yml
    stop: stop_beegfs_servers.yml
  client:
    start: mount_beegfs_clients.yml
    stop: umount_beegfs_clients.yml
```

### Starting servers and clients

``` shell
usage: dsrp_deploy.py [-h] {start,stop} config_file

positional arguments:
  {start,stop}  Start or stop the configured data manager
  config_file   Path of file containing DSRP configuration

optional arguments:
  -h, --help    show this help message and exit
```

### Running an application

Here is an example using IOR, the I/O benchmark suite:

``` shell
srun -N 2 -n8 src/ior -a MPIIO -t 1m -i 5 -b 1g -o $HOME/beegfs/test_8g
```

Please note that, by default, SLURM runs the application on the first pack
(index 0) of the allocated nodes. Thus, it shouldn't be necessary to
explicitely set the node list using the `SLURM_NODELIST_PACK_GROUP_0`
environment variable. 
