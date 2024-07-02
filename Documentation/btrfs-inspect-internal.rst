btrfs-inspect-internal(8)
=========================

SYNOPSIS
--------

**btrfs inspect-internal** <subcommand> <args>

DESCRIPTION
-----------

This command group provides an interface to query internal information. The
functionality ranges from a simple UI to an ioctl or a more complex query that
assembles the result from several internal structures. The latter usually
requires calls to privileged ioctls.

SUBCOMMAND
----------

dump-super [options] <device> [device...]
        Show btrfs superblock information stored on given devices in textual form.
        By default the first superblock is printed, more details about all copies or
        additional backup data can be printed.

        Besides verification of the filesystem signature, there are no other sanity
        checks. The superblock checksum status is reported, the device item and
        filesystem UUIDs are checked and reported.

        .. note::

                The meaning of option *-s* has changed in version 4.8 to be consistent
                with other tools to specify superblock copy rather the offset. The old way still
                works, but prints a warning. Please update your scripts to use *--bytenr*
                instead. The option *-i* has been deprecated.

        ``Options``

        -f|--full
                print full superblock information, including the system chunk array and backup roots
        -a|--all
                print information about all present superblock copies (cannot be used together
                with *-s* option)

        -i <super>
                (deprecated since 4.8, same behaviour as *--super*)
        --bytenr <bytenr>
                specify offset to a superblock in a non-standard location at *bytenr*, useful
                for debugging (disables the *-f* option)

                If there are multiple options specified, only the last one applies.

        -F|--force
                attempt to print the superblock even if a valid BTRFS signature is not found;
                the result may be completely wrong if the data does not resemble a superblock
        -s|--super <bytenr>
                (see compatibility note above)

                specify which mirror to print, valid values are 0, 1 and 2 and the superblock
                must be present on the device with a valid signature, can be used together with
                *--force*

dump-tree [options] <device> [device...]
        Dump tree structures from a given device in textual form, expand keys to human
        readable equivalents where possible.
        This is useful for analyzing filesystem state or inconsistencies and has
        a positive educational effect on understanding the internal filesystem structure.

        .. note::
                Contains file names, consider that if you're asked to send the dump for
                analysis. Does not contain file data.

        ``Options``

        -e|--extents
                print only extent-related information: extent and device trees
        -d|--device
                print only device-related information: tree root, chunk and device trees
        -r|--roots
                print only short root node information, i.e. the root tree keys
        -R|--backups
                same as *--roots* plus print backup root info, i.e. the backup root keys and
                the respective tree root block offset
        -u|--uuid
                print only the uuid tree information, empty output if the tree does not exist

        -b <block_num>
                print info of the specified block only, can be specified multiple times

        --follow
                use with *-b*, print all children tree blocks of *<block_num>*
        --dfs
                (default up to 5.2)

                use depth-first search to print trees, the nodes and leaves are
                intermixed in the output

        --bfs
                (default since 5.3)

                use breadth-first search to print trees, the nodes are printed before all
                leaves

        --hide-names
                print a placeholder *HIDDEN* instead of various names, useful for developers to
                inspect the dump while keeping potentially sensitive information hidden

                This is:

                * directory entries (files, directories, subvolumes)
                * default subvolume
                * extended attributes (name, value)
                * hardlink names (if stored inside another item or as extended references in standalone items)

                .. note::
                        Lengths are not hidden because they can be calculated from the item size anyway.

        --csum-headers
                print b-tree node checksums stored in headers (metadata)
        --csum-items
                print checksums stored in checksum items (data)
        --noscan
                do not automatically scan the system for other devices from the same
                filesystem, only use the devices provided as the arguments
        -t <tree_id>
                print only the tree with the specified ID, where the ID can be numerical or
                common name in a flexible human readable form

                The tree id name recognition rules:

                * case does not matter
                * the C source definition, e.g. BTRFS_ROOT_TREE_OBJECTID
                * short forms without BTRFS\_ prefix, without _TREE and _OBJECTID suffix, e.g. ROOT_TREE, ROOT
                * convenience aliases, e.g. DEVICE for the DEV tree, CHECKSUM for CSUM
                * unrecognized ID is an error

inode-resolve [-v] <ino> <path>
        (needs root privileges)

        resolve paths to all files with given inode number *ino* in a given subvolume
        at *path*, i.e. all hardlinks

        ``Options``

        -v
                (deprecated) alias for global *-v* option

logical-resolve [-Pvo] [-s <bufsize>] <logical> <path>
        (needs root privileges)

        resolve paths to all files at given *logical* address in the linear filesystem space

        ``Options``

        -P
                skip the path resolving and print the inodes instead
        -o
                ignore offsets, find all references to an extent instead of a single block.
                Requires kernel support for the V2 ioctl (added in 4.15). The results might need
                further processing to filter out unwanted extents by the offset that is supposed
                to be obtained by other means.
        -s <bufsize>
                set internal buffer for storing the file names to *bufsize*, default is 64KiB,
                maximum 16MiB.  Buffer sizes over 64Kib require kernel support for the V2 ioctl
                (added in 4.15).
        -v
                (deprecated) alias for global *-v* option

.. _man-inspect-map-swapfile:

map-swapfile [options] <file>
        (needs root privileges)

        Find device-specific physical offset of *file* that can be used for
        hibernation. Also verify that the *file* is suitable as a swapfile.
        See also command :command:`btrfs filesystem mkswapfile` and the
        :doc:`Swapfile feature<Swapfile>` description.

        .. note::
                Do not use :command:`filefrag` or *FIEMAP* ioctl values reported as
                physical, this is different due to internal filesystem mappings.
                The hibernation expects offset relative to the physical block device.

        ``Options``

        -r|--resume-offset
                print only the value suitable as resume offset for file */sys/power/resume_offset*

min-dev-size [options] <path>
        (needs root privileges)

        return the minimum size the device can be shrunk to, without performing any
        resize operation, this may be useful before executing the actual resize operation

        ``Options``

        --id <id>
                specify the device *id* to query, default is 1 if this option is not used

.. _man-inspect-rootid:

rootid <path>
        for a given file or directory, return the containing tree root id, but for a
        subvolume itself return its own tree id (i.e. subvol id)

        .. note::
                The result is undefined for the so-called empty subvolumes (identified by
                inode number 2), but such a subvolume does not contain any files anyway

subvolid-resolve <subvolid> <path>
        (needs root privileges)

        resolve the absolute path of the subvolume id *subvolid*

tree-stats [options] <device>
        (needs root privileges)

        Print sizes and statistics of trees. This takes a device as an argument
        and not a mount point unlike other commands.

        .. note::
                In case the the filesystem is still mounted it's possible to
                run the command but the results may be inaccurate or various
                errors may be printed in case there are ongoing writes to the
                filesystem. A warning is printed in such case.

        ``Options``

        -b
                Print raw numbers in bytes.

EXIT STATUS
-----------

**btrfs inspect-internal** returns a zero exit status if it succeeds. Non zero is
returned in case of failure.

AVAILABILITY
------------

**btrfs** is part of btrfs-progs.  Please refer to the documentation at
`https://btrfs.readthedocs.io <https://btrfs.readthedocs.io>`_.

SEE ALSO
--------

:doc:`mkfs.btrfs`
MARKER
