#!/usr/bin/env python3

import os, sys, pprint, click
import subprocess as p
from subprocess import check_call, CalledProcessError
from pathlib import Path

def print_comand(*args, **kwargs):
    pprint.pprint(locals())

@click.command()
@click.argument('target', type=click.Choice(['release_head', 'release_origin', 'fast_head', 'fast_origin']))
@click.option('--dry_run', default=False, is_flag=True, help='Only the show the command will be run')
def rebuild(target, dry_run):

    run = print_comand if dry_run else check_call

    dispatch = dict(
        release_head   = Path('~/builds/panama/release/head'),
        release_origin = Path('~/builds/panama/release/origin'),
        fast_head      = Path('~/builds/panama/fastdebug/head'),
        fast_origin    = Path('~/builds/panama/fastdebug/origin'),
    )
    directory = dispatch[target].expanduser()

    cmd_reconfigure = ['make', 'reconfigure']
    cmd_build = ['mkjdk.py', '--run_in', directory]

    try:
        run(cmd_build)
    except CalledProcessError:
        print("Caught exception 'CalledProcessError', will try to reconfigure:", cmd_reconfigure)
        run(cmd_reconfigure, cwd=directory)
        run(cmd_build)


if __name__ == "__main__":
    rebuild()
