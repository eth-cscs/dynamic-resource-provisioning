#!ENV/bin/python

activate_this = "/users/ftessier/dynamic-resource-provisioning/ENV/bin/activate_this.py"
execfile(activate_this, dict(__file__=activate_this))

import os
import sys
import io
import subprocess
import hostlist
import yaml

# Global variables
target   = 'targets/dom/storage_nodes.yml'
section  = 'storage_nodes'
playbook = 'playbooks/beegfs/start_beegfs_servers.yml'

def main (argv):
    global section
    try:
        scheduler_nodelist = os.environ['SLURM_JOB_NODELIST']
        #scheduler_nodelist = 'nid000[52-53]'
    except KeyError:
        print ("[ERR] SLURM_JOB_NODELIST environment variable does not exist.")
        
    nodes_list = hostlist.expand_hostlist (scheduler_nodelist)

    # Load inventory file
    if not os.path.exists (target):
        print ('[ERR] Cannot find this inventory: '+target)
        sys.exit()

    inventory_stream = open (target, 'r')
    inventory = yaml.safe_load (inventory_stream)
    inventory_stream.close ()

    for node, v in inventory['all']['children']['storage_nodes']['hosts'].items():
        del inventory['all']['children']['storage_nodes']['hosts'][node]

    for node in nodes_list:
        inventory['all']['children']['storage_nodes']['hosts'][node] = None
        
    with io.open(target, 'w', encoding='utf8') as inventory_stream:
        yaml.dump(inventory, inventory_stream, default_flow_style=False, allow_unicode=True)
    inventory_stream.close ()

    print ("[INFO] New inventory file generated with "+str(len(nodes_list))+" hosts in the "+section+" section")

    # Run Ansible Playbook
    p = subprocess.Popen (['ansible-playbook',
                           '-i', target,
                           playbook])
    
if __name__ == "__main__":
    main (sys.argv[1:])
