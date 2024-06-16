import subprocess



class StopAllContainer:
    
    def __init__(self):
        pass
    

if __name__ == '__main__':
    exec_res = subprocess.run(["docker", "container", "ls"], capture_output=True, text=True, check=True)
    print(exec_res.stdout)
    
    # exec_res = subprocess.check_output(["docker", "container", "ls"], shell=True)
    # stdout = exec_res.stdout