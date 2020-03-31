#!/usr/bin/env python3

import os, sys, pprint, click
import subprocess as p
from subprocess import check_call, CalledProcessError
from pathlib import Path

home = Path.home()

def print_comand(*args, **kwargs):
    pprint.pprint(locals())


@click.command()
@click.option('--vector_api/--no_vector_api', default=True, is_flag=True,
              help="Don't use Vector API, no Vector API by default")
@click.option('--dry_run', default=False, is_flag=True, help='Only the show the command will be run')
@click.option('--java_home', default=str(home/'builds/panama/fastdebug/head/images/jdk'), help='Specify the jdk to be tested')
@click.option('--show_command', default=False, is_flag=True, help='Show the command will be run before running')
@click.option('--add_vmoptions', type=str, help='Specify additional vmoptions')
@click.option('--print_assembly/--no_print_assembly', default=False, is_flag=True,
              help='Show the command will be run before running')
@click.option('-v', '--verbose', default=False, is_flag=True, help='Enables verbose mode')
@click.argument('files', nargs=-1, type=click.UNPROCESSED)
def run_jtreg(files, vector_api, dry_run, java_home, verbose, show_command, print_assembly, add_vmoptions):

    run = print_comand if dry_run else check_call

    files = [Path(file) for file in files]
    bad_files = list(filter(lambda file: not file.exists(), files))
    if bad_files:
        print('File not exist:')
        [print(f'  {i+1}: {file}') for i, file in enumerate(bad_files)]
        quit(1)

    v = '-va' if verbose else '-v:fail'
    vmoptions = ['-XX:+IgnoreUnrecognizedVMOptions', '-XX:+UnlockDiagnosticVMOptions']
    # vmoptions += ['-XX:MaxVectorSize=4']
    # vmoptions += ['-XX:PrintIdealGraphLevel=2', '-XX:PrintIdealGraphFile=ideal.xml']
    # vmoptions += ['-XX:+TieredCompilation', '-Xbatch']
    # vmoptions += ['-XX:+PrintCompilation']
    if not vector_api:
        vmoptions.append('-XX:-UseVectorApiIntrinsics')
    if print_assembly:
        vmoptions += ['-XX:+PrintAssembly',
                      # '-XX:+DebugNonSafepoints',
                      # '-XX:+DebugVectorApi',
                      ]
    if add_vmoptions is not None:
        vmoptions += add_vmoptions.split()

    jtreg_cmd = [
        home/"repos/jtreg/jtreg-hg/build/images/jtreg/bin/jtreg",
        # '--add-modules', 'jdk.incubator.vector',
        '-othervm', '-a', '-ea', '-esa', '-server', '-ignore:quiet', '-timeoutFactor:16', '-J-Xmx4g',
        '-vmoptions:' + ' '.join(vmoptions),
        # '-v:fail',
        # '-va',
        v,
        '-testjdk:' + java_home,
        '-r:' + str(home/'jtoutput/JTReport'),
        '-w:' + str(home/'jtoutput/JTWork'),
        *files
    ]

    env = dict(os.environ, JT_HOME='/home/qifen01/repos/jtreg/jtreg-hg/build/images/jtreg')
    if not dry_run and show_command:
        pprint.pprint(jtreg_cmd)

    pprint.pprint(jtreg_cmd)
    run(jtreg_cmd, env=env)

    check_call(['date', '+%F %T'])


if __name__ == "__main__":
    run_jtreg()
