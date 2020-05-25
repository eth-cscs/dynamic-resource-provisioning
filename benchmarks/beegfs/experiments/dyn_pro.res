
PLAY [storage_nodes] ***********************************************************

TASK [set_fact] ****************************************************************
ok: [nid00052]
ok: [nid00053]

TASK [set_fact] ****************************************************************
ok: [nid00052]
ok: [nid00053]

PLAY [storage_nodes] ***********************************************************

TASK [start_server : Start MinIO servers] **************************************
[WARNING]: Platform linux on host nid00052 is using the discovered Python
interpreter at /usr/bin/python, but future installation of another Python
interpreter could change this. See https://docs.ansible.com/ansible/2.9/referen
ce_appendices/interpreter_discovery.html for more information.
fatal: [nid00052]: FAILED! => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": true, "cmd": "module load sarus; nohup sarus run --entrypoint --mount=type=bind,bind-propagation=recursive,source=/mnt,destination=/mnt minio/minio /usr/bin/docker-entrypoint.sh server   http://nid00052/mnt/nvme0n1/MinIO  http://nid00053/mnt/nvme0n1/MinIO    http://nid00052/mnt/nvme1n1/MinIO  http://nid00053/mnt/nvme1n1/MinIO    http://nid00052/mnt/nvme2n1/MinIO  http://nid00053/mnt/nvme2n1/MinIO   </dev/null >/dev/null 2>&1 &;", "delta": "0:00:00.121700", "end": "2020-03-05 16:43:42.887004", "msg": "non-zero return code", "rc": 1, "start": "2020-03-05 16:43:42.765304", "stderr": "/bin/sh: -c: line 0: syntax error near unexpected token `;'\n/bin/sh: -c: line 0: `module load sarus; nohup sarus run --entrypoint --mount=type=bind,bind-propagation=recursive,source=/mnt,destination=/mnt minio/minio /usr/bin/docker-entrypoint.sh server   http://nid00052/mnt/nvme0n1/MinIO  http://nid00053/mnt/nvme0n1/MinIO    http://nid00052/mnt/nvme1n1/MinIO  http://nid00053/mnt/nvme1n1/MinIO    http://nid00052/mnt/nvme2n1/MinIO  http://nid00053/mnt/nvme2n1/MinIO   </dev/null >/dev/null 2>&1 &;'", "stderr_lines": ["/bin/sh: -c: line 0: syntax error near unexpected token `;'", "/bin/sh: -c: line 0: `module load sarus; nohup sarus run --entrypoint --mount=type=bind,bind-propagation=recursive,source=/mnt,destination=/mnt minio/minio /usr/bin/docker-entrypoint.sh server   http://nid00052/mnt/nvme0n1/MinIO  http://nid00053/mnt/nvme0n1/MinIO    http://nid00052/mnt/nvme1n1/MinIO  http://nid00053/mnt/nvme1n1/MinIO    http://nid00052/mnt/nvme2n1/MinIO  http://nid00053/mnt/nvme2n1/MinIO   </dev/null >/dev/null 2>&1 &;'"], "stdout": "", "stdout_lines": []}
[WARNING]: Platform linux on host nid00053 is using the discovered Python
interpreter at /usr/bin/python, but future installation of another Python
interpreter could change this. See https://docs.ansible.com/ansible/2.9/referen
ce_appendices/interpreter_discovery.html for more information.
fatal: [nid00053]: FAILED! => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": true, "cmd": "module load sarus; nohup sarus run --entrypoint --mount=type=bind,bind-propagation=recursive,source=/mnt,destination=/mnt minio/minio /usr/bin/docker-entrypoint.sh server   http://nid00052/mnt/nvme0n1/MinIO  http://nid00053/mnt/nvme0n1/MinIO    http://nid00052/mnt/nvme1n1/MinIO  http://nid00053/mnt/nvme1n1/MinIO    http://nid00052/mnt/nvme2n1/MinIO  http://nid00053/mnt/nvme2n1/MinIO   </dev/null >/dev/null 2>&1 &;", "delta": "0:00:00.120648", "end": "2020-03-05 16:43:42.914940", "msg": "non-zero return code", "rc": 1, "start": "2020-03-05 16:43:42.794292", "stderr": "/bin/sh: -c: line 0: syntax error near unexpected token `;'\n/bin/sh: -c: line 0: `module load sarus; nohup sarus run --entrypoint --mount=type=bind,bind-propagation=recursive,source=/mnt,destination=/mnt minio/minio /usr/bin/docker-entrypoint.sh server   http://nid00052/mnt/nvme0n1/MinIO  http://nid00053/mnt/nvme0n1/MinIO    http://nid00052/mnt/nvme1n1/MinIO  http://nid00053/mnt/nvme1n1/MinIO    http://nid00052/mnt/nvme2n1/MinIO  http://nid00053/mnt/nvme2n1/MinIO   </dev/null >/dev/null 2>&1 &;'", "stderr_lines": ["/bin/sh: -c: line 0: syntax error near unexpected token `;'", "/bin/sh: -c: line 0: `module load sarus; nohup sarus run --entrypoint --mount=type=bind,bind-propagation=recursive,source=/mnt,destination=/mnt minio/minio /usr/bin/docker-entrypoint.sh server   http://nid00052/mnt/nvme0n1/MinIO  http://nid00053/mnt/nvme0n1/MinIO    http://nid00052/mnt/nvme1n1/MinIO  http://nid00053/mnt/nvme1n1/MinIO    http://nid00052/mnt/nvme2n1/MinIO  http://nid00053/mnt/nvme2n1/MinIO   </dev/null >/dev/null 2>&1 &;'"], "stdout": "", "stdout_lines": []}

PLAY RECAP *********************************************************************
nid00052                   : ok=2    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
nid00053                   : ok=2    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

/users/ftessier/dynamic-resource-provisioning/src/dsrp_data_manager.py: info: No playbook set for starting the clients.
/users/ftessier/dynamic-resource-provisioning/src/dsrp_data_manager.py: info: No playbook set for stopping the clients.
/users/ftessier/dynamic-resource-provisioning/src/dsrp_data_manager.py: info: No client-side service to start.

PLAY [storage_nodes] ***********************************************************

TASK [set_fact] ****************************************************************
ok: [nid00052]
ok: [nid00053]

TASK [set_fact] ****************************************************************
ok: [nid00052]
ok: [nid00053]

PLAY [storage_nodes[0]] ********************************************************

TASK [stop_server : Stop MinIO servers] ****************************************
[WARNING]: Platform linux on host nid00052 is using the discovered Python
interpreter at /usr/bin/python, but future installation of another Python
interpreter could change this. See https://docs.ansible.com/ansible/2.9/referen
ce_appendices/interpreter_discovery.html for more information.
fatal: [nid00052]: FAILED! => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": true, "cmd": "module load sarus; sarus run --entrypoint --mount=type=bind,bind-propagation=recursive,source=/mnt,destination=/mnt minio/mc /bin/sh -c 'mc config host add minio http://nid00052:9000 IiaFsQIpRM gQbENgqvagxFt59j4U46m4dwL83kBQmf; mc admin service stop minio'", "delta": "0:00:00.171365", "end": "2020-03-05 16:46:53.360127", "msg": "non-zero return code", "rc": 1, "start": "2020-03-05 16:46:53.188762", "stderr": "[1838345.183501285] [nid00052-22945] [CLI] [WARN] WARNING: bind-propagation will be removed from mount options in a future Sarus release. In the future, all bind-mounts will be performed as rprivate.\nSpecified image index.docker.io/minio/mc:latest is not available", "stderr_lines": ["[1838345.183501285] [nid00052-22945] [CLI] [WARN] WARNING: bind-propagation will be removed from mount options in a future Sarus release. In the future, all bind-mounts will be performed as rprivate.", "Specified image index.docker.io/minio/mc:latest is not available"], "stdout": "", "stdout_lines": []}

PLAY RECAP *********************************************************************
nid00052                   : ok=2    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
nid00053                   : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


PLAY [storage_nodes] ***********************************************************

TASK [Clean up disks] **********************************************************
changed: [nid00052] => (item={'model': 'MZPLL6T4HMLS-00003', 'mount_point': '/mnt/nvme0n1', 'name': 'nvme0n1', 'size': '5.9T', 'vendor': 'SAMSUNG'})
changed: [nid00053] => (item={'model': 'MZPLL6T4HMLS-00003', 'mount_point': '/mnt/nvme0n1', 'name': 'nvme0n1', 'size': '5.9T', 'vendor': 'SAMSUNG'})
changed: [nid00052] => (item={'model': 'MZPLL6T4HMLS-00003', 'mount_point': '/mnt/nvme1n1', 'name': 'nvme1n1', 'size': '5.9T', 'vendor': 'SAMSUNG'})
changed: [nid00053] => (item={'model': 'MZPLL6T4HMLS-00003', 'mount_point': '/mnt/nvme1n1', 'name': 'nvme1n1', 'size': '5.9T', 'vendor': 'SAMSUNG'})
changed: [nid00053] => (item={'model': 'MZPLL6T4HMLS-00003', 'mount_point': '/mnt/nvme2n1', 'name': 'nvme2n1', 'size': '5.9T', 'vendor': 'SAMSUNG'})
[WARNING]: Consider using the file module with state=absent rather than running
'rm'.  If you need to use command because file is insufficient you can add
'warn: false' to this command task or set 'command_warnings=False' in
ansible.cfg to get rid of this message.
[WARNING]: Platform linux on host nid00053 is using the discovered Python
interpreter at /usr/bin/python, but future installation of another Python
interpreter could change this. See https://docs.ansible.com/ansible/2.9/referen
ce_appendices/interpreter_discovery.html for more information.
changed: [nid00052] => (item={'model': 'MZPLL6T4HMLS-00003', 'mount_point': '/mnt/nvme2n1', 'name': 'nvme2n1', 'size': '5.9T', 'vendor': 'SAMSUNG'})
[WARNING]: Platform linux on host nid00052 is using the discovered Python
interpreter at /usr/bin/python, but future installation of another Python
interpreter could change this. See https://docs.ansible.com/ansible/2.9/referen
ce_appendices/interpreter_discovery.html for more information.

TASK [debug] *******************************************************************
ok: [nid00052] => {
    "output.results": [
        {
            "ansible_facts": {
                "discovered_interpreter_python": "/usr/bin/python"
            },
            "ansible_loop": {
                "allitems": [
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme0n1",
                        "name": "nvme0n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    },
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme1n1",
                        "name": "nvme1n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    },
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme2n1",
                        "name": "nvme2n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    }
                ],
                "first": true,
                "index": 1,
                "index0": 0,
                "last": false,
                "length": 3,
                "nextitem": {
                    "model": "MZPLL6T4HMLS-00003",
                    "mount_point": "/mnt/nvme1n1",
                    "name": "nvme1n1",
                    "size": "5.9T",
                    "vendor": "SAMSUNG"
                },
                "revindex": 3,
                "revindex0": 2
            },
            "ansible_loop_var": "item",
            "changed": true,
            "cmd": "/bin/rm -rf /mnt/nvme0n1/*",
            "delta": "0:00:00.121581",
            "end": "2020-03-05 16:47:03.500894",
            "failed": false,
            "invocation": {
                "module_args": {
                    "_raw_params": "/bin/rm -rf /mnt/nvme0n1/*",
                    "_uses_shell": true,
                    "argv": null,
                    "chdir": null,
                    "creates": null,
                    "executable": null,
                    "removes": null,
                    "stdin": null,
                    "stdin_add_newline": true,
                    "strip_empty_ends": true,
                    "warn": true
                }
            },
            "item": {
                "model": "MZPLL6T4HMLS-00003",
                "mount_point": "/mnt/nvme0n1",
                "name": "nvme0n1",
                "size": "5.9T",
                "vendor": "SAMSUNG"
            },
            "rc": 0,
            "start": "2020-03-05 16:47:03.379313",
            "stderr": "",
            "stderr_lines": [],
            "stdout": "",
            "stdout_lines": []
        },
        {
            "ansible_loop": {
                "allitems": [
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme0n1",
                        "name": "nvme0n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    },
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme1n1",
                        "name": "nvme1n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    },
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme2n1",
                        "name": "nvme2n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    }
                ],
                "first": false,
                "index": 2,
                "index0": 1,
                "last": false,
                "length": 3,
                "nextitem": {
                    "model": "MZPLL6T4HMLS-00003",
                    "mount_point": "/mnt/nvme2n1",
                    "name": "nvme2n1",
                    "size": "5.9T",
                    "vendor": "SAMSUNG"
                },
                "previtem": {
                    "model": "MZPLL6T4HMLS-00003",
                    "mount_point": "/mnt/nvme0n1",
                    "name": "nvme0n1",
                    "size": "5.9T",
                    "vendor": "SAMSUNG"
                },
                "revindex": 2,
                "revindex0": 1
            },
            "ansible_loop_var": "item",
            "changed": true,
            "cmd": "/bin/rm -rf /mnt/nvme1n1/*",
            "delta": "0:00:00.122996",
            "end": "2020-03-05 16:47:08.451262",
            "failed": false,
            "invocation": {
                "module_args": {
                    "_raw_params": "/bin/rm -rf /mnt/nvme1n1/*",
                    "_uses_shell": true,
                    "argv": null,
                    "chdir": null,
                    "creates": null,
                    "executable": null,
                    "removes": null,
                    "stdin": null,
                    "stdin_add_newline": true,
                    "strip_empty_ends": true,
                    "warn": true
                }
            },
            "item": {
                "model": "MZPLL6T4HMLS-00003",
                "mount_point": "/mnt/nvme1n1",
                "name": "nvme1n1",
                "size": "5.9T",
                "vendor": "SAMSUNG"
            },
            "rc": 0,
            "start": "2020-03-05 16:47:08.328266",
            "stderr": "",
            "stderr_lines": [],
            "stdout": "",
            "stdout_lines": []
        },
        {
            "ansible_loop": {
                "allitems": [
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme0n1",
                        "name": "nvme0n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    },
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme1n1",
                        "name": "nvme1n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    },
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme2n1",
                        "name": "nvme2n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    }
                ],
                "first": false,
                "index": 3,
                "index0": 2,
                "last": true,
                "length": 3,
                "previtem": {
                    "model": "MZPLL6T4HMLS-00003",
                    "mount_point": "/mnt/nvme1n1",
                    "name": "nvme1n1",
                    "size": "5.9T",
                    "vendor": "SAMSUNG"
                },
                "revindex": 1,
                "revindex0": 0
            },
            "ansible_loop_var": "item",
            "changed": true,
            "cmd": "/bin/rm -rf /mnt/nvme2n1/*",
            "delta": "0:00:00.123002",
            "end": "2020-03-05 16:47:13.397122",
            "failed": false,
            "invocation": {
                "module_args": {
                    "_raw_params": "/bin/rm -rf /mnt/nvme2n1/*",
                    "_uses_shell": true,
                    "argv": null,
                    "chdir": null,
                    "creates": null,
                    "executable": null,
                    "removes": null,
                    "stdin": null,
                    "stdin_add_newline": true,
                    "strip_empty_ends": true,
                    "warn": true
                }
            },
            "item": {
                "model": "MZPLL6T4HMLS-00003",
                "mount_point": "/mnt/nvme2n1",
                "name": "nvme2n1",
                "size": "5.9T",
                "vendor": "SAMSUNG"
            },
            "rc": 0,
            "start": "2020-03-05 16:47:13.274120",
            "stderr": "",
            "stderr_lines": [],
            "stdout": "",
            "stdout_lines": []
        }
    ]
}
ok: [nid00053] => {
    "output.results": [
        {
            "ansible_facts": {
                "discovered_interpreter_python": "/usr/bin/python"
            },
            "ansible_loop": {
                "allitems": [
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme0n1",
                        "name": "nvme0n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    },
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme1n1",
                        "name": "nvme1n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    },
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme2n1",
                        "name": "nvme2n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    }
                ],
                "first": true,
                "index": 1,
                "index0": 0,
                "last": false,
                "length": 3,
                "nextitem": {
                    "model": "MZPLL6T4HMLS-00003",
                    "mount_point": "/mnt/nvme1n1",
                    "name": "nvme1n1",
                    "size": "5.9T",
                    "vendor": "SAMSUNG"
                },
                "revindex": 3,
                "revindex0": 2
            },
            "ansible_loop_var": "item",
            "changed": true,
            "cmd": "/bin/rm -rf /mnt/nvme0n1/*",
            "delta": "0:00:00.123181",
            "end": "2020-03-05 16:47:03.507265",
            "failed": false,
            "invocation": {
                "module_args": {
                    "_raw_params": "/bin/rm -rf /mnt/nvme0n1/*",
                    "_uses_shell": true,
                    "argv": null,
                    "chdir": null,
                    "creates": null,
                    "executable": null,
                    "removes": null,
                    "stdin": null,
                    "stdin_add_newline": true,
                    "strip_empty_ends": true,
                    "warn": true
                }
            },
            "item": {
                "model": "MZPLL6T4HMLS-00003",
                "mount_point": "/mnt/nvme0n1",
                "name": "nvme0n1",
                "size": "5.9T",
                "vendor": "SAMSUNG"
            },
            "rc": 0,
            "start": "2020-03-05 16:47:03.384084",
            "stderr": "",
            "stderr_lines": [],
            "stdout": "",
            "stdout_lines": []
        },
        {
            "ansible_loop": {
                "allitems": [
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme0n1",
                        "name": "nvme0n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    },
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme1n1",
                        "name": "nvme1n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    },
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme2n1",
                        "name": "nvme2n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    }
                ],
                "first": false,
                "index": 2,
                "index0": 1,
                "last": false,
                "length": 3,
                "nextitem": {
                    "model": "MZPLL6T4HMLS-00003",
                    "mount_point": "/mnt/nvme2n1",
                    "name": "nvme2n1",
                    "size": "5.9T",
                    "vendor": "SAMSUNG"
                },
                "previtem": {
                    "model": "MZPLL6T4HMLS-00003",
                    "mount_point": "/mnt/nvme0n1",
                    "name": "nvme0n1",
                    "size": "5.9T",
                    "vendor": "SAMSUNG"
                },
                "revindex": 2,
                "revindex0": 1
            },
            "ansible_loop_var": "item",
            "changed": true,
            "cmd": "/bin/rm -rf /mnt/nvme1n1/*",
            "delta": "0:00:00.122829",
            "end": "2020-03-05 16:47:08.454512",
            "failed": false,
            "invocation": {
                "module_args": {
                    "_raw_params": "/bin/rm -rf /mnt/nvme1n1/*",
                    "_uses_shell": true,
                    "argv": null,
                    "chdir": null,
                    "creates": null,
                    "executable": null,
                    "removes": null,
                    "stdin": null,
                    "stdin_add_newline": true,
                    "strip_empty_ends": true,
                    "warn": true
                }
            },
            "item": {
                "model": "MZPLL6T4HMLS-00003",
                "mount_point": "/mnt/nvme1n1",
                "name": "nvme1n1",
                "size": "5.9T",
                "vendor": "SAMSUNG"
            },
            "rc": 0,
            "start": "2020-03-05 16:47:08.331683",
            "stderr": "",
            "stderr_lines": [],
            "stdout": "",
            "stdout_lines": []
        },
        {
            "ansible_loop": {
                "allitems": [
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme0n1",
                        "name": "nvme0n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    },
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme1n1",
                        "name": "nvme1n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    },
                    {
                        "model": "MZPLL6T4HMLS-00003",
                        "mount_point": "/mnt/nvme2n1",
                        "name": "nvme2n1",
                        "size": "5.9T",
                        "vendor": "SAMSUNG"
                    }
                ],
                "first": false,
                "index": 3,
                "index0": 2,
                "last": true,
                "length": 3,
                "previtem": {
                    "model": "MZPLL6T4HMLS-00003",
                    "mount_point": "/mnt/nvme1n1",
                    "name": "nvme1n1",
                    "size": "5.9T",
                    "vendor": "SAMSUNG"
                },
                "revindex": 1,
                "revindex0": 0
            },
            "ansible_loop_var": "item",
            "changed": true,
            "cmd": "/bin/rm -rf /mnt/nvme2n1/*",
            "delta": "0:00:00.121824",
            "end": "2020-03-05 16:47:13.381671",
            "failed": false,
            "invocation": {
                "module_args": {
                    "_raw_params": "/bin/rm -rf /mnt/nvme2n1/*",
                    "_uses_shell": true,
                    "argv": null,
                    "chdir": null,
                    "creates": null,
                    "executable": null,
                    "removes": null,
                    "stdin": null,
                    "stdin_add_newline": true,
                    "strip_empty_ends": true,
                    "warn": true
                }
            },
            "item": {
                "model": "MZPLL6T4HMLS-00003",
                "mount_point": "/mnt/nvme2n1",
                "name": "nvme2n1",
                "size": "5.9T",
                "vendor": "SAMSUNG"
            },
            "rc": 0,
            "start": "2020-03-05 16:47:13.259847",
            "stderr": "",
            "stderr_lines": [],
            "stdout": "",
            "stdout_lines": []
        }
    ]
}

PLAY RECAP *********************************************************************
nid00052                   : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
nid00053                   : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

/users/ftessier/dynamic-resource-provisioning/src/dsrp_data_manager.py: info: No playbook set for starting the clients.
/users/ftessier/dynamic-resource-provisioning/src/dsrp_data_manager.py: info: No playbook set for stopping the clients.
/users/ftessier/dynamic-resource-provisioning/src/dsrp_data_manager.py: info: No client-side service to stop.
