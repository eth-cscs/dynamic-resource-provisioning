#!ENV/bin/python3

import os
import yaml

class DSRPConfig (object):

    def __init__(self):
        super().__init__()
        self._config_file = ''
        self._config_content = dict ()

        
    def load_config (self, config_file):
        if not os.path.exists (config_file):
            print (__file__+': error: DSRP configuration file does not exist!')
            sys.exit (2)
        self._config_file = os.path.realpath(config_file)
        stream = open (self._config_file, 'r')
        self._config_content = yaml.safe_load (stream)
        stream.close ()

    
    def get_config_file (self):
        return self._config_file

    
    def get_config_content (self):
        return self._config_content


    def get_system (self):
        return self._config_content['resources']['system']

    
    def get_inventory_filename (self):
        return self._config_content['resources']['inventory_file']


    #######################
    # Storage nodes       #
    #######################
    def get_storage_sched_env_var (self):
        return self._config_content['resources']['storage_nodes']['scheduler_nodelist_env']


    #######################
    # Compute nodes       #
    #######################
    def get_storage_sched_env_var (self):
        return self._config_content['resources']['compute_nodes']['scheduler_nodelist_env']

    
