#!ENV/bin/python3

import os
import sys
import subprocess

class DSRPPlaybook (object):

    def __init__(self, playbook_file):
        super().__init__()

        if playbook_file is None or '':
            self._playbook = None
        else:
            if not os.path.exists (playbook_file):
                print (__file__+': error: Playbook does not exist! ('+inventory_file+')')
                sys.exit (2)
            self._playbook = playbook_file
        self._target = ''

            
    def get_playbook_file (self):
        return self._playbook


    def run_playbook (self, target):
        self._target = target
        p = subprocess.Popen (['ansible-playbook',
                               '-i', self._target,
                                self._playbook])
        p.wait ()

