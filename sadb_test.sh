#!/usr/bin/env bash

# ==============================================================================
# sadb Professional Test Suite
# ==============================================================================

# 加载脚本（不执行 main）
export BASH_SOURCE="./sadb"
source ./sadb

# 清理颜色标识以便匹配
c_green="" c_error="" c_cyan="" c_yellow="" c_bold="" c_reset=""

# 记录失败数
FAILED=0

# --- 断言工具 ---
assert_eq() {
    if [[ "$1" == "$2" ]]; then
        printf "  [PASS] %s\n" "$3"
    else
        printf "  [FAIL] %s\n" "$3"
        printf "    Expected: [%s]\n" "$2"
        printf "    Got:      [%s]\n" "$1"
        ((FAILED++))
    fi
}

# --- 1. 设备行解析测试 ---
test_parse_device() {
    echo ">>> Case 1: Testing Device Parse..."
    parse_device "sn123    device usb:1-1.2 product:sdk_gphone64_arm64 model:sdk_gphone64_arm64 device:emu64a transport_id:1"
    assert_eq "${dic_device[sn]}" "sn123" "Serial match"
    assert_eq "${dic_device[device_type]}" "device" "Status match"
    assert_eq "${dic_device[model]}" "sdk_gphone64_arm64" "Model match"
    
    parse_device "192.168.1.1:5555    offline"
    assert_eq "${dic_device[sn]}" "192.168.1.1:5555" "IP Serial match"
    assert_eq "${dic_device[device_type]}" "offline" "Offline status match"
}

# --- 2. 别名与方法解析测试 ---
test_alias_method_read() {
    echo ">>> Case 2: Testing Alias and Method Reading..."
    local test_dir="/tmp/sadb_test_config_$$"
    mkdir -p "$test_dir"
    cat > "${test_dir}/.alias" <<EOF
# Comments should be ignored
log = logcat -v time
   
my_func() {
    echo "hello"
    adb shell uptime
}
EOF
    # Mock config path
    local old_config="$config"
    config="${test_dir}/"
    
    read_alias
    
    assert_eq "${alias[log]}" "logcat -v time" "Alias read"
    assert_eq "${methods[my_func]}" $'    echo "hello"\n    adb shell uptime\n' "Method body read"
    
    rm -rf "$test_dir"
    config="$old_config"
}

# --- 2b. 别名写入与删除测试 ---
test_alias_write_ops() {
    echo ">>> Case 2b: Testing Alias Add/Remove Operations..."
    local test_dir="/tmp/sadb_test_write_$$"
    mkdir -p "$test_dir"
    local old_config="$config"
    config="${test_dir}/"
    touch "${config}.alias"

    # 1. 测试添加新别名
    add_alias "test_key" "test_value" > /dev/null
    assert_eq "${alias[test_key]}" "test_value" "New alias added to memory"
    grep -q "test_key=test_value" "${config}.alias"
    assert_eq "$?" "0" "New alias written to file"

    # 2. 测试覆盖已有别名 (使用 here-string 避免子 shell)
    add_alias "test_key" "new_value" <<< "y" > /dev/null
    assert_eq "${alias[test_key]}" "new_value" "Alias overwritten in memory"
    grep -q "test_key=new_value" "${config}.alias"
    assert_eq "$?" "0" "Overwritten value in file"

    # 3. 测试删除别名
    remove_alias "test_key" > /dev/null
    [[ -z "${alias[test_key]}" ]]
    assert_eq "$?" "0" "Alias removed from memory"
    grep -q "test_key=" "${config}.alias"
    [[ "$?" != "0" ]]
    assert_eq "$?" "0" "Alias removed from file"

    # 4. 测试删除方法
    cat > "${config}.alias" <<EOF
test_method() {
    echo "hello"
}
EOF
    read_alias
    assert_eq "${methods[test_method]}" $'    echo "hello"\n' "Method read before removal"
    
    remove_alias "test_method" > /dev/null
    [[ -z "${methods[test_method]}" ]]
    assert_eq "$?" "0" "Method removed from memory"
    grep -q "test_method" "${config}.alias"
    [[ "$?" != "0" ]]
    assert_eq "$?" "0" "Method removed from file"

    # 5. 测试重名冲突删除 (Alias vs Method)
    cat > "${config}.alias" <<EOF
test_key=alias_val
test_key() {
    echo "method_val"
}
EOF
    read_alias
    # 模拟选择 2 (只删除 Alias)
    remove_alias "test_key" <<< "2" > /dev/null
    read_alias
    [[ -z "${alias[test_key]}" ]]
    assert_eq "$?" "0" "Conflict: Alias removed by choice"
    [[ -n "${methods[test_key]}" ]]
    assert_eq "$?" "0" "Conflict: Method preserved"

    # 模拟选择 3 (只删除 Method)
    cat > "${config}.alias" <<EOF
test_key=alias_val
test_key() {
    echo "method_val"
}
EOF
    read_alias
    remove_alias "test_key" <<< "3" > /dev/null
    read_alias
    [[ -n "${alias[test_key]}" ]]
    assert_eq "$?" "0" "Conflict: Alias preserved"
    [[ -z "${methods[test_key]}" ]]
    assert_eq "$?" "0" "Conflict: Method removed by choice"

    rm -rf "$test_dir"
    config="$old_config"
}

# --- 3. 会话级 Active 锁定测试 ---
test_session_active() {
    echo ">>> Case 3: Testing Session-scoped Active..."
    local test_sn="SN_TEST_SESSION"
    local session_file="/tmp/sadb_active_${USER}_${PPID}"
    
    # 初始化环境
    rm -f "$session_file"
    active_device_num=-1
    adb_args=("devices") # 模拟当前命令
    
    set_active_device "$test_sn" > /dev/null
    assert_eq "$(cat "$session_file")" "$test_sn" "Active SN saved to session file"
    
    # 测试 print_devices 能否读取 (Mock adb output)
    devices=$'List of devices attached\nSN_TEST_SESSION    device product:m1 model:m1 device:d1'
    device_count=2
    
    # 模拟锁定设备已被探测到的逻辑
    ACTIVE_DEVICE="" # 确保不被环境变量干扰
    print_devices "list" > /dev/null
    assert_eq "$active_device_num" "0" "Active device detected in session"
    
    unset_active_device > /dev/null
    [[ ! -f "$session_file" ]]
    assert_eq "$?" "0" "Session file removed on unset"
}

# --- 4. 列表排序逻辑测试 ---
test_sort_logic() {
    echo ">>> Case 4: Testing Sorting Logic..."
    # 手动填充 alias
    alias=()
    alias["zebra"]="short"
    alias["apple"]="long_value"
    alias["cat"]="mid"
    
    # 获取排序后的键
    local alpha_sorted=$(printf "%s\n" "${!alias[@]}" | sort | xargs)
    assert_eq "$alpha_sorted" "apple cat zebra" "Alpha sort keys"
    
    local length_sorted=$(printf "%s\n" "${!alias[@]}" | awk '{ print length, $0 }' | sort -n | cut -d" " -f2- | xargs)
    assert_eq "$length_sorted" "cat apple zebra" "Length sort keys"
}

# --- 运行所有测试 ---
echo "------------------------------------------------"
echo "Running sadb Integrated Tests"
echo "------------------------------------------------"

test_parse_device
test_alias_method_read
test_alias_write_ops
test_session_active
test_sort_logic

echo "------------------------------------------------"
if [ $FAILED -eq 0 ]; then
    echo "✅ ALL TESTS PASSED SUCCESSFULLY!"
    exit 0
else
    echo "❌ $FAILED TEST(S) FAILED!"
    exit 1
fi
