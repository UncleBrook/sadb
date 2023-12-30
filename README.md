# sadb

+ Interactive adb: when connecting multiple devices, select 1, 2 or more devices to execute a command
+ Support for setting alias (e.g. `adb alias.topActivity "shell dumpsys activity top | grep ACTIVITY"`)
+ Support for execute alias (e.g. `adb topActivity`)

## Installation

```shell
$ sudo su
$ curl https://raw.githubusercontent.com/darren109/sadb/main/sadb > /usr/bin/sadb && sudo chmod a+x /usr/bin/sadb
```
or 
```shell
$ git clone https://github.com/darren109/sadb.git ~/sadb
$ sudo mv ~/sadb/sadb /usr/bin/ && sudo chmod a+x /usr/bin/sadb && rm -rf ~/sadb
```
and then add `alias adb="sadb"` to `~/.bashrc` or `~/.bash_profile`


## Requirements

- `bash` version needs to be greater than v3.2
  > 1. `declare -A` is not supported before v3.2
  > 2. `bash --version` to view bash version

### demo
![](./screenshot/demo_0.gif)




