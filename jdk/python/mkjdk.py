#!/usr/bin/env python3

import os, sys, pprint, click
import subprocess as p
from subprocess import check_call, CalledProcessError
from pathlib import Path

def print_comand(*args, **kwargs):
    pprint.pprint(locals())


@click.command()
@click.option('--src', '-s', type=Path, default=Path('~/repos/panama').expanduser(),
              help='Assign OpenJDK source code directory')
@click.option('--des', '-d', type=Path, default=Path.cwd(), help='Assign build directory')
@click.option('--debug_level', '-l', type=click.Choice(['fastdebug', 'slowdebug']),
              default='fastdebug', help='Set debug level')
@click.option('--config_only', default=False, is_flag=True, help='Configure only, do not build')
@click.option('--config_needed/--no_config_needed', '-c', default=False, is_flag=True,
              help='Run configure before build')
@click.option('--target', '-t', type=click.Choice(['images', 'hotspot']), default='images',
              help='Specify build target, default is images')
@click.option('--jobs', '-j', default=16, help='Specifies the number of jobs (commands) to run simultaneously. Default value is 16.')
@click.option('--dry_run', default=False, is_flag=True, help='Only the show the command will be run')
def make_jdk(src, des, debug_level, config_only, config_needed, target, jobs, dry_run):

    run = print_comand if dry_run else check_call

    configure_cmd = [
        'bash',
        src/'configure',
        '--with-debug-level=' + debug_level,
        '--with-jvm-variants=server',
    ]
    if debug_level == 'slowdebug':
        configure_cmd.append('--with-native-debug-symbols=internal')

    build_cmd = ['make', target, 'JOBS='+str(jobs)]

    pprint.pprint(configure_cmd)
    pprint.pprint(build_cmd)

    env = dict(os.environ, JAVA_HOME='/usr/lib/jvm/jdk13')
    if config_needed:
        run(configure_cmd, cwd=des, env=env)
    if not config_only:
        run(build_cmd, cwd=des, env=env)


if __name__ == "__main__":
    make_jdk()
