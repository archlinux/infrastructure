<!--
This template should be used by DevOps members when adding an official GitLab Pages
site at a custom domain under either *.archlinux.page or *.archlinux.org.

For regular GitLab Pages using a generated unique domain, this is not necessary
and just works as-is without manual involvement.
-->

# Procedure for adding a GitLab Pages project to GitLab

## Details
- **Project name**: hello
- **Desired subdomain**: Either hello.archlinux.page or hello.archlinux.org

## New Pages site checklist

1. [ ] Have a pipeline that outputs some static HTML to `public/` during the build.
1. [ ] Specify this path (`public/`) as an artifact path.
1. [ ] GitLab should now recognize that you're trying to use Pages and will show some relevant
       information at https://gitlab.archlinux.org/your-namespace/your-project/pages
1. [ ] On this page, you'll also need to make sure that **Use unique domain** is toggled **ON**.
       Note down the custom domain.

### For a custom domain at *.archlinux.page
1. [ ] Add a mapping between the domain name and its generated unique domain
       from GitLab that you noted earlier into `gitlab_pages_archlinux_org_map` in
       `host_vars/gitlab.archlinux.org/misc.yml`.
1. [ ] Run `ansible-playbook playbooks/gitlab.archlinux.org.yml -t gitlab`.

### For a custom domain at *.archlinux.org
Please note that we don't give out custom domains under *.archlinux.org lightly.

1. [ ] Add the desired domain name into `archlinux_org_gitlab_pages` in `tf-stage1/archlinux.tf`.
1. [ ] Add a mapping between the domain name and its generated unique domain
       from GitLab that you noted earlier into `gitlab_pages_archlinux_org_map` in
       `host_vars/gitlab.archlinux.org/misc.yml`.
1. [ ] Run `terraform apply`.
1. [ ] Run `ansible-playbook playbooks/gitlab.archlinux.org.yml -t gitlab`.
