#!/bin/bash

source {{patchwork_dir}}/env/bin/activate
exec {{patchwork_dir}}/patchwork/bin/parsemail.sh
