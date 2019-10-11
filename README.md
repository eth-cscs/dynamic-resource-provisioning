# Ansible-powered Dynamic Resource Provisioning

## Install Ansible without root acccess

Step 1: install `virtualenv` and create a new environment

``` shell
pip install --user virtualenv
mkdir ENV
virtualenv ENV
```

Step 2: install the latest version of `ansible` in the virtual environment

``` shell
source ./ENV/bin/activate
pip install ansible configparser python-hostlist
ansible --version # ansible 2.8.4 or later
```

Step 3: every time ansible has to be used, it is necessary to "load" the
virtual environment

``` shell
virtualenv ENV
source ./ENV/bin/activate
```

Step 4: list all available hosts declared

``` shell
ansible --list-hosts all
```

Steap 5: ping and/or run remote command over ssh on nodes

``` shell
ansible -m ping all
ansible-playbook playbooks/beegfs/beegfs-server.yml
```
