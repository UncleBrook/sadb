#!/usr/bin/env bash

# ==============================================================================
# sadb Final Professional Test Suite
# ==============================================================================

# 加载待测脚本
source ./sadb

# 清理颜色以方便匹配字符串
c_green="" c_error="" c_cyan="" c_yellow="" c_bold="" c_reset=""

# --- 辅助函数: 断言 ---
assert_eq() {
    if [[ "$1" == "$2" ]]; then
        printf "  ${c_green}[PASS]${c_reset} Expected: %s, Got: %s\n" "$2" "$1"
    else
        printf "  ${c_error}[FAIL]${c_reset} Expected: %s, Got: %s\n" "$2" "$1"
        return 1
    fi
}

# --- 测试用例 1: 多样化设备行解析 ---
test_parse_device_variants() {
    echo ">>> Testing parse_device with different statuses..."
    parse_device "sn001    device product:p1 model:m1 device:d1"
    assert_eq "${dic_device[sn]}" "sn001"
    assert_eq "${dic_device[device_type]}" "device"
    
    parse_device "sn002    unauthorized usb:1-1"
    assert_eq "${dic_device[sn]}" "sn002"
    assert_eq "${dic_device[device_type]}" "unauthorized"
}

# --- 测试用例 2: 别名与空格清洗解析 ---
test_config_trimming() {
    echo ">>> Testing read_alias with whitespace trimming..."
    local test_dir="/tmp/sadb_test_config"
    mkdir -p "$test_dir"
    
    echo "  my_alias  =  shell getprop ro.product.model  " > "$test_dir/.alias"
    local old_config="$config"
    config="$test_dir/"
    
    read_alias
    
    assert_eq "${alias[my_alias]}" "shell getprop ro.product.model"

    rm -rf "$test_dir"
    config="$old_config"
}

# --- 测试用例 3: 核心逻辑分发 Mock 测试 ---
test_main_mocking() {
    echo ">>> Testing main command mocking..."
    
    # 这里的 adb 函数会拦截 command adb 调用
    adb() {
        MOCK_ADB_CALLED_WITH="$*"
    }
    
    main version
    assert_eq "$MOCK_ADB_CALLED_WITH" "version"

    main connect 127.0.0.1
    assert_eq "$MOCK_ADB_CALLED_WITH" "connect 127.0.0.1"
    
    unset -f adb
}

# --- 运行所有测试 ---
echo "------------------------------------------------"
echo "Starting sadb Final Tests"
echo "------------------------------------------------"

test_parse_device_variants || exit 1
test_config_trimming || exit 1
test_main_mocking || exit 1

echo "------------------------------------------------"
echo "🎉 ALL TESTS PASSED SUCCESSFULLY!"
echo "------------------------------------------------"
