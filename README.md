# sadb

+ Interactive adb: when connecting multiple devices, select 1, 2 or more devices to execute a command
+ Support for setting alias (e.g. `adb alias.topActivity "shell dumpsys activity top | grep ACTIVITY"`)

## Installation-sadb

```shell
$ sudo su
$ curl https://raw.githubusercontent.com/UncleBrook/sadb/main/sadb > /usr/bin/sadb && sudo chmod a+x /usr/bin/sadb
```

or

```shell
$ git clone https://github.com/UncleBrook/sadb.git ~/sadb
$ sudo mv ~/sadb/sadb /usr/bin/ && sudo chmod a+x /usr/bin/sadb && rm -rf ~/sadb
```

or

```shell
$ su
$ curl https://raw.githubusercontent.com/UncleBrook/sadb/main/install.sh | bash
```

and then add `alias adb="sadb"` to `~/.bashrc` or `~/.bash_profile`

## Installation-sadb-completion

`bash`

```shell
$ sudo cp ./sadb-completion.bash /usr/share/bash-completion/completions/
```

`zsh` 

```shell
$ sudo cp ./sadb-completion.bash /usr/share/bash-completion/completions/
$ cd ~
$ vim .zshrc

# adding the following content to your .zshrc file.
source /usr/share/bash-completion/completions/sadb-completion.bash
```

## Requirements

- `bash` version needs to be greater than v3.2
  > 1. `declare -A` is not supported before v3.2
  > 2. `bash --version` to view bash version
  >

## To-do

- [X] Select a device to execute a command
- [X] Setting alias (e.g. `adb alias.ws "shell wm size"`)

## Demo

[![Demo of the sadb script](https://i.ytimg.com/vi/GebidcL_W64/maxresdefault.jpg)](https://www.youtube.com/watch?v=GebidcL_W64 "Demo of the sadb script")

