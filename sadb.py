#!/usr/bin/env python3
import os
import subprocess
import sys

# 设置颜色
c_green = '\033[92m'
c_reset = '\033[0m'

# 获取 adb 命令的位置
adb = subprocess.getoutput('which adb')
config = os.path.join(os.path.expanduser('~'), '.config/sadb/')
os.makedirs(config, exist_ok=True)

alias_file = os.path.join(config, '.alias')
if not os.path.exists(alias_file):
    open(alias_file, 'a').close()

alias = {}

def read_alias():
    with open(alias_file, 'r') as f:
        for line in f:
            if '=' in line:
                key, value = line.strip().split('=', 1)
                alias[key] = value

def exec_adb(serial_number, adb_args):
    real_args = alias.get(adb_args[0], ' '.join(adb_args))
    cmd = f"{adb} -s {serial_number} {real_args}"
    print(f"\n{c_green}{adb} {c_reset}-s {serial_number} {real_args}\n", file=sys.stderr)
    subprocess.run(cmd, shell=True)
    print("\n", file=sys.stderr)

def choose_device(devices, adb_args):
    device_lines = devices.splitlines()[1:]  # Skip the first line which is a header
    device_count = len(device_lines)
    total_line = device_count

    tips = f"More than one device/emulator, please select {c_green}[0 .. {total_line-1}]{c_reset} or {c_green}[a/A]{c_reset}: "
    
    while True:
        num = input(tips)
        if num.isdigit() and 0 <= int(num) < total_line:
            serial_number = parse_device(device_lines[int(num)])['sn']
            exec_adb(serial_number, adb_args)
            break
        elif num.lower() == 'a':
            for line in device_lines:
                serial_number = parse_device(line)['sn']
                exec_adb(serial_number, adb_args)
            break

def print_devices(adb_args):
    devices = subprocess.getoutput(f"{adb} devices -l")
    device_count = len(devices.splitlines())
    device_lines = devices.splitlines()[1:]

    if device_count <= 2:
        sn = parse_device(device_lines[0])['sn']
        exec_adb(sn, adb_args)
        sys.exit(0)
    else:
        print(devices.splitlines()[0], file=sys.stderr)
        for num, line in enumerate(devices.splitlines()[1:]):
            dic_device = parse_device(line)
            print(f"{c_green}[ {num} ]{c_reset} sn: {dic_device['sn']:<20} {dic_device['device_type']:<16} model: {dic_device['model']:<20} product: {dic_device['product']}", file=sys.stderr)

def parse_device(device):
    parts = device.split()
    dic_device = {'sn': parts[0], 'device_type': parts[1], 'model': '', 'product': ''}
    for part in parts[2:]:
        if ':' in part:
            key, value = part.split(':', 1)
            dic_device[key] = value
    return dic_device

def main(adb_args):
    if not adb_args:
        print("No command provided. Use -h or --help for usage information.")
        sys.exit(1)

    local_cmds = {'-s', 'start-server', 'kill-server', 'disconnect', 'connect'}
    
    if adb_args[0] in local_cmds:
        subprocess.run([adb] + adb_args)
    elif adb_args[0] == 'devices':
        if len(adb_args) == 1:
            subprocess.run([adb] + adb_args + ['-l'])
        else:
            subprocess.run([adb] + adb_args)
    elif adb_args[0] == 'alias' and (len(adb_args) > 1 and (adb_args[1] == '-h' or adb_args[1] == '--help')):
        print_help()
    elif adb_args[0].startswith('alias.'):
        adb_alias(adb_args)
    else:
        devices = subprocess.getoutput(f"{adb} devices -l")
        print_devices(adb_args)
        choose_device(devices, adb_args)

def print_help():
    print("Usage: adb alias.[alias] [command]")

def adb_alias(adb_args):
    with open(alias_file, 'a') as f:
        f.write(f"{adb_args[0].split('.')[1]}={' '.join(adb_args[1:])}\n")

if __name__ == "__main__":
    read_alias()
    main(sys.argv[1:])