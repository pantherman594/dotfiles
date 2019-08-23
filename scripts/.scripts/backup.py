#!/usr/bin/python3

from datetime import datetime
import time
import os
import subprocess

SNAPSHOTS_DIR = '/backups/.snapshots'
LAST_BACKUP_FILE = '{}/.lastbackup'.format(SNAPSHOTS_DIR)


def backup(level):
    if level == 'sync':
        print("Syncing backups...")
    else:
        print("Rotating level {}...".format(level))
    subprocess.call(['/usr/bin/rsnapshot', level])


if os.geteuid() is not 0:
    print("Please run as root.")
    raise SystemExit()

print("Waiting for snapshot root...")
notification_hr = 21
while not os.path.isdir(SNAPSHOTS_DIR):
    curr_time = datetime.now()
    if curr_time.hour == 21 and curr_time.minute < 30:
        raise SystemExit()
    if curr_time.hour == notification_hr:
        subprocess.call('sudo -u pantherman594 DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/501/bus notify-send \'backup.py\' \'Plug in external hard drive to start backup.\'', shell=True)
        notification_hr = (notification_hr + 1) % 24
    time.sleep(60)

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
