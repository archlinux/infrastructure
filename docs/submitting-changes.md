# Submitting changes

Direct pushes to the `main` branch are disabled, every change set must go through merge
requests.

Merge requests require the following rules in order to be merged:

- The pipeline should succeed.
- Every thread must be resolved.
- There should be at least one approval.

While it's not technically enforced, approving your own merge requests should be avoided.  
Exceptions to this rule can be made for really trivial changes that may not necessarily
warrant a review from another member of the team (for instance, simple version bump such
as [this](https://gitlab.archlinux.org/archlinux/infrastructure/-/merge_requests/1128))
or critical changes that may need to be shipped urgently (for instance, critical security
or bug fixes).
