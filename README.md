# sadb

+ 交互式 adb：在连接多台设备时，选择 1 台、2 台或多台设备执行相关命令
+ 支持设置 `adb alias`

### 使用
```
$ sudo cp ./sadb /usr/bin/
$ sudo chmod a+x /usr/bin/sadb
```
在 `~/.bashrc` 中添加 `alias`
```
alias adb="sadb"
```

### 要求
- `bash` 版本需要高于 v3.2
  > 1. 低于 v4.x 的版本不支持 `declare -A`
  > 2. `bash --version`  查看 bash 版本


### TODO
- [x] ~~选择设备执行命令~~
- [ ] 设置 alias, `adb alias.ws 'shell wm size'`


### demo
![](https://raw.githubusercontent.com/UncleBrook/sadb/main/screenshot/demo_0.gif)




