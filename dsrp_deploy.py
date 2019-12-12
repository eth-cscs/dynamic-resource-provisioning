#!/usr/bin/env python3

import os

dsrp_root_dir = os.path.dirname(os.path.realpath(__file__))
activate_this = dsrp_root_dir+"/ENV/bin/activate_this.py"
exec(open(activate_this, 'r').read(), dict(__file__=activate_this))

import sys
import argparse
from dsrp.src.common import get_env_var
from dsrp.src.dsrp_data_manager import DSRPDataManager
from dsrp.src.dsrp_inventory import DSRPInventory

dsrp_data_manager = DSRPDataManager (dsrp_root_dir)

def parse_args ():
    global dsrp_data_manager
    parser = argparse.ArgumentParser ()
    parser.add_argument ("command", choices=['start', 'stop'], help="Start or stop the configured data manager")
    parser.add_argument ("data_manager", choices=['beegfs', 'minio', 'cassandra'], help="Data manager")
    parser.add_argument ('-s', '--storage-nodelist',
                         help="Storage nodelist for data manager deployment. Usually a job scheduler environment variable")
    parser.add_argument ('-c', '--compute-nodelist',
                         help="Compute nodelist for clients deployment, Usually a job scheduler environment variable")
    parser.add_argument ('-t', '--target', help="[DEBUG] Target architecture")
    args = parser.parse_args ()
    
    dsrp_data_manager.load_config (args.data_manager)

    return args.command
    
    
def main (argv):
    global dsrp_data_manager
    command = parse_args ()
    #dsrp_inventory = DSRPInventory ()
    
    # if command == "start":
    #     #######################
    #     # Storage nodes       #
    #     #######################
    #     storage_nodelist = get_env_var (dsrp_data_manager.get_storage_sched_env_var ())
    #     dsrp_inventory.set_storage_nodelist (storage_nodelist)

    #     #######################
    #     # Compute nodes       #
    #     #######################
    #     compute_nodelist = get_env_var (dsrp_data_manager.get_compute_sched_env_var ())
    #     dsrp_inventory.set_compute_nodelist (compute_nodelist)
        
    #     job_inventory = dsrp_inventory.write_job_inventory (job_id)

    #     # Servers
    #     if dsrp_data_manager.get_dm_server_start_file ():
    #         server_playbook = DSRPPlaybook (dsrp_data_manager.get_dm_server_start_file ())
    #         server_playbook.run_playbook (job_inventory)
    #     else:
    #         print (__file__+': error: No playbook set for starting the servers!')
    #         sys.exit (2)

    #     # Clients
    #     if dsrp_data_manager.get_dm_client_start_file ():
    #         client_playbook = DSRPPlaybook (dsrp_data_manager.get_dm_client_start_file ())
    #         client_playbook.run_playbook (job_inventory)
    #     else:
    #         print (__file__+': warning: No playbook set for starting the clients.')

    # else:
    #     job_inventory = dsrp_inventory.get_job_inventory_file ()
    #     if not os.path.exists (job_inventory):
    #         print (__file__+': error: Inventory file does not exist! ('+
    #                dsrp_inventory.get_job_inventory_file ()+')')
    #         sys.exit (2)

    #     # Servers
    #     if dsrp_data_manager.get_dm_server_stop_file ():
    #         server_playbook = DSRPPlaybook (dsrp_data_manager.get_dm_server_stop_file ())
    #         server_playbook.run_playbook (job_inventory)
    #     else:
    #         print (__file__+': warning: No playbook set for stopping the servers.')

    #     # Clients
    #     if dsrp_data_manager.get_dm_client_stop_file ():
    #         client_playbook = DSRPPlaybook (dsrp_data_manager.get_dm_client_stop_file ())
    #         client_playbook.run_playbook (job_inventory)
    #     else:
    #         print (__file__+': warning: No playbook set for stopping the clients.')
        
    
if __name__ == "__main__":
    main (sys.argv[1:])
