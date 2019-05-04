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
Synopsis: $0 [command]

Commands:
clean    Remove installed file
install  Install by copying (default if no commands given).
symlink  Install symlinks from currect directory."

help="
Configure directories kept in RAM in /etc/defaults/ramdisk
Edit RAM flush period in /etc/cron.d/ramdisk-flush"

InstallDo ()
{
    if [ "$1" ]; then
        ${test:+echo} ln --verbose --symbolic --relative --force "$2" "$3"
    else
        ${test:+echo} install --verbose --mode 755 "$2" "$3"
    fi
}

Install ()
{
    [ ! -f /etc/init.d/ramdisk ] && firsttime="$help"

    InstallDo "$1"  etc/init.d/ramdisk /etc/init.d/
    InstallDo "$1"  etc/cron.d/ramdisk /etc/cron.d/

    [ "$firsttime" ] && echo "$firsttime"
}

Clean ()
{
    ${test:+echo} rm --verbose --force etc/init.d/ramdisk /etc/cron.d/etc/cron.d/ramdisk-flush
}

Main ()
{
    for arg in "$@"
    do
        case "$arg" in
            -c | *clean*)
                Clean
                ;;
            -s | *symlink*)
                # In place install for developrs and easy updates
                Install symlink
                ;;
            -h | *help*)
                echo "$usage"
                return 0
                ;;
            *)
                Install
                ;;
        esac
    done
}

Main "$@"

# End of file
