import os
import hashlib
import random
import string
import pathlib
import subprocess
import time
import multiprocessing

from datetime import datetime
from termcolor import colored


def parent_dir(path):
    return os.path.dirname(path)


def basename(path):
    return os.path.basename(path)


def path_join(prefix, suffix):
    return os.path.join(prefix, suffix)


def static_vars(**kwargs):
    def decorate(func):
        for k in kwargs:
            setattr(func, k, kwargs[k])
        return func
    return decorate


def hash_str(s: str) -> int:
    result = hashlib.md5(s.encode())
    return int(result.hexdigest()[0:8], 16)


def hash_concat(h1: int, h2: int) -> int:
    return hash_int(h1 + h2)


def hash_int(i: int) -> int:
    result = hashlib.md5(i.to_bytes(8, 'big', signed=True))
    return int(result.hexdigest()[0:8], 16)


def true_with_prob(x):
    return random.randint(1, 100) <= x


def rand_str(l=10):
    letters = string.ascii_lowercase + string.ascii_uppercase
    return ''.join(random.choice(letters) for i in range(l))


def mkdir(path):
    print(colored(f'MKDIR: {path}', 'green'))
    pathlib.Path(path).mkdir(parents=True, exist_ok=True)


def print_red(message, no_newline=False):
    if no_newline:
        print(colored(message, 'red'), end='', flush=True)
    else:
        print(colored(message, 'red'))


def print_blue(message, no_newline=False):
    if no_newline:
        print(colored(message, 'blue'), end='', flush=True)
    else:
        print(colored(message, 'blue'))


def print_cyan(message, no_newline=False):
    if no_newline:
        print(colored(message, 'cyan'), end='', flush=True)
    else:
        print(colored(message, 'cyan'))


def print_green(message, no_newline=False):
    if no_newline:
        print(colored(message, 'green'), end='', flush=True)
    else:
        print(colored(message, 'green'))


def time_str():
    return datetime.now().strftime('%Y_%m_%d-%H:%M:%S')


def ancestor_path(p1, p2):
    return p1.startswith(p2) or p2.startswith(p1)


def exec(cmd_list, timeout=None):
    if timeout:
        return subprocess.run(cmd_list,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            timeout=timeout)
    else:
        return subprocess.run(cmd_list,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)

def process_exec(cmd_list, timeout=None, stdout_output=True):
    def _target(timeout):
        if stdout_output:
            proc = subprocess.Popen(cmd_list)
        else:
            proc = subprocess.Popen(cmd_list,
                                    stdout=subprocess.PIPE,
                                    stderr=subprocess.PIPE)
        try:
            outs, errs = proc.communicate(timeout=timeout)
        except subprocess.TimeoutExpired:
            proc.kill()
            outs, errs = proc.communicate()


    if timeout:
        worker_process = multiprocessing.Process(target=_target, args=(timeout-1,))
        worker_process.start()
        wait_for(timeout, f'Running command {cmd_list}\n')

        if worker_process.is_alive():
            worker_process.terminate()
    else:
        worker_process = multiprocessing.Process(target=_target, args=(None,))
        worker_process.start()

    return worker_process

def print_result(result):
    if result.returncode == 0:
        print(result.stdout.decode('utf-8'))
    else:
        print(result.stdout.decode('utf-8'))
        print_red(result.stderr.decode('utf-8'))


def rand_sample(items):
    if not items:
        return []
    nr = random.randint(1, len(items))
    return random.sample(items, nr)


def wait_for(nr_second, task_name=None):
    if task_name is not None:
        print_red(task_name, no_newline=True)
    for _ in range(nr_second):
        time.sleep(1)
        print_red('.', no_newline=True)
    print('')
