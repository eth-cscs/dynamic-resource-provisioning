#!ENV/bin/python3

import os
import yaml
import sys
from src.dsrp_playbook import DSRPPlaybook

class DSRPDataManager (object):

    def __init__(self, dsrp_root_dir):
        super().__init__()
        self._dsrp_root_dir = dsrp_root_dir
        self._data_manager = ''
        self._config_file = ''
        self._config_content = dict ()
        self._playbooks = dict ()

        
    def load_config (self, data_manager):
        config_file = self._dsrp_root_dir+'/playbooks/'+data_manager+'/dsrp_config.yml'
        if not os.path.exists (config_file):
            print (__file__+': error: Data manager configuration file does not exist!')
            sys.exit (2)
        self._config_file = config_file
        self._data_manager = data_manager

        stream = open (self._config_file, 'r')
        self._config_content = yaml.safe_load (stream)
        stream.close ()

        self._playbooks['server'] = dict()
        self._playbooks['client'] = dict()
        
        try:
            self._playbooks['server']['start'] = DSRPPlaybook (self._playbook_root_dir() +
                                                               self._config_content['data_manager']['server']['start'])
        except (KeyError, TypeError):
            print (__file__+": error: No playbook set for starting the services. This playbook is mandatory.")
            sys.exit (2)
            
        try:
            self._playbooks['server']['stop'] = DSRPPlaybook (self._playbook_root_dir() +
                                                              self._config_content['data_manager']['server']['stop'])
        except (KeyError, TypeError):
            print (__file__+": error: No playbook set for stopping the services. This playbook is mandatory.")
            sys.exit (2)

        try:
            self._playbooks['client']['start'] = DSRPPlaybook (self._playbook_root_dir() +
                                                               self._config_content['data_manager']['client']['start'])
        except (KeyError, TypeError):
            print (__file__+": info: No playbook set for starting the clients.")

        try:
            self._playbooks['client']['stop'] = DSRPPlaybook (self._playbook_root_dir() +
                                                              self._config_content['data_manager']['client']['stop'])
        except (KeyError, TypeError):
            print (__file__+": info: No playbook set for stopping the clients.")


    
    def get_config_file (self):
        return self._config_file

    
    def get_config_content (self):
        return self._config_content

    
    #######################
    # Data Manager        #
    #######################
    def get_data_manager (self):
        return self._data_manager


    def _playbook_root_dir (self):
        return os.path.dirname(self._config_file)+'/'

    
    # Servers
    #######################
    def start_servers (self, inventory):
        self._playbooks['server']['start'].run_playbook (inventory)

    def stop_servers (self, inventory):
        self._playbooks['server']['stop'].run_playbook (inventory)

    # Clients
    #######################
    def start_clients (self, inventory):
        try:
            self._playbooks['client']['start'].run_playbook (inventory)
        except KeyError:
            print (__file__+": info: No client-side service to start.")

    def stop_clients (self, inventory):
        try:
            self._playbooks['client']['stop'].run_playbook (inventory)
        except KeyError:
            print (__file__+": info: No client-side service to stop.")
