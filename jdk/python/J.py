#!/usr/bin/env python3

import click
from subprocess import check_call, CalledProcessError
from pathlib import Path
from pprint import pprint


def print_comand(*args, **kwargs):
    pprint(locals())


@click.command()
@click.option('--dry_run', default=False, is_flag=True, help='Only the show the command will be run')
@click.argument('file', nargs=-1, type=click.UNPROCESSED)
def J(dry_run, file):
    if len(file) != 1:
        print('no file or more than one file given')
        quit(1)

    run = print_comand if dry_run else check_call

    java_home = Path('~/builds/panama-fast/images/jdk').expanduser()
    javac = java_home/'bin/javac'
    java = java_home/'bin/java'
    add_module = ['--add-modules', 'jdk.incubator.vector']

    file = Path(file[0])
    file_no_ext = file.stem

    compile = [javac, *add_module, file]
    execute = [java, *add_module, file_no_ext]

    # pprint(locals())

    run(compile)
    run(execute)


if __name__ == "__main__":
    J()
