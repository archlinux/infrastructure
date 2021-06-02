#!/usr/bin/python3

import json
import os
import sys
from contextlib import contextmanager
from enum import Enum
from pathlib import Path
from typing import List
import click
import yaml


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
    with chdir(root):
        return yaml.load(
            vault_lib.decrypt(Path(path).read_text()), Loader=yaml.SafeLoader
        )


class OutputFormat(str, Enum):
    BARE = "bare"
    ENV = "env"
    JSON = "json"

    def __str__(self):
        return self.value

@click.command()
@click.argument('vault', type=click.Path(exists=True))
@click.argument('keys', nargs=-1)
@click.option('--format', default=OutputFormat.BARE, type=click.Choice([e.value for e in OutputFormat]), help='Output format')
def main(vault, keys, format):
    """
    Get a bunch of entries from the vault located at VAULT.

    Use KEYS to choose which keys in the vault you want to output.
    """
    vault = load_vault(vault)
    filtered = {vault_key: vault[vault_key] for vault_key in keys}

    if format == OutputFormat.BARE:
        for secret in filtered.values():
            print(secret)
    elif format == OutputFormat.ENV:
        for key, secret in filtered.items():
            print(f"{key}={secret}")
    elif format == OutputFormat.JSON:
        json.dump(filtered, sys.stdout)
        print()


if __name__ == "__main__":
    main()
