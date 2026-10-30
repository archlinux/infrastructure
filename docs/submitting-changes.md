# Submitting changes

Direct pushes to the `main` branch are disabled, every change set must go through merge
requests.

Merge requests require the following rules in order to be merged:

- The pipeline must succeed.
- Every thread must be resolved.
- There must be at least one approval.

Self-approval is enabled but should generally be avoided. Exceptions can be made for really
trivial changes that may not necessarily warrant a review from another member of the team
(such as simple version bumps like
[this](https://gitlab.archlinux.org/archlinux/infrastructure/-/merge_requests/1128)).
