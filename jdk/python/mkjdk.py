#!/usr/bin/env python3

import os, sys, pprint, click
import subprocess as p
from subprocess import check_call, CalledProcessError
from pathlib import Path

def print_comand(*args, **kwargs):
    pprint.pprint(locals())


def run_with_default_exit_code(*args, **kwargs):
    try:
        check_call(*args, **kwargs)
    except CalledProcessError as e:
        click.get_current_context().exit(e.returncode)


@click.command()
@click.option('--src', '-s', type=Path, default=Path('~/repos/panama').expanduser(),
              show_default=True, help='Assign OpenJDK source code directory')
@click.option('--run-in', '-i', type=Path, default=Path.cwd(),
              help='Designate working directory. [default: current directory]')
@click.option('--debug-level', '-l', type=click.Choice(['fastdebug', 'slowdebug', 'release']),
              default='fastdebug', show_default=True, help='Set debug level')
@click.option('--config-only', default=False, is_flag=True, help='Configure only, do not build')
@click.option('--config-needed/--no-config-needed', '-c', default=False, is_flag=True,
              show_default=True, help='Run configure before build')
@click.option('--target', '-t', type=click.Choice(['images', 'hotspot']), default='images',
              show_default=True, help='Specify build target')
@click.option('--jobs', '-j', default=16, show_default=True,
              help='Specifies the number of jobs (commands) to run simultaneously.')
@click.option('--dry-run', default=False, is_flag=True, help='Only the show the command will be run')
def make_jdk(src, run_in, debug_level, config_only, config_needed, target, jobs, dry_run):
    print("Working in: " + str(run_in))

    run = print_comand if dry_run else run_with_default_exit_code

    configure_cmd = [
        'bash',
        src/'configure',
        '--with-debug-level=' + debug_level,
        '--with-jvm-variants=server',
    ]
    if debug_level == 'slowdebug':
        configure_cmd.append('--with-native-debug-symbols=internal')

    build_cmd = ['make', target, 'JOBS='+str(jobs)]

    env = dict(os.environ, JAVA_HOME='/mnt/share/openjdk/packages/boot-jdk/aarch64/latest')
    if config_needed:
        pprint.pprint(configure_cmd)
        run(configure_cmd, cwd=run_in, env=env)
    if not config_only:
        pprint.pprint(build_cmd)
        run(build_cmd, cwd=run_in, env=env)

        if target == 'hotspot':
            update_libjvm = ['cp', run_in/'jdk/lib/server/libjvm.so', run_in/'images/jdk/lib/server/libjvm.so']
            pprint.pprint(update_libjvm)
            run(update_libjvm , cwd=run_in, env=env)


if __name__ == "__main__":
    make_jdk()
