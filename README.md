# log2file

此库将Android logcat与内核日志写入文件保存，方便系统debug之用。

## 使用
#### 1. 将log2file目录copy至vendor/rockchip/common/下
```
shenhb@dqrd01:~/code/topband_rk3128/vendor/rockchip/common/log2file$ tree
.
├── Android.mk
├── log2file.mk
└── log2file.sh
```
#### 2. 修改device/rockchip/common/init.rockchip.rc，增加下面代码：
```
#log2file
service log2file /system/xbin/log2file.sh
    class late_start
    user root
    group media_rw
```
#### 3. 修改vendor/rockchip/common/BoardConfigVendor.mk，增加下面代码：
```
PRODUCT_HAVE_LOG2FILE ?= true
```
#### 4. 修改vendor/rockchip/common/device-vendor.mk，增加下面代码：
```
ifeq ($(PRODUCT_HAVE_LOG2FILE),true)
$(call inherit-product-if-exists, vendor/rockchip/common/log2file/log2file.mk)
endif
```