#!ENV/bin/python

import os

dsrp_root_dir = os.path.dirname(os.path.realpath(__file__))
activate_this = dsrp_root_dir+"/ENV/bin/activate_this.py"
execfile(activate_this, dict(__file__=activate_this))

import sys
import io
import argparse
import subprocess
import hostlist
import yaml

def parse_dsrp_config (dsrp_config_file):
    dsrp_config_stream = open (dsrp_config_file, 'r')
    dsrp_config = yaml.safe_load (dsrp_config_stream)
    dsrp_config_stream.close ()
    return dsrp_config


def parse_args ():
    dsrp_config = None
    parser = argparse.ArgumentParser ()
    parser.add_argument ("dsrp_config", help="Path of file containing DSRP configuration")
    args = parser.parse_args()
    if args.dsrp_config:
        if not os.path.exists (args.dsrp_config):
            print (__file__+': error: DSRP configuration file does not exist!')
            sys.exit()
        dsrp_config = parse_dsrp_config (args.dsrp_config)
        
    return dsrp_config


def get_env_var (env_var_name):
    try:
        env_var = os.environ[env_var_name]
    except KeyError:
        print ("[ERR] "+env_var_name+" environment variable does not exist.")
        sys.exit()
    return env_var


def read_inventory_file (inventory_file):
    if not os.path.exists (inventory_file):
        print ('[ERR] Cannot find this inventory: '+inventory_file)
        sys.exit()

    inventory_stream = open (inventory_file, 'r')
    inventory = yaml.safe_load (inventory_stream)
    inventory_stream.close ()

    return inventory


def set_storage_inventory (dsrp_config, inventory):
    scheduler_nodelist = get_env_var (dsrp_config['resources']['storage_nodes']['scheduler_nodelist_env'])
    storage_nodelist   = hostlist.expand_hostlist (scheduler_nodelist)

    for node, v in inventory['all']['children']['storage_nodes']['hosts'].items():
        del inventory['all']['children']['storage_nodes']['hosts'][node]

    for node in storage_nodelist:
        inventory['all']['children']['storage_nodes']['hosts'][node] = None

    return inventory

        
def main (argv):
    global dsrp_root_dir
    dsrp_config = parse_args ()

    inventory_file = (dsrp_root_dir+'/targets/'+
                      dsrp_config['resources']['system']+'/'+
                      dsrp_config['resources']['inventory_file'])
                     
    inventory = read_inventory_file (inventory_file)
    inventory = set_storage_inventory (dsrp_config, inventory)
        
    # Load inventory file
    
    job_nodelist_file = os.path.dirname(inventory_file)+'/job_nodelist.yml'
    
    with io.open(job_nodelist_file, 'w', encoding='utf8') as job_nodelist_stream:
        yaml.dump(inventory, job_nodelist_stream, default_flow_style=False, allow_unicode=True)
    job_nodelist_stream.close ()

    # print ("[INFO] New inventory file generated with "+str(len(nodes_list))+" hosts in the storage_nodes section")

    # # Run Ansible Playbook
    # # p = subprocess.Popen (['ansible-playbook',
    # #                        '-i', target,
    # #                        playbook])
    
if __name__ == "__main__":
    main (sys.argv[1:])
