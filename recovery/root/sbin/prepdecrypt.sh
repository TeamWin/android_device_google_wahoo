#!/sbin/sh

relink()
{
	fname=$(basename "$1")
	target="/sbin/$fname"
	sed 's|/system/bin/linker64|///////sbin/linker64|' "$1" > "$target"
	chmod 755 $target
}

finish()
{
	umount /v
	umount /s
	rmdir /v
	rmdir /s
	setprop crypto.ready 1
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
syspath="/dev/block/bootdevice/by-name/system$suffix"
mkdir /s
mount -t ext4 -o ro "$syspath" /s

# Pixel 2 walleye modules
insmod /v/lib/modules/synaptics_dsx_core_htc.ko
insmod /v/lib/modules/htc_battery.ko

# Pixel 2 XL taimen modules
insmod /v/lib/modules/touch_core_base.ko
insmod /v/lib/modules/ftm4.ko
insmod /v/lib/modules/lge_battery.ko

device_codename=$(getprop ro.boot.hardware)
is_fastboot_twrp=$(getprop ro.boot.fastboot)
if [ ! -z "$is_fastboot_twrp" ]; then
    if [ "$device_codename" == "walleye" ]; then
		# Note, this method only works on walleye as taimen still fetches the OS / patch information from the active boot slot even when fastboot booting
		# Be sure to increase the PLATFORM_VERSION in build/core/version_defaults.mk to override Google's anti-rollback features to something rather insane
		osver=$(getprop ro.build.version.release_orig)
		patchlevel=$(getprop ro.build.version.security_patch_orig)
		setprop ro.build.version.release "$osver"
		setprop ro.build.version.security_patch "$patchlevel"
		finish
	fi
fi

if [ -f /s/system/build.prop ]; then
	# TODO: It may be better to try to read these from the boot image than from /system
	osver=$(grep -i 'ro.build.version.release' /s/system/build.prop  | cut -f2 -d'=')
	patchlevel=$(grep -i 'ro.build.version.security_patch' /s/system/build.prop  | cut -f2 -d'=')
	setprop ro.build.version.release "$osver"
	setprop ro.build.version.security_patch "$patchlevel"
	finish
else
	# Be sure to increase the PLATFORM_VERSION in build/core/version_defaults.mk to override Google's anti-rollback features to something rather insane
    osver=$(getprop ro.build.version_orig)
    patchlevel=$(getprop ro.build.version.security_patch_orig)
	setprop ro.build.version.release "$osver"
	setprop ro.build.version.security_patch "$patchlevel"
	finish
fi

###### NOTE: The below is no longer used but I'm keeping it here in case it is needed again at some point!
mkdir /vendor
mkdir -p /odm/lib64/hw
mkdir -p odm/firmware/ese/prodkeys/
mkdir -p odm/firmware/ese/testkeys/
mkdir -p /system/etc
cp /event-log-tags /system/etc/event-log-tags
cp /s/system/etc/event-log-tags /system/etc/event-log-tags
relink /v/bin/qseecomd
cp /v/lib64/libdiag.so /sbin/
cp /v/lib64/libdrmfs.so /sbin/
cp /v/lib64/libdrmtime.so /sbin/
cp /v/lib64/libQSEEComAPI.so /sbin/
cp /v/lib64/librpmb.so /sbin/
cp /v/lib64/libssd.so /sbin/
cp /v/lib64/libtime_genoff.so /sbin/
cp /v/lib64/libgptutils.so /sbin/
cp /v/lib64/libkeymasterdeviceutils.so /sbin/
cp /v/etc/selinux/nonplat_hwservice_contexts /
cp /v/etc/selinux/nonplat_service_contexts /
cp /s/system/etc/selinux/plat_hwservice_contexts /
cp /s/system/etc/selinux/plat_service_contexts /
cp /v/manifest.xml /vendor/
cp /v/compatibility_matrix.xml /vendor/
cp /v/lib64/hw/android.hardware.boot@1.0-impl.so /odm/lib64/hw/
cp /v/lib64/hw/android.hardware.gatekeeper@1.0-impl-qti.so /odm/lib64/hw/
cp /v/lib64/hw/android.hardware.keymaster@3.0-impl-qti.so /odm/lib64/hw/
cp /v/lib64/hw/bootctrl.msm8998.so /odm/lib64/hw/
relink /v/bin/esed
# esed_load is needed but it's a shell script and we need a few small changes applied
relink /v/bin/ese-ls-provision
cp /s/system/lib64/android.hardware.weaver@1.0.so /sbin/
cp /v/lib64/libp61-jcop-kit.so /sbin/
cp /v/lib64/libese-app-boot.so /sbin/
cp /v/lib64/libese-app-weaver.so /sbin/
cp /v/lib64/libese_cpp_nxp_pn80t_nq_nci.so /sbin/
cp /v/lib64/libese-hw-nxp-pn80t-nq-nci.so /sbin/
cp /v/lib64/libese.so /sbin/
cp /v/lib64/libese-sysdeps.so /sbin/
cp /v/lib64/libese-teq1.so /sbin/
cp /v/firmware/ese/prodkeys/ese.f000.prodkeys /odm/firmware/ese/prodkeys/
cp /v/firmware/ese/prodkeys/ese.f102.prodkeys /odm/firmware/ese/prodkeys/
cp /v/firmware/ese/prodkeys/ese.f200.prodkeys /odm/firmware/ese/prodkeys/
cp /v/firmware/ese/prodkeys/ese.f201.prodkeys /odm/firmware/ese/prodkeys/
cp /v/firmware/ese/prodkeys/ese.shadata.prodkeys /odm/firmware/ese/prodkeys/
cp /v/firmware/ese/testkeys/ese.f000.testkeys /odm/firmware/ese/testkeys/
cp /v/firmware/ese/testkeys/ese.f102.testkeys /odm/firmware/ese/testkeys/
cp /v/firmware/ese/testkeys/ese.f200.testkeys /odm/firmware/ese/testkeys/
cp /v/firmware/ese/testkeys/ese.f201.testkeys /odm/firmware/ese/testkeys/
cp /v/firmware/ese/testkeys/ese.shadata.testkeys /odm/firmware/ese/testkeys/
relink /v/bin/hw/android.hardware.keymaster@3.0-service-qti
relink /v/bin/hw/android.hardware.boot@1.0-service
relink /v/bin/hw/android.hardware.gatekeeper@1.0-service-qti

finish
exit 0
