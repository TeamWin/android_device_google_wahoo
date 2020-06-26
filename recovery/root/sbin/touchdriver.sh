#!/sbin/sh

finish()
{
	umount /v
	umount /s
	rmdir /v
	rmdir /s
	exit 0
}

suffix=$(getprop ro.boot.slot_suffix)
if [ -z "$suffix" ]; then
	suf=$(getprop ro.boot.slot)
	suffix="_$suf"
fi
venpath="/dev/block/bootdevice/by-name/vendor$suffix"
mkdir /v
mount -t ext4 -o ro "$venpath" /v
# Pixel 2 walleye modules
insmod /v/lib/modules/synaptics_dsx_core_htc.ko
insmod /v/lib/modules/htc_battery.ko

# Pixel 2 XL taimen modules
insmod /v/lib/modules/touch_core_base.ko
insmod /v/lib/modules/ftm4.ko
insmod /v/lib/modules/lge_battery.ko

