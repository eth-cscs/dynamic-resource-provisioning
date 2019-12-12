#!ENV/bin/python3

import os
import io
import sys
import yaml
import hostlist

class DSRPInventory (object):

    def __init__(self, root_dir, system, filename):
        super().__init__()
        inventory_file = root_dir+'/targets/'+system+'/'+filename
        
        if not os.path.exists (inventory_file):
            print (__file__+': error: Inventory file does not exist! ('+inventory_file+')')
            sys.exit (2)
            
        self._inventory_file = inventory_file
        stream = open (self._inventory_file, 'r')
        self._inventory_content = yaml.safe_load (stream)
        stream.close ()
        self.set_job_inventory_file ()
        
    
    def get_inventory_file (self):
        return self._inventory_file


    def set_job_inventory_file (self):
        self._inventory_job_file = os.path.dirname(self._inventory_file)+'/inventory_job.yml'
        
        
    def get_job_inventory_file (self):
        return self._inventory_job_file

    
    def get_inventory_content (self):
        return self._inventory_content

    
    def set_storage_nodelist (self, nodelist):
        nodelist_expanded = hostlist.expand_hostlist (nodelist)
        self._inventory_content['all']['children']['storage_nodes']['hosts'] = {}

        for node in nodelist_expanded:
            self._inventory_content['all']['children']['storage_nodes']['hosts'][node] = None

            
    def set_compute_nodelist (self, nodelist):
        nodelist_expanded = hostlist.expand_hostlist (nodelist)
        self._inventory_content['all']['children']['compute_nodes']['hosts'] = {}

        for node in nodelist_expanded:
            self._inventory_content['all']['children']['compute_nodes']['hosts'][node] = None


    def write_job_inventory (self):
        self.set_job_inventory_file ()
        
        if self._inventory_file == self._inventory_job_file:
            print (__file__+': error: Cannot overwrite inventory file!')
            sys.exit (1)
            
        with io.open (self._inventory_job_file, 'w', encoding='utf8') as inventory_job_stream:
            yaml.dump(self._inventory_content, inventory_job_stream, default_flow_style=False, allow_unicode=True)
            
        inventory_job_stream.close ()    
        return self._inventory_job_file
