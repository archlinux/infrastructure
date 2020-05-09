# Add a new dev/TU

 - Add the user to group_vars/all/archusers.yml
 - Copy the ssh key to pubkeys/$username.pub

 - Run `ansible-playbook -t archusers playbooks/*.yml` or similar

 - To create a new user in archweb use: https://www.archlinux.org/devel/newuser/
   This is also linked in the django admin backend at the top

 - For email accounts refer to docs/email.txt
