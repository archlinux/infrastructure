#!/usr/bin/env python3

import json
from collections import OrderedDict
from sys import stdout
from urllib.parse import urlparse

import jsonschema
import requests
from jsonschema.exceptions import ValidationError

output = requests.get("https://oembed.com/providers.json")
output.raise_for_status()
providers = output.json(object_pairs_hook=OrderedDict)

# From synapse/config/oembed.py
_OEMBED_PROVIDER_SCHEMA = {
    "type": "array",
    "items": {
        "type": "object",
        "properties": {
            "provider_name": {"type": "string"},
            "provider_url": {"type": "string"},
            "endpoints": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "schemes": {
                            "type": "array",
                            "items": {"type": "string"},
                        },
                        "url": {"type": "string"},
                        "formats": {"type": "array", "items": {"type": "string"}},
                        "discovery": {"type": "boolean"},
                    },
                    "required": ["schemes", "url"],
                },
            },
        },
        "required": ["provider_name", "provider_url", "endpoints"],
    },
}

while True:
    try:
        jsonschema.validate(providers, _OEMBED_PROVIDER_SCHEMA)
    except ValidationError as e:
        del providers[e.absolute_path[0]]
    else:
        break


def valid_url(url):
    return urlparse(url).scheme in ["http", "https"]


def valid_provider(provider):
    for endpoint in provider["endpoints"]:
        if not valid_url(endpoint["url"]):
            return False
        for glob in endpoint["schemes"]:
            if not valid_url(glob):
                return False
    return True


providers = [p for p in providers if valid_provider(p)]
json.dump(providers, stdout, indent=4)
print()
