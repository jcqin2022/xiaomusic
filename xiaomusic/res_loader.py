import os
import logging

def get_resource_path(file_name):
    #current_dir = os.path.dirname(os.path.abspath(__file__))
    current_dir = os.path.dirname(os.path.abspath(file_name))
    print(f"current dir - {file_name}: {current_dir}")
    relative_path = os.path.join(file_name)
    file_path = os.path.join(current_dir, relative_path)
    return file_path