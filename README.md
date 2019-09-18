# Android-log2file

This library saves Android logcat and kernel logs to a file for easy system debugging.

## Usage
1. Copy the log2file directory to vendor/rockchip/common/
```
shenhb@dqrd01:~/android/vendor/rockchip/common/log2file$ tree
.
├── Android.mk
├── log2file.mk
└── log2file.sh
```
2. Modify device/rockchip/common/init.rockchip.rc and add the following code:
```
#log2file
service log2file /system/xbin/log2file.sh
    class late_start
    user root
    group media_rw
```
3. Modify vendor/rockchip/common/BoardConfigVendor.mk and add the following code:
```
PRODUCT_HAVE_LOG2FILE ?= true
```
4. Modify vendor/rockchip/common/device-vendor.mk and add the following code:
```
ifeq ($(PRODUCT_HAVE_LOG2FILE),true)
$(call inherit-product-if-exists, vendor/rockchip/common/log2file/log2file.mk)
endif
```

### For SEAndroid
1. Modify device/rockchip/common/init.rockchip.rc and add the following code:
```   
#log2file
service log2file /system/xbin/log2file.sh
    class late_start
    user root
    group media_rw
    oneshot
```
2. Modify device/rockchip/common/sepolicy/file_contexts and add the following code:
```
# for log2file
/system/xbin/log2file.sh            u:object_r:log2file_exec:s0
```
3. Modify device/rockchip/common/sepolicy/init.te and add the following code:
```
domain_trans(init, log2file_exec, log2file)
```
4. Add device/rockchip/common/sepolicy/log2file.te file.
```
type log2file, domain, coredomain, mlstrustedsubject;
type log2file_exec, exec_type, vendor_file_type, file_type;
init_daemon_domain(log2file)
```
