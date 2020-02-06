#!/usr/bin/env python3

import os

dsrp_root_dir = os.path.dirname(os.path.realpath(__file__))
activate_this = dsrp_root_dir+"/ENV/bin/activate_this.py"
exec(open(activate_this, 'r').read(), dict(__file__=activate_this))

import sys
import argparse
from src.common import get_env_var
from src.dsrp_data_manager import DSRPDataManager
from src.dsrp_inventory import DSRPInventory

dsrp_data_manager = DSRPDataManager (dsrp_root_dir)
dsrp_inventory = DSRPInventory (dsrp_root_dir)

def parse_args ():
    global dsrp_data_manager
    parser = argparse.ArgumentParser ()
    parser.add_argument ("command", choices=['start', 'stop'], help="Start or stop the configured data manager")
    parser.add_argument ("data_manager", choices=['beegfs', 'minio', 'cassandra'], help="Data manager")
    parser.add_argument ('-s', '--storage-nodelist',
                         help="Storage nodelist for data manager deployment. Usually a job scheduler environment variable")
    parser.add_argument ('-c', '--compute-nodelist',
                         help="Compute nodelist for clients deployment, Usually a job scheduler environment variable")
    parser.add_argument ('-i', '--stage-in', help="Location of staged-out data from a previously deployed data manager")
    parser.add_argument ('-o', '--stage-out', help="Location where the data is to be backed up for future use")
    parser.add_argument ('-t', '--target', help="[DEBUG] Target architecture")
    args = parser.parse_args ()

    if args.stage_in and args.command == "stop":
        parser.print_usage()
        print ('Error: argument --stage-in (-i) is not allowed with argument stop')
        sys.exit(1)

    if args.stage_out and args.command == "start":
        parser.print_usage()
        print ('Error: argument --stage-out (-o) is not allowed with argument start')
        sys.exit(1)
        
    dsrp_data_manager.load_config (args.data_manager)
    dsrp_inventory.load_inventory (args.target)
    
    if args.storage_nodelist:
        dsrp_inventory.set_storage_nodelist (args.storage_nodelist)
        
    if args.compute_nodelist:
        dsrp_inventory.set_compute_nodelist (args.compute_nodelist)
        
    dsrp_inventory.set_job_inventory()

    return args.command
    
    
def main (argv):
    global dsrp_data_manager
    command = parse_args ()
    
    # if command == "start":
    #     dsrp_data_manager.start_servers (dsrp_inventory.get_job_inventory_file())
    #     dsrp_data_manager.start_clients (dsrp_inventory.get_job_inventory_file())
    # else:
    #     dsrp_data_manager.stop_servers (dsrp_inventory.get_job_inventory_file())
    #     dsrp_data_manager.stop_clients (dsrp_inventory.get_job_inventory_file())

        
if __name__ == "__main__":
    main (sys.argv[1:])
