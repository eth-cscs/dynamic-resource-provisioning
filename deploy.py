#!ENV/bin/python

import os
import sys
import subprocess
import hostlist
import configparser
from ansible.parsing.dataloader import DataLoader
from ansible.inventory.manager import InventoryManager
from ansible.vars.manager import VariableManager
from ansible.executor.playbook_executor import PlaybookExecutor

# Global variables
target   = 'targets/dom/storage_nodes.ini'
section  = 'storage_nodes'
playbook = 'playbooks/beegfs/beegfs_server.yml'

def empty_section (config, section):
    config.remove_section (section)
    config.add_section (section)
    return config

def main (argv):
    global section
    scheduler_nodelist = 'nid000[52-53]'
    # scheduler_nodelist = os.environ['SLURM_JOB_NODELIST']
    nodes_list = hostlist.expand_hostlist (scheduler_nodelist)

    config = configparser.ConfigParser (allow_no_value=True)
    if not os.path.exists (target):
        print ('[ERR] Cannot find this inventory: '+target)
        sys.exit()    
    
    config_file = open (target)
    config.read_file (config_file)
    config_file.close ()
    config = empty_section (config, section)

    for node in nodes_list:
        config.set (section, node)

    config_file = open (target, 'w')
    config.write (config_file, space_around_delimiters=False)
    config_file.close

    print ("[INFO] New inventory file generated with "+str(len(nodes_list))+" hosts in the "+section+" section")

    # Run Ansible Playbook
    p = subprocess.Popen (['ansible-playbook',
                           '-i', target,
                           playbook])
    
if __name__ == "__main__":
    main (sys.argv[1:])


# Run Ansible Playbook
# loader       = DataLoader ()
# inventory    = InventoryManager (loader=loader, sources=target)
# variable_mgr = VariableManager (loader=loader, inventory=inventory)

# if not os.path.exists (playbook):
#     print ('[ERR] Cannot find this playbook: '+playbook)
#     sys.exit()

# executor = PlaybookExecutor (playbooks=[playbook],
#                              inventory=inventory,
#                              variable_manager=variable_mgr,
#                              loader=loader,
#                              passwords={})

# executor.run ()
