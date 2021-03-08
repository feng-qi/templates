#!/usr/bin/env python3

from pprint import pprint
from pathlib import Path
import subprocess as p
import time, psutil, os

# print(f'geteuid: {os.geteuid()}')
bundle      = '/home/qi/test/docker/nginx'
name_prefix = 'footprint'
runc_exe    = 'runc'
crun_exe    = '/home/qi/repos/crun/crun'

bundle_dir = Path(bundle)
if not ((bundle_dir/'config.json').is_file() and (bundle_dir/'rootfs').is_dir()):
    print(f'config.json or rootfs not exist in current directory: {str(bundle_dir)}')
    quit(1)

results = [ p.run(['which', cmd], capture_output=True)
            for cmd in [ runc_exe, crun_exe ] ]
if any(result.returncode != 0 for result in results):
    print(f"'{runc_exe}' or '{crun_exe}' can't be found")

def gen_id(runc, prefix, index):
    return f'{Path(runc).stem}_{prefix}_{index}'


def runc_list(quiet=False, runc='runc', capture_output=False):
    quiet = ['--quiet'] if quiet else []
    list_cmd = [ runc, 'list', *quiet ]
    out = p.run(list_cmd, check=True, capture_output=capture_output)
    # print(f'list_cmd: {list_cmd}')
    # print(f'out: {out}')
    return out.stdout.decode().strip()


def runc_version(runc='runc'):
    get_version_cmd = [ runc, '--version' ]
    p.run(get_version_cmd, check=True)


def runc_create(count, bundle=bundle, runc='runc'):
    create_cmds = [[ runc, 'create', '--bundle', bundle, gen_id(runc, name_prefix, i) ] for i in range(count)]
    for cmd in create_cmds:
        # pprint(cmd)
        p.run(cmd, check=True)


def runc_start(count, runc='runc'):
    start_cmds = [[ runc, 'start', gen_id(runc, name_prefix, i) ] for i in range(count)]
    for cmd in start_cmds:
        # pprint(cmd)
        p.run(cmd, check=True)


def runc_kill(count, signal, runc='runc'):
    kill_cmds = [[ runc, 'kill', gen_id(runc, name_prefix, i), signal ] for i in range(count)]
    for cmd in kill_cmds:
        # pprint(cmd)
        p.run(cmd, check=True)
        time.sleep(0.5)


def runc_delete(count, force=False, runc='runc'):
    force = ['--force'] if force else []
    delete_cmds = [[ runc, 'delete', *force, gen_id(runc, name_prefix, i) ] for i in range(count)]
    for cmd in delete_cmds:
        # pprint(cmd)
        p.run(cmd, check=True)


# def do_statistics(container_count, proc_name):

#     for proc in [ p for p in psutil.process_iter() if proc_name in p.name() ]:
#         print(f'{proc.name()}, {proc.pid}, cpu: {proc.cpu_percent()}, rss: {proc.memory_info().rss}, {proc.cmdline()}')
#     return

#     mem_in_bytes = sum([ proc.memory_info().rss
#                          for proc in psutil.process_iter() if proc_name in proc.name() ])
#     cpu_percent  = sum([ proc.cpu_percent()
#                          for proc in psutil.process_iter() if proc_name in proc.name() ])
#     print(f'container_count: {container_count}\nmem usage(rss):  {mem_in_bytes / 1024 / 1024} MB\ncpu percent:     {cpu_percent}')


def count_memory_before_start(container_count, runc='runc'):

    output = runc_list(runc =runc, capture_output =True)
    pids   = [ line.split()[1] for line in output.splitlines()[1:] ]
    procs  = [ psutil.Process(int(pid)) for pid in pids ]

    mem_in_bytes = sum([ proc.memory_info().rss for proc in procs ])
    cpu_percent  = sum([ proc.cpu_percent() for proc in procs ])
    print(f'container_count: {container_count}\nmem usage(rss):  {mem_in_bytes / 1024} KB\ncpu percent:     {cpu_percent}')


def get_fingerprint(container_count, runc='runc'):
    runc_create(container_count, runc=runc)
    # runc_start(container_count, runc=runc)
    time.sleep(1)    # Wait 1 second for stability

    count_memory_before_start(container_count, runc=runc)

    # p.run(['ps', '-o', 'pid,%cpu,%mem,args', '-C', 'nginx'])
    runc_delete(container_count, force=True, runc=runc)


# version infos
print('-- runc --------------------')
runc_version(runc=runc_exe)
print('-- crun --------------------')
runc_version(runc=crun_exe)
print()

container_counts = [ 10, 100 ]

print(f'{{-- runc --------------------------------')
for count in container_counts:
    get_fingerprint(container_count=count, runc=runc_exe)
    print()
print('}----------------------------------\n')

print(f'{{-- crun --------------------------------')
for count in container_counts:
    get_fingerprint(container_count=count, runc=crun_exe)
    print()
print('}----------------------------------')
