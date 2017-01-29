#!/usr/bin/python

import errno
import grp
import os
import pwd
from stat import *

# simple module that creates many directories for users
# initially created for dbscripts to create staging directories in the user homes

def main():
    module = AnsibleModule(
            argument_spec = dict(
                permissions = dict(required=True),
                users = dict(required=True, type='list'),
                group = dict(required=True),
                directories = dict(required=True, type='list'),
                pathtmpl = dict(required=True),
                ),
            supports_check_mode=True,
    )

    users = module.params['users']
    directories = module.params['directories']
    permissions = int(module.params['permissions'], 8)
    pathtmpl = module.params['pathtmpl']
    group = module.params['group']
    gid = grp.getgrnam(group).gr_gid

    changed = 0
    changed_dirs = []

    for user in users:
        uid = pwd.getpwnam(user).pw_uid

        for dirname in directories:
            path = pathtmpl.format(**{"user": user, "dirname": dirname})

            permissions_incorrect = True
            dirmode = None

            if os.path.exists(path):
                stat = os.stat(path)
                dirmode = oct(stat.st_mode & 0777)
                diruid = stat.st_uid
                dirgid = stat.st_gid
                permissions_incorrect = diruid != uid or dirgid != gid

            if not os.path.isdir(path) or dirmode != oct(permissions) or permissions_incorrect:
                changed += 1
                changed_dirs.append(path)

                if not module.check_mode:
                    try:
                        try:
                            os.mkdir(path, permissions)
                        except OSError as ex:
                            if not (ex.errno == errno.EEXIST and os.path.isdir(path)):
                                raise
                    except Exception as e:
                        module.fail_json(path=path, msg='There was an issue creating %s as requested: %s' % (path, str(e)))
                    os.chmod(path, permissions)
                    os.chown(path, uid, gid)

    module.exit_json(changed=changed > 0, msg="%s directories changed" % (changed), changed_dirs=changed_dirs)

from ansible.module_utils.basic import AnsibleModule
if __name__ == '__main__':
    main()

