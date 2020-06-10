#!/usr/bin/env python3

import os, sys, pprint, click
import subprocess as p
from pathlib import Path
from subprocess import CalledProcessError, check_call


@click.command()
@click.option('--dry-run', '-n', default=False, is_flag=True, help='Set --dry-run option for rsync')
@click.option('--pull', default=False, is_flag=True, help='Sync remote webrev content to local directory')
def rsync(dry_run, pull):

    dry_run = ['--dry-run'] if dry_run else []
    # Add trailing '/' to sync contents rather than directory itself
    local   = str(Path.home()/'webrev') + '/'
    remote  = 'qfeng@cr.openjdk.java.net:~'
    if pull:
        local, remote = remote, local

    rsync = ['rsync',
             *dry_run,
             '--exclude=.ssh', '--exclude=.trash',
             '--delete',
             '-av',
             local,
             remote]

    pprint.pprint(rsync)
    check_call(rsync)


if __name__ == "__main__":
    rsync()
