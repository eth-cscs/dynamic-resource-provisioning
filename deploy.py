#!/usr/bin/python

from ansible.parsing.dataloader import DataLoader
from ansible.inventory.manager import InventoryManager
from ansible.inventory.manager import InventoryData
from ansible.vars.manager import VariableManager

loader           = DataLoader ()
inventory        = InventoryManager (loader = loader, sources="storage_nodes.ini")
data             = inventory._inventory
nodes_list       = ['nid000GD', 'nid000HG', 'nid000fds', 'nid000rrew']
# nodes_list = hostlist.expand_hostlist(os.environ['SLURM_JOB_NODELIST'])

for h in inventory.get_hosts (pattern='nid*'):
    data.remove_host (h)

for n in nodes_list:
    data.add_host (n, group='storage_nodes')

    
