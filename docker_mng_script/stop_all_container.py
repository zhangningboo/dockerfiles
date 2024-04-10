import subprocess
from typing import List
from tqdm import tqdm


class StopAllContainer:
    
    def __init__(self):
        pass
    
    def exec_cmd(self, cmd: List) -> str:
        exec_res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        if exec_res.returncode == 0:
            return exec_res.returncode, exec_res.stdout
        else:
            return exec_res.returncode, exec_res.stderr
        
    def query_running_container(self) -> List:
        cmd = ["docker", "container", "ls", "-q"]
        code, info = self.exec_cmd(cmd)
        if code == 0:
            return info.split('\n')
        else:
            print(f'Execute command failed: {cmd = }, {info = }')
            return []
        
    def stop_containers(self, container_ids: List):
        if len(container_ids) == 0:
            return
        for container_id in tqdm(container_ids):
            if container_id == '':
                continue
            cmd = ["docker", "stop", container_id]
            code, info = self.exec_cmd(cmd)
            if code != 0:
                print(f'Stop container failed: {cmd = }, {info = }')
                break

if __name__ == '__main__':
    stop_container = StopAllContainer()
    containers = stop_container.query_running_container()
    print(containers)
    stop_container.stop_containers(containers)
