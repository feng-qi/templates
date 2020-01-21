#!/usr/bin/env python3

import os, sys, pprint, click
import subprocess as p
from subprocess import check_call, CalledProcessError
from pathlib import Path

def print_comand(*args, **kwargs):
    pprint.pprint(locals())


def get_branch_in(directory):
    cmd = ['git', 'rev-parse', '--abbrev-ref', 'HEAD']
    return p.check_output(cmd, cwd=directory.expanduser()).decode('utf-8').strip()

def dir_has_branch(directory, branch):
    return get_branch_in(directory) == branch


@click.command()
@click.argument('target', type=click.Choice(['release_head', 'release_origin', 'fast_head', 'fast_origin']))
@click.option('--repo', default=Path('~/repos/panama').expanduser(), help='Specify which repo to use')
@click.option('--origin', '-o', default='vectorIntrinsics', help='Specify which branch is used as origin')
@click.option('--dry_run', default=False, is_flag=True, help='Only the show the command will be run')
@click.pass_context
def rebuild(ctx, target, repo, origin, dry_run):

    run = print_comand if dry_run else check_call

    dispatch = dict(
        release_head   = Path('~/builds/panama/release/head'),
        release_origin = Path('~/builds/panama/release/origin'),
        fast_head      = Path('~/builds/panama/fastdebug/head'),
        fast_origin    = Path('~/builds/panama/fastdebug/origin'),
    )
    build_dir = dispatch[target].expanduser()

    if 'origin' in target and not dir_has_branch(repo, origin):
        ctx.fail(f"{target} build: repo in '{build_dir}' does not have branch '{origin}'")

    # cmd_reconfigure = ['make', 'reconfigure']
    cmd_build = ['mkjdk.py', '--run_in', build_dir]

    run(cmd_build)

if __name__ == "__main__":
    rebuild()
