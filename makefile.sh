#!/bin/sh
#
#   Copyright
#
#       Copyright (C) 2018-2019 Jari Aalto
#
#   License
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program. If not, see <http://www.gnu.org/licenses/>.

usage="\
Synopsis: [DESTDIR=<install root>] $0 [command]

Commands:
install    Install by copying (default if no commands given)
symlink    Install symlinks from currect directory
clean      Remove installed run files. Leave configuration in /etc/defaults/ramdisk
realclean  Remove everything
status     Show install status."

help="
NOTE: Configure directories kept in RAM in /etc/defaults/ramdisk
NOTE: Edit RAM flush period in /etc/cron.d/ramdisk-flush"

Warn ()
{
    echo "$*" >&2
}

Die ()
{
    Warn "$*"
    exit 1
}

IsOverlayfs ()
{
    grep overlay /proc/filesystems
}

InstallDo ()
{
    type="$1"

    # Once defaults file is installed, do nothing.

    case "$2" in
        *default*)
            [ -f "/$2" ] && return 0
            type=""
            ;;
    esac

    unset dest

    case "$DESTDIR" in
        */)  dest=$DESTDIR    ;;
        */*) dest="$DESTDIR/" ;;
    esac

    if [ "$type" ]; then
        ${test:+echo} ln --verbose --symbolic --relative --force "$2" "$dest$3"
    else
        ${test:+echo} install ${dest:+-D} --verbose --mode 755 "$2" "$dest$3"
    fi
}

Install ()
{
    [ ! -f /etc/init.d/ramdisk ] && firsttime="$help"

    InstallDo "$1"  etc/init.d/ramdisk /etc/init.d/
    InstallDo "$1"  etc/cron.d/ramdisk /etc/cron.d/
    InstallDo "$1"  etc/default/ramdisk /etc/default/

    [ "$firsttime" ] && echo "$firsttime"
}

Clean ()
{
    ${test:+echo} rm --verbose --force /etc/init.d/ramdisk /etc/cron.d/ramdisk "$@"
}

RealClean ()
{
    Clean /etc/default/ramdisk
}

Status ()
{
    ls -l /ect/cron.d/ramdisk /ect/default/ramdisk /ect/init.d/ramdisk
}

RequireFEaturesOrDie ()
{
    if ! IsOverlayfs ; then
        Die "ERROR overlayfs not supported in current Kernel. Aborted."
    fi

    if ! which rsync > /dev/null 2>&1 ; then
        Die "ERROR rsync(1) progam not in PATH. Aborted."
    fi
}

Main ()
{
    for arg in "$@"
    do
        case "$arg" in
            -c | clean)
                Clean
                ;;
            -C | realclean)
                RealClean
                ;;
            -h | *help*)
                echo "$usage"
                return 0
                ;;
            -i | install)
                RequireFEaturesOrDie
                Install
                ;;
            -I | *symlink*)
                RequireFEaturesOrDie
                # In place install for developrs and easy updates
                Install symlink
                ;;
            -s | status)
                Status
                ;;
        esac
    done
}

Main "$@"

# End of file
