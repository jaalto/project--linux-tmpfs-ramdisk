..  comment: the source is maintained in ReST format.
    Emacs: http://docutils.sourceforge.net/tools/editors/emacs/rst.el
    Manual: http://docutils.sourceforge.net/docs/user/rst/quickref.html

DESCRIPTION
===========

Warning: as of 2019-05-04 this is only a CONCEPT, NOT YET WORKING,
**EXPERIMENTAL**, UNTESTED.

A Linux administrator utility to manage selected directories in tmpfs RAM.

Keep list of directories like ``/tmp`` and ``/var/cache`` in RAM in a
single mount point. The idea is speed and less HDD/SDD wear of
frequently accessed or written files. In low RAM systems (NAS,
routers, other embedded Linux), it's possible to use RAM better by
using tempfs filesystem like Zram[1].

For virtualized environments, the network traffic can be also reduced
by not writing directly to remote disk but keeping the data in host A's
memory. ::

     HOST                     NAS
     +-----------------+      +--------------------------------+
     | [Host A]        |      | [Host]                         |
     | Virtual Machine + ---- + Disks located on network drive |
     +-----------------+      +--------------------------------+

How does it work?
-----------------

The ``/etc/init.d/ramdisk`` controls management of mount points,
layers them using overlayfs[3] and pretends that the new mounts in RAM
are the actual file system mounts using "bind mounts". The command
"start" is responsible for creating all the mounts and moving data to
RAM. Command "stop" unwinds the mounts, transfers changes back to the
disk and dissolves any remaining mounts back to pristine state. While
the data is in RAM, command "sync" can be used to write snapshot data
back to their respective direcories while continuing serving RAM after
the save is complete (a cron task is included to do this).

There are two mount layers: ::

    +-------------------------------------------+
    |    bind mounts from /mnt/ramdisk/<DIR>    |
    |    back to original FS: e.g. /tmp         |
    +-------------------------------------------+
    |    overlayfs: /tamp /var/spool...         |
    |    all mounts under: /mnt/ramdisk         |
    +-------------------------------------------+
    |    Original FS (standard directories)     |
    +-------------------------------------------+

REQUIREMENTS
============

1. Environment: Linux only. Requires overlayfs[3] in kernel (3.18+; 2014)
   Check ``/proc/filesystems``.

2. POSIX ``/bin/sh``, GNU command
   line programs and ``rsync``.

USAGE
=====

For preparations, make sure processes are not holding any files in
directories. E.g. ``ssh-agent`` stores files in ``/tmp``:

     find /tmp -print0 | xargs --null fuser

Make similar checks on other directories that you plan to put on RAM
according to ``/etc/default/ramdisk``. If in doubt, drop in single
user mode on running system first:

    telinit 1

After preparations, the utility is used as any other service. The
"sync" command copies data back from RAM to disk. ::

    /etc/init.d/ramdisk <start|stop|sync>

INSTALL
=======

Login as root and run install: ::

    ./makefile.sh install

Install Zram (optional): ::

    apt-get install zram-tools
    apt-get install util-linux # contains zramctl

    # Or use: "service zramswap <command>" depending on your Linux

    systemctl zramswap start
    systemctl zramswap status

Create tmpfs mount point, add it to /etc/fstab and mount it: ::

    mkdir /mnt/ramdisk   # You can use any dir. Remember to edit /etc/defaults/ramdisk

    # (1) use this
    /dev/zram0 /mnt/ramdisk  tmpfs  size=200M,defaults,noexec,nosuid,nodev,mode=0755 0 0

    # (2) or use plain tmpfs
    tmpfs /mnt/ramdisk  tmpfs  size=200M,defaults,noexec,nosuid,nodev,mode=0755 0 0

    mount /mnt/ramdisk

Configure setting. Be very careful what directories you put in RAM.
On power failure, the non-flushed data in RAM is *lost*. ::

    /etc/defaults/ramdisk

Configure how often the RAM is written back to disk. Default setup is every
2 hours. ::

    /etc/cron.d/ramdisk

REFERENCES
==========

- [1] Tmpfs:
  <https://www.kernel.org/doc/Documentation/filesystems/tmpfs.txt> and
  <https://wiki.gentoo.org/wiki/Tmpfs>

- [2] Zram:
  <https://www.kernel.org/doc/Documentation/blockdev/zram.txt> and
  <https://wiki.debian.org/ZRam> and
  <https://wiki.archlinux.org/index.php/Improving_performance#Zram_or_zswap> and
  <https://wiki.gentoo.org/wiki/Zram>

- [3] Overlayfs:
  <https://www.kernel.org/doc/Documentation/filesystems/overlayfs.txt> and
  <https://en.wikipedia.org/wiki/OverlayFS>

See also:

- <https://github.com/graysky2/anything-sync-daemon>
- <https://wiki.archlinux.org/index.php/anything-sync-daemon>
- <https://salsa.debian.org/janluca-guest/anything-sync-daemon-debian>
- <https://debian-administration.org/article/661/A_transient_/var/log>

COPYRIGHT AND LICENSE
=====================

Copyright (C) 2018-2019 Jari Aalto <jari.aalto@cante.net>

This project is free; you can redistribute and/or modify it under
the terms of GNU General Public license either version 2 of the
License, or (at your option) any later version.

Project homepage (bugs and source) is at
<https://github.com/jaalto/project--linux-tmpfs-ramdisk>

.. End of file
