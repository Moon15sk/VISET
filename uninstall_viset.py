import os
import shutil
import subprocess
import time
import sys

PROGRAMDATA = os.environ.get('PROGRAMDATA', r'C:\ProgramData')
VISET_DATA = os.path.join(PROGRAMDATA, 'Viset')
PROG_FILES_DIR = os.path.join(os.environ.get('ProgramFiles', r'C:\Program Files'), 'Viset')
SERVICE_NAME = 'VisetService'
DRIVER_SERVICE_NAME = 'VisetDriver'

def log(msg):
    print(f"[uninstall] {msg}")

def stop_and_delete_service(name):
    try:
        subprocess.run(['sc', 'stop', name], check=False)
    except Exception as e:
        log(f"Failed to stop {name}: {e}")
    try:
        subprocess.run(['sc', 'delete', name], check=False)
    except Exception as e:
        log(f"Failed to delete {name}: {e}")

def remove_path(path):
    try:
        if os.path.exists(path):
            if os.path.isfile(path):
                os.remove(path)
            else:
                shutil.rmtree(path)
            log(f'Removed {path}')
        else:
            log(f'Path not found: {path}')
    except Exception as e:
        log(f'Error removing {path}: {e}')

def main():
    print('Viset Uninstaller')
    print('This will stop services and remove Viset files from this machine.')
    ans = input('Proceed? (y/N): ').strip().lower()
    if ans != 'y':
        print('Aborted')
        return

    # Stop and delete services
    stop_and_delete_service(SERVICE_NAME)
    stop_and_delete_service(DRIVER_SERVICE_NAME)

    # Remove Program Files installation
    remove_path(PROG_FILES_DIR)

    # Remove ProgramData Viset
    remove_path(VISET_DATA)

    # Remove build/dist from repository if present
    repo_build = os.path.join(os.path.dirname(__file__), 'build')
    remove_path(repo_build)

    # Optionally remove driver file from system32\drivers
    try:
        drivers_folder = os.path.join(os.environ.get('SystemRoot', r'C:\Windows'), 'System32', 'drivers')
        driver_sys = os.path.join(drivers_folder, 'viset.sys')
        if os.path.exists(driver_sys):
            try:
                os.remove(driver_sys)
                log(f'Removed driver file: {driver_sys}')
            except Exception as e:
                log(f'Could not remove driver file (might require reboot/admin): {e}')
        else:
            log('Driver file not found in system drivers folder')
    except Exception as e:
        log(f'Error while attempting to remove driver file: {e}')

    print('Uninstall completed. You may need to reboot to finalize driver removal.')
    time.sleep(2)

if __name__ == '__main__':
    main()
