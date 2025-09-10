#!/usr/bin/env python3
"""
Check if the AFL Fantasy scheduler is running
Can also be used to stop the scheduler
"""

import os
import sys
import signal
import subprocess

def find_scheduler_pid():
    """Find the PID of the running scheduler process"""
    try:
        output = subprocess.check_output(['pgrep', '-f', 'python scheduler.py'], 
                                         stderr=subprocess.STDOUT, 
                                         universal_newlines=True)
        pids = output.strip().split('\n')
        return [int(pid) for pid in pids if pid]
    except subprocess.CalledProcessError:
        return []

def check_scheduler():
    """Check if the scheduler is running"""
    pids = find_scheduler_pid()
    
    if pids:
        print(f"Scheduler is running with PID(s): {', '.join(map(str, pids))}")
        return True
    else:
        print("Scheduler is not running")
        return False

def stop_scheduler():
    """Stop the running scheduler process"""
    pids = find_scheduler_pid()
    
    if not pids:
        print("No scheduler processes found")
        return
    
    for pid in pids:
        try:
            os.kill(pid, signal.SIGTERM)
            print(f"Sent termination signal to scheduler process {pid}")
        except OSError as e:
            print(f"Error stopping process {pid}: {e}")
    
    # Check if processes are still running
    remaining = find_scheduler_pid()
    if remaining:
        print(f"Warning: {len(remaining)} scheduler processes still running")
    else:
        print("All scheduler processes stopped successfully")

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "stop":
        stop_scheduler()
    else:
        check_scheduler()