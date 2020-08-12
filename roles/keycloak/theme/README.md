# Arch Linux Keycloak theme

A custom Keycloak theme that resembles the Arch Linux website in terms of coloring scheme and aesthetics.

The custom theme name is `archlinux` and is based on the default theme `keycloak` which in turn is based on `base`. Based means that the custom theme is an extension of the `keycloak` theme that already comes bundled with Keycloak.

## What has been modified

There are five sections that can be customized: login, account, admin console welcome screen and email.  The email content did not need any further changes from the defaults therefore it has not been modified, everything else was customized.

The theme modifications were pretty simple and mostly involved changing images from Keycloak logo to Arch Linux logo along with some background images and some element hiding and sizing fixes.

A Keycloak theme consists of various files but for the custom theme only images, CSS stylesheets and HTML templates (FreeMarker templates) were needed to be modified to achieve the desired results.

- Login screen

  - the background image has been changed

  - the Keycloak logo has been replaced with the Arch Linux logo

- Welcome screen

  - the background image has been changed

  - the Keycloak logo has been replaced with the Arch Linux logo

  - the title text color was changed from black to white due to the dark background

  - the text of the panels and their associated links has been changed to refer to the Arch Linux project instead of the Keycloak one

  - the default footer has been hidden

- Account screen

  - the Keycloak logo on the top left has been replaced with the Arch Linux logo

  - the Keycloak logo during the account console loading animation has been replaced with the Arch Linux logo

- Admin console Screen

  - the Keycloak logo on the top left has been replaced with the Arch Linux logo

## Useful resources

- [Keycloak theming documentation](https://www.keycloak.org/docs/latest/server_development/#_themes)

- [Keycloak default theme resource files]([keycloak/themes/src/main/resources/theme/keycloak at master · keycloak/keycloak · GitHub](https://github.com/keycloak/keycloak/tree/master/themes/src/main/resources/theme/keycloak))

- [Keycloak base theme resource files]([keycloak/themes/src/main/resources/theme/base at master · keycloak/keycloak · GitHub](https://github.com/keycloak/keycloak/tree/master/themes/src/main/resources/theme/base))

- [Keycloak preview theme for new account system resource files]([keycloak/themes/src/main/resources/theme/keycloak-preview/account at master · keycloak/keycloak · GitHub](https://github.com/keycloak/keycloak/tree/master/themes/src/main/resources/theme/keycloak-preview/account))

- [Keycloak Docker containers main repository]([GitHub - keycloak/keycloak-containers: Docker image for Keycloak project](https://github.com/keycloak/keycloak-containers))

## Additional notes

- When extending a theme you can override individual resources (templates, stylesheets, etc.). To minimize the changes the stylesheets only override what was necessary. Since the custom theme is based on the default `keycloak` theme the new stylesheets import the default stylesheets and through the use of [cascading]([Cascade and inheritance - Learn web development | MDN](https://developer.mozilla.org/en-US/docs/Learn/CSS/Building_blocks/Cascade_and_inheritance)) change only what is necessary.

- If you decide to override HTML templates bear in mind that you may need to update your custom template when upgrading to a new release. Since some HTML templates were modified, a maintenance update to the theme could be necessary.

- While creating a theme it’s a good idea to disable caching as this makes it possible to edit theme resources directly from the `themes` directory without restarting Keycloak. To do this edit `standalone.xml`. For `theme` set `staticMaxAge` to `-1` and both `cacheTemplates` and `cacheThemes` to `false`. **Note**: this is done automatically by the provided Ansible playbook for local development. See the maintenance guide below for details.

- Each section that can be modified uses a file called `theme.properties` which allows setting some configuration for the theme such as:

  - parent - Parent theme to extend

  - import - Import resources from another theme

  - styles - Space-separated list of styles to include

  - locales - Comma-separated list of supported locales

  The file sometimes can also include custom properties that can be used from HTML  templates. **Note**: this is quite powerful always try to use properties if at all possible to do theme alterations.

### Licensing details

The custom theme is using the following image resources:

- The Arch Linux "Two-color standard version" and "Two-color inverted version" SVG logos from the [Arch Linux Logos and Artwork webpage]([Arch Linux - Artwork](https://www.archlinux.org/art/)). The following Arch Linux logos are available for press and other use, subject to the restrictions of a [trademark policy](https://wiki.archlinux.org/index.php/DeveloperWiki:TrademarkPolicy "Arch Linux Trademark Policy").

- The [dark plaster texture background image](https://unsplash.com/photos/gM8igOIP5MA) by [Annie Spratt](https://unsplash.com/@anniespratt) hosted on Unsplash. All images hosted on Unsplash are made to be used freely. Please look at the [license](https://unsplash.com/license) for more information.

### Maintenance guide

Requirements:

- Docker

- Ansible  

The theme folder includes a helpful Ansible playbook (`localdev.yml`) to enable local theme development and maintenance via a Docker container that spins up a local Keycloak instance that can be quickly accessed and be tampered with. This means that there is no need to touch the actual running Keycloak instance to do theme modifications. It is recommend to test out theme customizations locally first before deploying them to the running instance.

The Ansible playbook is doing the following:

- Spins up a local Keycloak server instance that can be accessed from `http://127.0.0.1:9000`

- Creates a default `admin` user with the same name and password

- Sets the default theme and welcome screen to the `archlinux` theme

- Disables theme caching to make it possible to edit theme resources directly from the `themes` directory without restarting Keycloak

- Installs vim to enable editing of the theme resources within the container

- Automatically restarts and recreates the container each time is executed to test any new changes applied to the local resource files

**Note**:  the directory structure of the Keycloak docker container is different from an actual running instance.

| Directory     | Container                                    | Actual Instance                        |
| ------------- | -------------------------------------------- | -------------------------------------- |
| themes        | /opt/jboss/keycloak/themes                   | /opt/keycloak/themes                   |
| configuration | /opt/jboss/keycloak/standalone/configuration | /opt/keycloak/standalone/configuration |

To start the local Keycloak instance and try out some changes:

1. navigate into the theme directory

   ```shell
   cd /roles/keycloak/theme
   ```

2. run the Ansible playbook

   ```shell
   ansible-playbook -i localhost, localdev.yml
   ```

3. edit the custom `archlinux` theme

   ```shell
   docker exec -it keycloak bash
   cd /opt/jboss/keycloak/themes/archlinux
   vim path_to_file_you_want_to_edit

   ....

   restart the page and view your changes live
   ```

**Note**: since the `archlinux` custom theme folder gets mounted within the container each time the playbook is executed, any changes you do within the container are persistent.
