# Growing (partitioned) Disks

Our VPS are provisioned with 20G as CX11 by default. When one is resized the disk size usually changes.
To use the additional space, one needs to grow the partition and the filesystem.

## Resizing partition

Grow the partition with a tool called growpart

    growpart /dev/sdX <partnum>

So for most of our machines this is:

    growpart /dev/sda 1

## Resizing filesystem

This is straight forward

    btrfs fi res max <mountpoint>

For most of our setups, being in the root homedir:

    btrfs fi res max .
