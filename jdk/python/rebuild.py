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
@click.argument('target', type=click.Choice(
    ['release_head', 'release_origin', 'fastdebug_head', 'fastdebug_origin', 'slowdebug_head', 'slowdebug_origin',
     'jdk_release_head', 'jdk_release_origin', 'jdk_fastdebug_head', 'jdk_fastdebug_origin']))
@click.option('--repo', show_default=True, default=Path('~/repos/panama').expanduser(), help='Specify which repo to use')
@click.option('--origin', '-o', default='vectorIntrinsics', help='Specify which branch is used as origin')
@click.option('--dry-run', default=False, is_flag=True, help='Only the show the command will be run')
@click.pass_context
def rebuild(ctx, target, repo, origin, dry_run):

    run = print_comand if dry_run else check_call

    build_dir = Path("~/builds").expanduser()
    dispatch = dict(
        release_head         = build_dir/'panama/release/head',
        release_origin       = build_dir/'panama/release/origin',
        fastdebug_head       = build_dir/'panama/fastdebug/head',
        fastdebug_origin     = build_dir/'panama/fastdebug/origin',
        slowdebug_head       = build_dir/'panama/slowdebug/head',
        slowdebug_origin     = build_dir/'panama/slowdebug/origin',
        jdk_release_head     = build_dir/'jdk/release/head',
        jdk_release_origin   = build_dir/'jdk/release/origin',
        jdk_fastdebug_head   = build_dir/'jdk/fastdebug/head',
        jdk_fastdebug_origin = build_dir/'jdk/fastdebug/origin',
    )
    build_dir = dispatch[target]
    src_dir = '~/repos/jdk' if 'jdk' in target else '~/repos/panama'

    if 'origin' in target and not dir_has_branch(repo, origin):
        ctx.fail(f"{target} build: repo in '{build_dir}' does not have branch '{origin}'")

    cmd_reconfigure = ['make', 'reconfigure']
    cmd_build = ['mkjdk.py', '--src', src_dir]

    try:
        run(cmd_build, cwd=build_dir)
    except CalledProcessError as e:
        if e.returncode == 2:
            run(cmd_reconfigure, cwd=build_dir)
            run(cmd_build, cwd=build_dir)

if __name__ == "__main__":
    rebuild()
