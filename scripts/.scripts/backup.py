#!/usr/bin/python3

from datetime import datetime
from time import sleep
import os
import subprocess

SNAPSHOTS_DIR = '/backups/.snapshots'
LAST_BACKUP_FILE = '/backups/.lastbackup'
LOCK_FILE = '/backups/backup.lock'

def rsync(source, destination, *extraFlags, compress=True):
    flags = '-a'

    if compress:
        flags += 'z'

    subprocess.call(['rsync', flags, *extraFlags, '--delete', '--inplace', '--numeric-ids', '--acls', '--xattrs',
                     source, destination])

def backup():
    rsync('/boot/', '/backups/.sync/brijuni/boot', compress=False)
    rsync('/data/', '/backups/.sync/brijuni/data', '--exclude="90-99 Misc/93 VMs/93.12 OSX-KVM/mac_hdd_ng.img"', compress=False)
    subprocess.call(['/usr/bin/mkdir', '-p', '/backups/.sync/brijuni/windows/Users/david'])
    rsync('/windows/Users/david/', '/backups/.sync/brijuni/windows/Users/david', '--exclude=AppData/Local/Microsoft/WindowsApps/MicrosoftEdge.exe', compress=False)

    subprocess.call(['/usr/bin/mkdir', '-p', '/backups/.sync/culatra/root/var'])
    rsync('root@ssh.pantherman594.com:/root', '/backups/.sync/culatra/root/')
    rsync('root@ssh.pantherman594.com:/home', '/backups/.sync/culatra/root/')
    rsync('root@ssh.pantherman594.com:/var/lib', '/backups/.sync/culatra/root/var/')
    rsync('root@ssh.pantherman594.com:/var/www', '/backups/.sync/culatra/root/var/')
    rsync('root@ssh.pantherman594.com:/etc', '/backups/.sync/culatra/root/')

    # rrsync already restricted to /opt/backup/. Path here is relative to that.
    rsync('root@mail.pantherman594.com:/', '/backups/.sync/mail/root')

    subprocess.call(['/usr/bin/mkdir', '-p', '/backups/pkgs'])
    timestamp = datetime.now().strftime('%Y%m%dT%H%M')

    subprocess.call('/usr/bin/pacman -Qqen > /backups/pkgs/brijuni_native.{}'.format(timestamp), shell=True)
    subprocess.call('/usr/bin/pacman -Qqem > /backups/pkgs/brijuni_aur.{}'.format(timestamp), shell=True)
    subprocess.call('sudo -u pantherman594 ssh ssh.pantherman594.com "/usr/bin/pacman -Qqen" > /backups/pkgs/culatra_native.{}'.format(timestamp), shell=True)
    subprocess.call('sudo -u pantherman594 ssh ssh.pantherman594.com "/usr/bin/pacman -Qqem" > /backups/pkgs/culatra_aur.{}'.format(timestamp), shell=True)

    return True

if __name__ == '__main__':
    if os.geteuid() != 0:
        print('Please run as root.')
        raise SystemExit()

    curr_time = datetime.now()

    try:
        with open(LAST_BACKUP_FILE, 'r') as f:
            lastbackup = int(f.readline())
    except Exception:
        lastbackup = 0

    should_notify = curr_time.hour >= 20 and curr_time.timestamp() - lastbackup > 12*60*60
    locked = False
    success = False

    print('Checking for snapshot root...')
    dir_first_exists = os.path.isdir(SNAPSHOTS_DIR)
    if not dir_first_exists:
        if should_notify:
            subprocess.call('sudo -u pantherman594 DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send \'backup.py\' \'Plug in external hard drive to start backup.\' -t 60000', shell=True)
            sleep(5 * 60)

    if dir_first_exists or (should_notify and os.path.isdir(SNAPSHOTS_DIR)):
        if os.path.exists(LOCK_FILE):
            print('Lock file exists. Exiting...')
            raise SystemExit()

        with open(LOCK_FILE, 'x') as f:
            locked = True

        print('Starting sync...')
        success = backup()

    print('Starting backup...')
    # Create snapshots regardless of whether drive is mounted.
    subprocess.call(['/usr/bin/btrbk', '-q', 'run'])

    if success:
        with open(LAST_BACKUP_FILE, 'w') as f:
            f.write(str(int(datetime.now().timestamp())))

        print("Backups complete.")
        if should_notify:
            subprocess.call('sudo -u pantherman594 DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send \'backup.py\' \'Backups complete.\' -t 60000', shell=True)

    if locked:
        os.remove(LOCK_FILE)
