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
