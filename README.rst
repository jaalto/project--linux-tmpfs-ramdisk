..  comment: the source is maintained in ReST format.
    Emacs: http://docutils.sourceforge.net/tools/editors/emacs/rst.el
    Manual: http://docutils.sourceforge.net/docs/user/rst/quickref.html

DESCRIPTION
===========

Warning: As of 2019-05-04 this is *EXPERIMENTAL*. NOT TESTED and YOU
MAY LOOSE ALL YOUR DATA.

A Linux administrator utility to manage selected directories in tmpfs RAM.

Keep list of directories like /tmp and /var/cache in RAM in withing a
single mount point. The idea is speed and less HDD/SDD wear of
frequently accessed or written files. In low RAM systems (NAS,
routers, other embedded Linux), it's possible to use RAM better by
using tempfs filesystem like Zram[1].

For virtualized environments, the network traffic can be also reduced
by not writing directly to remte disk but keeping the data in host A's
memory.

     HOST		      NAS
     +-----------------+      +--------------------------------+
     | [Host A]        |      | [Host]                         |
     | Virtual Machine + ---- + Disks located on network drive |
     +-----------------+      +--------------------------------+

How does it work?
-----------------

Bash installation contains ``rbash`` binary which restricts access.
See
<http://www.gnu.org/s/bash/manual/html_node/The-Restricted-Shell.html>.
What is left to do is to provide a small set of configuration files to
go with the account. The concept is pretty straight forward but it is
tedious to type all the commands. This project automates the steps to:

1. Create a user account, provided it does not exist. Set login shell to ``rbash``

2. Copy minimal startup files (Bash, SSH).

2. Symlink allowed commands to user's ``bin/`` directory and point PATH there.

3. Set tight permissions for the account directory and its files.

After these steps, the account is hopefully sufficiently locked down.
User cannot edit configuration files, change PATH, run commands
starting with slash, or cd anywhere, so the only commands available to
him are those in ``bin/``.

REQUIREMENTS
============

1. Environment: Linux only

2. Build: /bin/sh

3. Run: POSIX ``/bin/sh`` and GNU command
   line programs

USAGE
=====

Login as root and run install:

    ./makefile.sh

Install Zram (optional):

    apt-get install zram-tools
    apt-get install util-linux # contains zramctl

    # Or use: "service zramswap <command>" depending on your Linux

    systemctl zramswap start
    systemctl zramswap status

Set up tempfs mount point in /etc/fstab and mount it:

    mkdir /mnt/ramdisk   # You can use any dir. Remember to edit /etc/defaults/ramdisk

    # (1) use this
    /dev/zram0 /mnt/ramdisk  tmpfs  size=200M,defaults,noexec,nosuid,nodev,mode=0755 0 0

    # (2) or use plain tmpfs
    tmpfs /mnt/ramdisk  tmpfs  size=200M,defaults,noexec,nosuid,nodev,mode=0755 0 0

    mount /mnt/ramdisk

Configure setting. Be very careful what diretoctories you put in RAM.
On power failure, the non-flushed data from RAM to disk is *lost*.

    /etc/defaults/ramdisk

Configure how often the RAM is flushed to disk. Default setup is every
2 hours:

    /etc/cron.d/ramdisk

REFERENCES
==========

- [1] Tmpfs:
  <https://www.kernel.org/doc/Documentation/filesystems/tmpfs.txt>
  <https://wiki.gentoo.org/wiki/Tmpfs>

- [2] Zram:
  <https://www.kernel.org/doc/Documentation/blockdev/zram.txt>
  <https://wiki.debian.org/ZRam>
  <https://wiki.archlinux.org/index.php/Improving_performance#Zram_or_zswap>
  <https://wiki.gentoo.org/wiki/Zram>

COPYRIGHT AND LICENSE
=====================

Copyright (C) 2018-2019 Jari Aalto <jari.aalto@cante.net>

This project is free; you can redistribute and/or modify it under
the terms of GNU General Public license either version 2 of the
License, or (at your option) any later version.

Project homepage (bugs and source) is at
<https://github.com/jaalto/project--linux-tmpfs-ramdisk>

.. End of file
