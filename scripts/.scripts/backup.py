#!/usr/bin/python3

from datetime import datetime
import time
import os
import subprocess

LAST_BACKUP_FILE = '/home/pantherman594/.lastbackup'


def backup(level):
    if level == 'sync':
        print("Syncing backups...")
    else:
        print("Rotating level {}...".format(level))
    subprocess.call(['/usr/bin/rsnapshot', level])


print("Waiting for snapshot root...")
while not os.path.isdir('/backups/.snapshots'):
    time.sleep(60)
    curr_time = datetime.now()
    if curr_time.hour is 23 and curr_time.minute < 30:
        raise SystemExit()

print("Snapshot root found. Starting backup cycler...")
try:
    with open(LAST_BACKUP_FILE, 'r') as f:
        alpha = int(f.readline())
        beta = int(f.readline())
except Exception:
    alpha = 0
    beta = 0

backup_stack = []  # stack to reverse orders
backup_stack.append('alpha')
backup_stack.append('sync')  # sync before rotating alpha, to rotate the sync into alpha
alpha += 1
if alpha > 5:
    backup_stack.append('beta')
    alpha = 0
    beta += 1
if beta > 5:
    backup_stack.append('gamma')
    beta = 0

while len(backup_stack) > 0:
    backup(backup_stack.pop())

with open(LAST_BACKUP_FILE, 'w') as f:
    f.write('{}\n{}'.format(alpha, beta))

print("Backups complete.")
