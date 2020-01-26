import M4
import subprocess
import multiprocessing
import re


class Qemu:
    def __init__(self):
        pass

    def start(self):
        M4.print_blue('Start qemu daemon')

        def target():
            command_process = subprocess.Popen(['./ctrl', 'start'],
                                               stdout=subprocess.PIPE,
                                               stderr=subprocess.PIPE)
            command_process.communicate()

        self.qemu_thread = multiprocessing.Process(target=target)
        self.qemu_thread.start()

        M4.wait_for(25, 'Starting qemu')
        if not self.log_contain(['syzkaller login:']):
            M4.print_red('Qemu starting failure')

            subprocess.Popen(['./ctrl', 'stop']).communicate()
            return

        M4.print_blue('=================')
        subprocess.Popen(['./ctrl', 'init']).communicate()
        M4.print_blue('... ending')

    def stop(self):
        M4.print_red('Stop qemu daemon', no_newline=True)

        subprocess.Popen(['./ctrl', 'stop']).communicate()

        if self.qemu_thread.is_alive():
            self.qemu_thread.terminate()

        M4.print_red('... ending')

    def log_contain(self, keywords):
        M4.exec(['sync', './vm.log'])

        with open('./vm.log', 'r') as fd:
            for line in fd:
                for k in keywords:
                    if re.search(k, line.strip()):
                        # print(k, line)
                        return True
        return False
