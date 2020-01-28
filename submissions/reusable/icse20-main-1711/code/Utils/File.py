import os
import shutil


def fnameList(path, list_name):
    for file in os.listdir(path):
        file_path = os.path.join(path, file)
        if os.path.isdir(file_path):
            fnameList(file_path, list_name)
        else:
            list_name.append(file_path)

def create_dir(dirname):
    path = os.getcwd() + '/' + dirname
    folder = os.path.exists(path)
    if not folder:
        os.makedirs(path)
    return path+"/"

class fdelete(object):
    def __init__(self):
        self.dir = os.getcwd()

    def deleteDir(self, ext, dir='default'):
        if dir == 'default':
            dir = self.dir
        for name in os.listdir(dir):
            if ext in name:
                #print(dir + name)
                shutil.rmtree(dir + '/' + name)