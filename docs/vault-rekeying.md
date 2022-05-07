# Vault rekeying

## Changing the default vault password

```bash
# Generate a new password for the default vault
pwgen -s 64 >new-default-pw

# Re-encrypt all default vaults
ansible-vault rekey --new-vault-password-file ./new-default-pw \
  $(git grep -l 'ANSIBLE_VAULT;1.1;AES256$')

# Save the new password in encrypted form
# (replace "RECIPIENT" with your email)
gpg -r RECIPIENT -o misc/vault-default-password.gpg -e new-default-pw

# Re-encrypt the new password with all DevOps keys
ansible-playbook playbooks/tasks/reencrypt-vault-default-key.yml

# Ensure the new password is usable
ansible-vault view misc/vaults/vault_hcloud.yml

# Remove the unencrypted password file
rm new-default-pw

# Review and commit the changes
```

## Changing the super vault password

```bash
# Generate a new password for the super vault
pwgen -s 64 >new-super-pw

# Re-encrypt all super vaults
ansible-vault rekey --new-vault-id super@./new-super-pw \
  $(git grep -l 'ANSIBLE_VAULT;1.2;AES256;super$')

# Save the new password in encrypted form
# (replace "RECIPIENT" with your email)
gpg -r RECIPIENT -o misc/vault-super-password.gpg -e new-super-pw

# Re-encrypt the new password with all DevOps super keys
ansible-playbook playbooks/tasks/reencrypt-vault-super-key.yml

# Ensure the new password is usable
ansible-vault view misc/vaults/vault_hetzner.yml

# Remove the unencrypted password file
rm new-super-pw

# Review and commit the changes
```
