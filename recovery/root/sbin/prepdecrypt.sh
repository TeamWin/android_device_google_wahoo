#!/sbin/sh

mount -t ext4 -o ro /dev/block/bootdevice/by-name/vendor_a /vendor
setprop crypto.ready 1
exit 0
