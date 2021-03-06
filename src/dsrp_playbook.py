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
                print (__file__+': error: Playbook does not exist! ('+playbook_file+')')
                sys.exit (2)
            self._playbook = playbook_file
        self._target = ''
        self._extra_vars = ''

            
    def get_playbook_file (self):
        return self._playbook


    def run_playbook (self, target, extra_vars = ''):
        self._target = target
        self._extra_vars = extra_vars
        p = subprocess.Popen (['ansible-playbook',
                               '-i', self._target,
                                self._playbook,
                               '-e', self._extra_vars])
        p.wait ()

