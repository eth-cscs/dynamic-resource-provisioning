#!ENV/bin/python3

import os
import io
import yaml
import hostlist

class DSRPInventory (object):

    def __init__(self):
        super().__init__()
        self._inventory_file = ''
        self._inventory_content = dict ()
        self._inventory_job_file = ''

        
    def load_inventory (self, root_dir, system, filename):
        inventory_file = root_dir+'/targets/'+system+'/'+filename

        if not os.path.exists (inventory_file):
            print (__file__+': error: Inventory file does not exist! ('+inventory_file+')')
            sys.exit (2)

        self._inventory_file = inventory_file
        stream = open (self._inventory_file, 'r')
        self._inventory_content = yaml.safe_load (stream)
        stream.close ()

    
    def get_inventory_file (self):
        return self._inventory_file

    
    def get_inventory_content (self):
        return self._inventory_content

    
    def set_storage_nodelist (self, nodelist):
        nodelist_expanded = hostlist.expand_hostlist (nodelist)
        self._inventory_content['all']['children']['storage_nodes']['hosts'].clear ()

        for node in nodelist_expanded:
            self._inventory_content['all']['children']['storage_nodes']['hosts'][node] = None


    def write_job_inventory (self):
        self._inventory_job_file = os.path.dirname(self._inventory_file)+'/job_inventory.yml'
        
        if self._inventory_file == self._inventory_job_file:
            print (__file__+': error: Cannot overwrite inventory file!')
            sys.exit (1)
            
        with io.open (self._inventory_job_file, 'w', encoding='utf8') as inventory_job_stream:
            yaml.dump(self._inventory_content, inventory_job_stream, default_flow_style=False, allow_unicode=True)
            
        inventory_job_stream.close ()    
        
