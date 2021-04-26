<!--
This template should be used by DevOps members when adding a repository to GitLab.
It can be used for migrations as well as new projects.
-->

# Procedure for adding an official project to GitLab

## Details
- **Project name**: my-example
- **Type**: MIGRATION or NEW PROJECT <!-- delete one of these -->
- **Current location**: git.archlinux.org/my-example.git <!-- delete this line if it's a new project and not a migration -->

## New repo checklist

If you want to add a new official project, here are some guidelines to follow:

1. [ ] Evaluate whether the project can sit in the official [GitLab Arch Linux group](https://gitlab.archlinux.org/archlinux)
       or whether it needs its own group. It only needs its own group if the primary
       development group is somehow detached from Arch Linux and only losely related (for instance: [pacman](https://gitlab.archlinux.org/pacman))
1. [ ] After project creation (use the GitLab import function if you migrate a repo), add the responsible people to the project
       in the *Members* page (https://gitlab.archlinux.org/archlinux/my-example/-/project_members)
       and give them the `Developer` role. The idea is to let these people mostly manage their own project while not giving them
       enough permissions to be able to misconfigure the project.
1. [ ] If mirroring to github.com is desired, work through the **GitHub.com mirroring checklist**
       below and then return to this one.
1. [ ] If the project needs a secure runner to build trusted artifacts, coordinate with
       the rest of the DevOps team and if found to be reasonable, assign a secure runner
       to a protected branch of the project.
1. [ ] If a secure runner is used, create an MR to make sure the project's `.gitlab-ci.yml` specifies
       `tags: secure`.
1. [ ] Make sure that the *Push Rules* in https://gitlab.archlinux.org/archlinux/arch-boxes/-/settings/repository
       reflect these values:
   - `Committer restriction`: `on`
   - `Reject unsigned commits`: `on`
   - `Do not allow users to remove tags with git push`: `on`
   - `Check whether author is a gitlab user`: `on`
   - `Prevent committing secrets to git`: `on`
   - All of these should be activated by default as per group rules but it's good to check.
1. [ ] The *Protected Branches* in https://gitlab.archlinux.org/archlinux/my-example/-/settings/repository should specify
       `Allowed to merge` and `Allowed to push` as `Developers + Maintainers.`
1. [ ] Disable unneeded project features under *Visibility, project features, permissions* (https://gitlab.archlinux.org/archlinux/my-example/edit)  
   Always:
   - `Users can request access`: `off`  
   Often, but not always:
   - Repository -> Container registry
   - Repository -> Git Large File Storage (LFS)
   - Repository -> Packages
   - Analytics
   - Requirements
   - Security & Compliance
   - Wiki
   - Operations

## GitHub.com mirroring checklist

### GitLab side

1. [ ] If you want to mirror your repository "my-example" from gitlab.archlinux.org to the github.com/archlinux organization,
       you should create an empty project for your project at github.com/archlinux/my-example or
       if that's an existing repository, make sure that the current histories of the source and
       target repository are exactly the same.
1. [ ] Go to https://gitlab.archlinux.org/archlinux/my-example/-/settings/repository and open
       *Mirroring repositories*. Make sure it has these settings:
   - `Git repository URL`: `ssh://git@github.com/archlinux/my-example.git`
   - `Mirror direction`: `Push`
   - `Authentication method`: `SSH public key`
   - `Only mirror protected branches` : `off`
1. [ ] Click `Mirror repository`.
1. [ ] A new entry will pop up which has a button titled `Copy SSH public key`. Click that to copy the public key to your clipboard.

### GitHub side

1. [ ] Log in with your primary GitHub account.
1. [ ] Go to https://github.com/archlinux/my-example/settings/access and assign the `Admin` role to the GitHub account
       `archlinux-github`.
1. [ ] Log in as the `archlinux-github` technical user. This is important as otherwise pushes won't be associated correctly.
1. [ ] Go to https://github.com/archlinux/my-example/settings/keys and add a new deploy key.
1. [ ] Name it "gitlab.archlinux.org" so we know where it's from.
1. [ ] Paste the public key you copied from GitLab earlier.
1. [ ] Check `Allow write access`.
1. [ ] Click `Add key`.
1. [ ] Verify the push mirror works by clicking the `Update now` button.
1. [ ] In the repository settings on GitHub's side you should disable a few things to clean up the project page:
   - `GitHub Actions`
   - `Wiki`
   - `Issues`
   - `Projects`
1. [ ] In the GitHub description of the mirrored project, append " (read-only mirror)" so that people know it's a mirror.
1. [ ] Disable `Packages` and `Environments` from being shown on the main page.
1. [ ] In the website field put the full url to the repository on our GitLab.
