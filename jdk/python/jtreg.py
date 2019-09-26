#!/usr/bin/env python3

import sys, pprint
import subprocess as p
from subprocess import check_call, CalledProcessError
from pathlib import Path

def run_jtreg_on(file_or_dir: Path):
    """
    Corresponding shell command:

    $JT_HOME/bin/jtreg -othervm -a -ea -esa -va \
        -vmoptions:"--add-modules jdk.incubator.vector -XX:+UnlockDiagnosticVMOptions -XX:+DebugVectorApi -XX:-TieredCompilation" \
        -ignore:quiet -timeoutFactor:16 \
        -J-Xmx4g -testjdk:/home/qifen01/builds/panama-build/images/jdk \
        -server -r:/home/qifen01/builds/JTReport -w:/home/qifen01/builds/JTWork \
        /home/qifen01/repos/panama/test/jdk/jdk/incubator/vector
    """

    home = Path.home()
    jtreg_cmd = [
        home/"repos/jtreg/jtreg-hg/dist/jtreg/bin/jtreg",
        '-v:fail',
        # '-va',
        '-othervm', '-a', '-ea', '-esa',
        # '-vmoptions:--add-modules jdk.incubator.vector -XX:+UnlockDiagnosticVMOptions -XX:+DebugVectorApi -XX:-TieredCompilation',
        '-vmoptions:--add-modules jdk.incubator.vector -XX:-UseVectorApiIntrinsics',
        # '-vmoptions:--add-modules jdk.incubator.vector',
        '-ignore:quiet',
        '-timeoutFactor:16',
        '-J-Xmx4g',
        '-testjdk:' + str(home/'builds/panama-fast/images/jdk'),
        '-server',
        '-r:' + str(home/'builds/JTReport'),
        '-w:' + str(home/'builds/JTWork'),
        file_or_dir,
    ]

    pprint.pprint(jtreg_cmd)
    p.check_call(jtreg_cmd)


if __name__ == "__main__":

    try:
        files = [Path(file) for file in sys.argv[1:]]
        bad_files = list(filter(lambda file: not file.exists(), files))
        if bad_files:
            print('File not exist:')
            [print(f'  {i}: {file}') for i, file in enumerate(bad_files)]
            quit(1)
        else:
            [run_jtreg_on(file) for file in files]
    except KeyboardInterrupt:
        print("Ctrl-C received, terminated by user")
