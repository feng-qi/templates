#!/usr/bin/env python3

import sys, pprint, click
import subprocess as p
from subprocess import check_call, CalledProcessError
from pathlib import Path

def print_comand(*args, **kwargs):
    pprint.pprint(locals())


@click.command()
@click.option('--vector_api/--no_vector_api', default=False, is_flag=True,
              help="Don't use Vector API, no Vector API by default")
@click.option('--dry_run', default=False, is_flag=True, help='Only the show the command will be run')
@click.option('--show_command', default=False, is_flag=True, help='Show the command will be run before running')
@click.option('-v', '--verbose', default=False, is_flag=True, help='Enables verbose mode')
@click.argument('files', nargs=-1, type=click.UNPROCESSED)
def run_jtreg(files, vector_api, dry_run, verbose, show_command):

    run = print_comand if dry_run else check_call

    files = [Path(file) for file in files]
    bad_files = list(filter(lambda file: not file.exists(), files))
    if bad_files:
        print('File not exist:')
        [print(f'  {i+1}: {file}') for i, file in enumerate(bad_files)]
        quit(1)

    vmoptions = ['--add-modules', 'jdk.incubator.vector']
    if not vector_api:
        vmoptions.append('-XX:-UseVectorApiIntrinsics')
    if verbose:
        vmoptions += ['-XX:+UnlockDiagnosticVMOptions',
                      '-XX:+DebugVectorApi',
                      '-XX:-TieredCompilation',]
    vmoptions = '-vmoptions:' + ' '.join(vmoptions)

    home = Path.home()
    jtreg_cmd = [
        home/"repos/jtreg/jtreg-hg/dist/jtreg/bin/jtreg",
        '-othervm', '-a', '-ea', '-esa', '-server', '-ignore:quiet', '-timeoutFactor:16', '-J-Xmx4g', vmoptions,
        '-v:fail',
        # '-va',
        '-testjdk:' + str(home/'builds/panama-fast/images/jdk'),
        '-r:' + str(home/'jtoutput/JTReport'),
        '-w:' + str(home/'jtoutput/JTWork'),
    ]

    for cmd in [jtreg_cmd + [file] for file in files]:
        if not dry_run and show_command:
            pprint.pprint(cmd)
        run(cmd)

    check_call(['date', '+%F %T'])


if __name__ == "__main__":
    run_jtreg()
