# Matrix

We offer a Matrix homeserver for Arch team members. Matrix is a federated communication service with
a variety of available clients for multiple platforms, mobile included. The flagship [Element
clients](https://element.io/) offer us file upload, end-to-end encryption, push notifications and
integrations with third-party services.

## Signing in

For the initial sign-in you need to use a client that supports OpenID Single-Sign-On, such as
[Element Web](https://app.element.io/). Enter `@username:archlinux.org` as the username and Element
should offer to sign into our homeserver.

You will be automatically invited to several spaces and rooms:
  - `#public-space:archlinux.org`: A public space for Arch Linux users.
    - `#archlinux:archlinux.org`: A public room for Arch Linux users.
  - `#staff-space:archlinux.org`: A staff-only space for Arch Linux staff.
    - `#internal:archlinux.org`: A staff-only room with end-to-end encryption.

Password login is currently disabled, which might exclude some clients. It can be re-enabled should
demand exist.

If you need to provide your client with a homeserver address, use `https://matrix.archlinux.org`.

## Our rooms bridged to IRC

We bridge several of our private IRC channels on Libera.Chat to Matrix.

These rooms are open to all staff-space members:
  - `#packaging:archlinux.org`: Bridged with `#archlinux-packaging`.
  - `#staff:archlinux.org`: Bridged with `#archlinux-staff`.

The following rooms are not open to all staff, so you need to be invited:
  - `#developers:archlinux.org`: Bridged with `#archlinux-dev`.
  - `#trusted-users:archlinux.org`: Bridged with `#archlinux-tu`.

Please request an invitation in `#internal:archlinux.org` for the rooms you need to be in.

These rooms are bridged to public channels, for which you should log into Libera.Chat via SASL:
  - `#aurweb:archlinux.org`: Bridged with `#archlinux-aurweb`.
  - `#bugs:archlinux.org`: Bridged with `#archlinux-bugs`.
  - `#devops:archlinux.org`: Bridged with `#archlinux-devops`.
  - `#pacman:archlinux.org`: Bridged with `#archlinux-pacman`.
  - `#projects:archlinux.org`: Bridged with `#archlinux-projects`.
  - `#reproducible:archlinux.org`: Bridged with `#archlinux-reproducible`.
  - `#security:archlinux.org`: Bridged with `#archlinux-security`.
  - `#testing:archlinux.org`: Bridged with `#archlinux-testing`.
  - `#wiki:archlinux.org`: Bridged with `#archlinux-wiki`.

If you fail to do so, your bridged IRC user cannot join the channels, meaning your messages won't be
bridged. See [Libera.Chat's guide](https://libera.chat/guides/registration) on how to register a
nickname. Afterwards, contact `@irc-bridge:archlinux.org` and send it the folllowing commands:
  - `!username <username>`, with the primary nickname you registered with, then
  - `!storepass <password>`, with your password for NickServ, and then
  - `!reconnect` to reconnect and attempt the SASL login.

If this worked, `@liberachat_SaslServ:archlinux.org` should contact you after the reconnect.
