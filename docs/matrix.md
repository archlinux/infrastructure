# Matrix

We offer a Matrix homeserver for Arch team members. Matrix is a federated communication service with
a variety of available clients for multiple platforms, mobile included. The flagship [Element
clients](https://element.io/) offer us file upload, end-to-end encryption, push notifications and
integrations with third-party services.

## Signing in

For the initial sign-in you need to use a client that supports OpenID Single-Sign-On, such as
[Element Web](https://app.element.io/). Enter `@username:archlinux.org` as the username and Element
should offer to sign into our homeserver.

You will be automatically invited to several rooms:
  - `#archlinux:archlinux.org`: A public room for Arch Linux users.
  - `#internal:archlinux.org`: A staff-only room with end-to-end encryption.

Password login is currently disabled, which might exclude some clients. It can be re-enabled should
demand exist.

If you need to provide your client with a homeserver address, use `https://matrix.archlinux.org`.

## IRC bridges

### Our bridge

We bridge several of our private IRC channels on Libera Chat to Matrix, which you need to be invited
into:
  - `#developers:archlinux.org`: Bridged with `#archlinux-dev`.
  - `#trusted-users:archlinux.org`: Bridged with `#archlinux-tu`.
  - `#staff:archlinux.org`: Bridged with `#archlinux-staff`.

Please request an invitation in `#internal:archlinux.org` for the rooms you need to be in.

### Matrix.org bridge

Channels without keys are available via the official Libera Chat bridge. For example:
  - `#archlinux-devops:libera.chat`: Bridged with `#archlinux-devops`.
  - `#archlinux-projects:libera.chat`: Bridged with `#archlinux-projects`.

**Please avoid joining large bridged rooms (such as `#archlinux:libera.chat`), as these slow down
the server immensely.**

Libera Chat may require you to have a registered nick to join certain channels. Once
`@appservice:libera.chat` contacts you, tell it `!username <username>`, then `!storepass <password>`
with the username and the password of your Libera Chat NickServ account. Then `!reconnect` and it
will reconnect you as registered.
