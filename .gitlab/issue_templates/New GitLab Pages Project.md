<!--
This template should be used by DevOps members when adding a GitLab Pages project to GitLab.

In order to use GitLab Pages with Arch Linux, you'll have to specifically request a custom subdomain
below `pkgbuild.com` or `archlinux.org` to be assigned. We don't allow random projects to use Pages
because of legal and safety reasons (we don't want people to be able to trick others into thinking
something hosted below one of our domains is official).
-->

# Procedure for adding a GitLab Pages project to GitLab

## Details
- **Project name**: hello
- **Desired subdomain**: hello.archlinux.org

## New Pages site checklist

1. [ ] Have a pipeline that outputs some static HTML to `public/` during the build.
1. [ ] Specify this path (`public/`) as an artifact path.
1. [ ] GitLab should now recognize that you're trying to use Pages and will show some relevant
       information at https://gitlab.archlinux.org/your-namespace/your-project/pages
1. [ ] At this page, you'll also need to add your custom domain. Add the custom domain you requested earlier.
       GitLab will then show domain verification information which you'll need in the next step.
1. [ ] At this point, we'll need to add some stuff to the `archlinux_org_gitlab_pages` variable in `archlinux.tf`. It should look something like this.
       Make sure to substitute the `your-domain` and `your-code-shown-by-gitlab` strings accordingly:

        {
          name              = "your-domain"
          verification_code = "your-code-shown-by-gitlab"
        }

1. [ ] Run `terraform apply` and go back to GitLab. Hit `Verify` and it should pick up the new domain
       verification code. It should then also automatically begin fetching a certificate via Let's
       Encrypt. That should take roughly 10min.
