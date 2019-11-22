#!ENV/bin/python3

import os

dsrp_root_dir = os.path.dirname(os.path.realpath(__file__))
activate_this = dsrp_root_dir+"/ENV/bin/activate_this.py"
exec(open(activate_this, 'r').read(), dict(__file__=activate_this))

import sys
import argparse
from dsrp.src.common import get_env_var
from dsrp.src.dsrp_config import DSRPConfig
from dsrp.src.dsrp_inventory import DSRPInventory
from dsrp.src.dsrp_playbook import DSRPPlaybook

dsrp_config = DSRPConfig ()

def parse_args ():
    global dsrp_config
    parser = argparse.ArgumentParser ()
    parser.add_argument ("command", choices=['start', 'stop'], help="Start or stop the configured data manager")
    parser.add_argument ("config_file", help="Path of file containing DSRP configuration")
    args = parser.parse_args ()
    if args.config_file:
        dsrp_config.load_config (args.config_file)

    return args.command
    
    
def main (argv):
    global dsrp_config
    command = parse_args ()
    job_id = get_env_var (dsrp_config.get_job_id_env_var ())
    dsrp_inventory = DSRPInventory (dsrp_config.get_dsrp_root_dir (),
                                    dsrp_config.get_system (),
                                    dsrp_config.get_inventory_filename (),
                                    job_id)
    
    if command == "start":
        #######################
        # Storage nodes       #
        #######################
        storage_nodelist = get_env_var (dsrp_config.get_storage_sched_env_var ())
        dsrp_inventory.set_storage_nodelist (storage_nodelist)

        #######################
        # Compute nodes       #
        #######################
        compute_nodelist = get_env_var (dsrp_config.get_compute_sched_env_var ())
        dsrp_inventory.set_compute_nodelist (compute_nodelist)
        
        job_inventory = dsrp_inventory.write_job_inventory (job_id)

        # Servers
        if dsrp_config.get_dm_server_start_file ():
            server_playbook = DSRPPlaybook (dsrp_config.get_dm_server_start_file ())
            server_playbook.run_playbook (job_inventory)
        else:
            print (__file__+': error: No playbook set for starting the servers!')
            sys.exit (2)

        # Clients
        if dsrp_config.get_dm_client_start_file ():
            client_playbook = DSRPPlaybook (dsrp_config.get_dm_client_start_file ())
            client_playbook.run_playbook (job_inventory)
        else:
            print (__file__+': warning: No playbook set for starting the clients.')

    else:
        job_inventory = dsrp_inventory.get_job_inventory_file ()
        if not os.path.exists (job_inventory):
            print (__file__+': error: Inventory file does not exist! ('+
                   dsrp_inventory.get_job_inventory_file ()+')')
            sys.exit (2)

        # Servers
        if dsrp_config.get_dm_server_stop_file ():
            server_playbook = DSRPPlaybook (dsrp_config.get_dm_server_stop_file ())
            server_playbook.run_playbook (job_inventory)
        else:
            print (__file__+': warning: No playbook set for stopping the servers.')

        # Clients
        if dsrp_config.get_dm_client_stop_file ():
            client_playbook = DSRPPlaybook (dsrp_config.get_dm_client_stop_file ())
            client_playbook.run_playbook (job_inventory)
        else:
            print (__file__+': warning: No playbook set for stopping the clients.')
        
    
if __name__ == "__main__":
    main (sys.argv[1:])
