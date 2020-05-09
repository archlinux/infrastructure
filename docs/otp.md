# Setting up OTP stuff for Arch's various accounts

Arch has master accounts with some service providers. These are to be treated with utmost
care for obvious reasons. We use 2FA where ever possible.

The general flow for these is:
- Install pass-otp: `pacman -S pass-otp`
- Use pass-otp to log in via a master seed
- (Optional) Depending on the service provider, you can then add your own authenticator

## GitHub

Run

    pass otp insert -i GitHub -a archlinux-master-token github.com/archlinux-master-token -s

When asked for a secret, provide the `github_master_seed` from `misc/vault_github.yml`.
You can then run

    pass otp code github.com/archlinux-master-token

to generate a token to log in.

Sadly, GitHub doesn't support multiple 2FA devices so this is all we get.


## Hetzner

Run

    pass otp insert -i Hetzner -a archlinux-master-token Hetzner/archlinux-master-token -s

When asked for a secret, provide the `hetzner_master_seed` from `misc/vault_hetzner.yml`.
You can then run

    pass otp code Hetzner/archlinux-master-token

to generate a token to log in.


### Adding your own account

Hetzner supports multiple 2FA devices at once which allows you to add your own 2FA app of choice
in addition to pass-otp.

To add yours, go to the 2FA management page: https://accounts.hetzner.com/tfa

Add a new authentication method with your username and add the token of this
key to either pass otp or an OTP tool of your choice.

Make sure to put your nickname into the description so we know who that key belongs to.

If you choose to use pass, you can add the key by running something
similar to `pass otp insert -i Hetzner -a archlinux Hetzner/archlinux -s`.

If you want to use your own tool, you can either scan the QR code or enter the shown string manually.
