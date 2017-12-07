"""
Source: https://gist.github.com/rkrzr/f5387167fa7b4869e2dca8b713879562

This module implements an Ansible plugin that is triggered at the start of a playbook.

The plugin dynamically generates a tag for each role. Each tag has the same name as its role.
The advantage of this is that it saves you some boilerplate, because you don't have to wrap
all tasks of a role in an additional block and assign a tag to that.
Additionally, it works automatically when you add new roles to your playbook.

Usage is exactly the same as without this plugin:

ansible-playbook --tags=some_tag provision.yml

Here, the "some_tag" tag was generated dynamically (assuming there is a "some_tag" role).

Installation:
1. Place this file in `plugins/callbacks/auto_tags.py` (relative to your playbook root)
2. Add the following two lines to your `ansible.cfg` file:

callback_plugins = plugins/callbacks
callback_whitelist = auto_tags
"""
from __future__ import print_function
from ansible.plugins.callback import CallbackBase


class CallbackModule(CallbackBase):
    """
    Ansible supports several types of plugins. We are using the *callback* type here, since
    it seemed the best choice for our use case, because it allows you to hook into the start
    of a playbook.
    """
    def v2_playbook_on_start(self, playbook):
        """
        Dynamically add a tag of the same name to each role.
        Note: Plays, roles, task_blocks and tasks can have tags.
        """
        plays = playbook.get_plays()

        # Note: Although identical roles are shared between plays we cannot deduplicate them,
        # since Ansible treats them as different objects internally
        roles = [role for play in plays for role in play.get_roles()]

        # Note: Tags for roles are set dynamically in `_load_role_data` instead of in __init__
        # I don't know why they do that.
        for role in roles:
            role_name = role._role_name
            if role_name not in role.tags:
                role.tags += [role_name]
