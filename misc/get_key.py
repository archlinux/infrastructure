#!/usr/bin/python3

import json
import os
import sys
from contextlib import contextmanager
from pathlib import Path
import click
import yaml
import enum


@contextmanager
def chdir(path):
    oldcwd = os.getcwd()
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(oldcwd)


root = Path(__file__).resolve().parents[1]

with chdir(root):
    from ansible.cli import CLI
    from ansible.constants import DEFAULT_VAULT_IDENTITY_LIST
    from ansible.parsing.dataloader import DataLoader
    from ansible.parsing.vault import VaultLib

    data_loader = DataLoader()
    data_loader.set_basedir(root)

    vault_lib = VaultLib(
        CLI.setup_vault_secrets(
            data_loader, DEFAULT_VAULT_IDENTITY_LIST, auto_prompt=False
        )
    )


def load_vault(path):
    return yaml.load(
        vault_lib.decrypt(Path(path).read_text()), Loader=yaml.SafeLoader
    )


class OutputFormat(enum.StrEnum):
    bare = enum.auto()
    env = enum.auto()
    json = enum.auto()

@click.command()
@click.argument('vault', type=click.Path(exists=True))
@click.argument('keys', nargs=-1)
@click.option('--format', default=OutputFormat.bare, type=click.Choice(OutputFormat), help='Output format')
def main(vault, keys, format):
    """
    Get a bunch of entries from the vault located at VAULT.

    Use KEYS to choose which keys in the vault you want to output.
    """
    vault = load_vault(vault)
    filtered = {vault_key: vault[vault_key] for vault_key in keys}

    if format == OutputFormat.bare:
        for secret in filtered.values():
            print(secret)
    elif format == OutputFormat.env:
        for key, secret in filtered.items():
            print(f"{key}={secret}")
    elif format == OutputFormat.json:
        json.dump(filtered, sys.stdout)
        print()


if __name__ == "__main__":
    main()
