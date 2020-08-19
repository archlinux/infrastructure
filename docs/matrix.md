# Matrix

We offer a Matrix homeserver for Arch team members. Matrix is a federated communication service with
a variety of available clients for multiple platforms, mobile included. The flagship [Element
clients](https://element.io/) offer us file upload, end-to-end encryption, push notifications and
integrations with third-party services.

## Signing in

For the initial sign-in you need to use a client that supports OpenID Single-Sign-On, such as [Element
Web](https://app.element.io/). Enter `@username:archlinux.org` as the username and Element should
offer to sign into our homeserver.

You will be automatically invited to several rooms:
  - `#archlinux:archlinux.org`: A public room for Arch Linux users.
  - `#staff:archlinux.org`: Bridged with the `#archlinux-staff` IRC channel on Freenode.
  - `#internal:archlinux.org`: A staff-only room with end-to-end encryption.

After signing in you can use Element's settings to set a password for the account if you want to use
a client that does not support SSO.

If you need to provide your client with a homeserver address, use `https://matrix.archlinux.org`.

## IRC bridges

### Our bridge

We bridge several of our private IRC channels on Freenode to Matrix, which you need to be invited
into:
  - `#developers:archlinux.org`: Bridged with `#archlinux-dev`.
  - `#trusted-users:archlinux.org`: Bridged with `#archlinux-tu`.
  - `#staff:archlinux.org`: Bridged with `#archlinux-staff`.

### Matrix.org bridge

Channels without keys are available via the "official" Freenode bridge at Matrix.org. For example:
  - `#freenode_#archlinux-devops:matrix.org`: Bridged with `#archlinux-devops`.
  - `#freenode_#archlinux-projects:matrix.org`: Bridged with `#archlinux-projects`.

**Please avoid joining large bridged rooms (such as `#freenode_#archlinux:matrix.org`), as these
slow down the server immensely.**

Freenode may require you to have a registered nick to join certain channels. Once
`@appservice-irc:matrix.org` contacts you, tell it to `!storepass <username>:<password>` with the
username and the password of your Freenode account and it will reconnect you as registered.
