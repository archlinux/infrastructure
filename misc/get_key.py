#!/usr/bin/python3

from contextlib import contextmanager
from enum import Enum
from pathlib import Path
import argparse
import json
import os
import sys
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


class Output(Enum):
    BARE = "bare"
    ENV = "env"
    JSON = "json"

    def __str__(self):
        return self.value


def parse_args():
    parser = argparse.ArgumentParser(
        description="Retrieve a password from an Ansible vault."
    )
    parser.add_argument(dest="vault", type=Path, help="vault to open")
    parser.add_argument(dest="key", help="key to extract")
    parser.add_argument(
        dest="output",
        nargs="?",
        type=Output,
        choices=Output,
        default=Output.BARE,
        help="style of output",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    value = load_vault(args.vault)[args.key]

    if args.output == Output.BARE:
        print(value)
    elif args.output == Output.ENV:
        print(f"{args.key}={value}")
    elif args.output == Output.JSON:
        json.dump({args.key: value}, sys.stdout)
        print()
    else:
        assert False


if __name__ == "__main__":
    main()
