# How to create a new official project on GitLab

If you want to create a new official project, here are some guidelines to follow:

1. Evaluate whether the project can sit in the official GitLab Arch Linux group
or whether it needs its own group. It only needs its own group if the primary
development group is somehow detached from Arch Linux and only losely related.
Example: pacman
2. After project creation, add the responsible people to the project and give them
the "Developer" role. The idea is to let these people mostly manage their own project.
3. If mirroring to github.com is desired, see `github-mirror.md`.
4. If a project needs a secure runner to build trusted artifacts, coordinate with
the rest of the DevOps team and if found to be reasonable, assign a secure runner
to a protected branch of the project.
5. Make sure that the Push Rules in https://gitlab.archlinux.org/archlinux/arch-boxes/-/settings/repository
tick all of "Committer restriction", "Reject unsigned commits", "Do not allow
users to remove tags with git push", "Check whether author is a GitLab user",
"Prevent committing secrets to Git". All of these should be activated by
default as per group rules but it's good to check.
6. The Protected Branches in https://gitlab.archlinux.org/archlinux/arch-boxes/-/settings/repository
should specify "Allowed to merge" and "Allowed to push" as "Developers + Maintainers."
