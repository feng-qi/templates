#!/usr/bin/env python3

import click
from subprocess import check_call, CalledProcessError
from pathlib import Path
from pprint import pprint


def print_comand(*args, **kwargs):
    pprint(locals())


@click.command()
@click.option('--dry_run', default=False, is_flag=True, help='Only the show the command will be run')
@click.option('--print_intrinsic/--no_print_intrinsic', default=False, is_flag=True,
              help='Print intrinsification information')
@click.option('--print_assembly/--no_print_assembly', default=False, is_flag=True,
              help='Print Assembly to file print_assembly.log')
@click.option('--log_file', type=Path, default=Path('print_assembly.log'), help='Specify the file to save the log')
@click.option('--java_home', type=Path, default=Path('~/builds/panama/fastdebug/head/images/jdk').expanduser(),
              help='Specify the java home')
@click.argument('file', nargs=-1, type=click.UNPROCESSED)
def J(dry_run, print_intrinsic, print_assembly, log_file, java_home, file):
    if len(file) != 1:
        print('no file or more than one file given')
        quit(1)

    run = print_comand if dry_run else check_call

    javac = java_home/'bin/javac'
    java = java_home/'bin/java'
    add_module = ['--add-modules', 'jdk.incubator.vector']

    file = Path(file[0])
    file_no_ext = file.stem

    print_assembly_opts = [
        '-XX:+PrintAssembly',
        # '-XX:+DebugNonSafepoints',
        '-XX:LogFile=' + str(log_file.expanduser()),
    ] if print_assembly else []

    print_intrinsic_opts = [
        '-XX:+DebugVectorApi',
    ] if print_intrinsic else []

    compile = [javac, *add_module, file]
    execute = [java, *add_module,
               '-XX:+UnlockDiagnosticVMOptions',
               # '-XX:-UseVectorApiIntrinsics',
               *print_assembly_opts,
               *print_intrinsic_opts,
               file_no_ext]

    pprint(execute)

    run(compile)
    run(execute)


if __name__ == "__main__":
    J()
