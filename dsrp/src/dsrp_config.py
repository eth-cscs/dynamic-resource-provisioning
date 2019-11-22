#!ENV/bin/python3

import os
import yaml
import sys

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

    
    #######################
    # DSRP                #
    #######################
    def get_dsrp_root_dir (self):
        return self._config_content['dsrp']['root_dir']
    
    
    #######################
    # Resources           #
    #######################
    def get_system (self):
        return self._config_content['resources']['system']

    
    def get_job_id_env_var (self):
        return self._config_content['resources']['job_id_env']
        
        
    def get_inventory_filename (self):
        return self._config_content['resources']['inventory_file']

    
    # Storage nodes
    #######################
    def get_storage_sched_env_var (self):
        return self._config_content['resources']['storage_nodes']['scheduler_nodelist_env']



    # Compute nodes
    #######################
    def get_compute_sched_env_var (self):
        return self._config_content['resources']['compute_nodes']['scheduler_nodelist_env']

    
    #######################
    # Data Manager        #
    #######################
    def get_data_manager (self):
        return self._config_content['data_manager']['type']


    def _playbook_root_dir (self):
        return (self.get_dsrp_root_dir()+
                '/playbooks/'+
                self.get_data_manager()+'/')

    
    # Servers
    #######################
    def get_dm_server_start_file (self):
        if 'start' in self._config_content['data_manager']['server']:
            if not self._config_content['data_manager']['server']['start']:
                return None
            else:
                return (self._playbook_root_dir()+
                        self._config_content['data_manager']['server']['start'])
        return None
    
    
    def get_dm_server_stop_file (self):
        if 'stop' in self._config_content['data_manager']['server']:
            if not self._config_content['data_manager']['server']['stop']:
                return None
            else:
                return (self._playbook_root_dir()+
                        self._config_content['data_manager']['server']['stop'])
        return None


    # Clients
    #######################
    def get_dm_client_start_file (self):
        if 'start' in self._config_content['data_manager']['client']:
            if not self._config_content['data_manager']['client']['start']:
                return None
            else:
                return (self._playbook_root_dir()+
                        self._config_content['data_manager']['client']['start'])
        return None

    
    def get_dm_client_stop_file (self):
        if 'stop' in self._config_content['data_manager']['client']:
            if not self._config_content['data_manager']['client']['stop']:
                return None
            else:
                return (self._playbook_root_dir()+
                        self._config_content['data_manager']['client']['stop'])
        return None
