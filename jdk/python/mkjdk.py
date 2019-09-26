#!/usr/bin/env python3

import sys, pprint, click
import subprocess as p
from subprocess import check_call, CalledProcessError
from pathlib import Path

def print_comand(*args, **kwargs):
    pprint.pprint(locals())

@click.command()
@click.option('--src', '-s', default=Path('~/repos/panama').expanduser(),
              help='Assign OpenJDK source code directory')
@click.option('--des', '-d', default=Path.cwd(), help='Assign build directory')
@click.option('--debug_level', '-l', type=click.Choice(['fastdebug', 'slowdebug']),
              default='fastdebug', help='Set debug level')
@click.option('--config_only', default=False, is_flag=True, help='Configure only, do not build')
@click.option('--config_needed', '-c', default=False, is_flag=True, help='Run configure before build')
@click.option('--target', '-t', type=click.Choice(['images', 'hotspot']), default='images',
              help='Specify build target, default is images')
@click.option('--dry_run', default=False, is_flag=True, help='Only the show the command will be run')
def make_jdk(src, des, debug_level, config_only, config_needed, target, dry_run):

    run = print_comand if dry_run else p.check_call

    configure_cmd = [
        'bash',
        src/'configure',
        '--with-debug-level=' + debug_level,
        '--with-jvm-variants=server',
    ]
    if debug_level == 'slowdebug':
        configure_cmd.append('--with-native-debug-symbols=internal')

    pprint.pprint(configure_cmd)

    if not config_needed:
        run(configure_cmd, cwd=des)
    if not config_only:
        run(['make', target], cwd=des)


if __name__ == "__main__":

    try:
        make_jdk()
    except KeyboardInterrupt:
        print("Ctrl-C received, terminated by user")
