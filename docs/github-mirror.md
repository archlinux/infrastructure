# How to add a mirror to GitHub

## GitLab side

If you want to mirror your repository "myproject" from gitlab.archlinux.org to the github.com/archlinux organization,
you should create an empty project for your project at github.com/archlinux/myproject or
if that's an existing repository, make sure that the current histories of the source and
target repository are exactly the same.

Then, go to https://gitlab.archlinux.org/archlinux/myproject/-/settings/repository and open
"Mirroring Repositories".
Make sure it has these settings:

* Git repository URL: `ssh://git@github.com/archlinux/myproject.git`
* Mirror direction: Push
* Authentication method: "SSH public key"
* Only mirror protected branches: Off

and then click Mirror repository.

A new entry will pop up which has a button titled "Copy SSH public key". Click that.

## GitHub side

Then go to https://github.com/archlinux/myproject/settings/keys and add a new deploy key.
Give it the title "gitlab.archlinux.org" so we know where it's from and then paste the
public key you copied from GitLab just now. Check "Allow write access" and
click "Add key".

Your push mirror should now work.

### GitHub repo settings

In the repo settings on GitHub's side you should disable a few things to clean up the project page:

- GitHub Actions
- Wikis
- Issues
- Projects

Finally, in the GitHub description of the mirrored project, append " (read-only mirror)"
so that people know it's a mirror. Also, in the website field put the full URL to the
upstream repo on our GitLab, and disable "Packages" and "Environments" from being shown on the
main page.
