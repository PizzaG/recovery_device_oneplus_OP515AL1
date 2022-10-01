#!/system/bin/sh

touch_class_path=/sys/kernel/oplus_display
touch_path=/sys/class/touchscreen/primary
firmware_path=/vendor/firmware
firmware_file=FW_GT9886_SAMSUNG.img

device=$(getprop ro.boot.device)

wait_for_poweron()
{
	local wait_nomore
	local readiness
	local count
	wait_nomore=60
	count=0
	while true; do
		readiness=$(cat $touch_path/poweron)
		if [ "$readiness" == "1" ]; then
			break;
		fi
		count=$((count+1))
		[ $count -eq $wait_nomore ] && break
		sleep 1
	done
	if [ $count -eq $wait_nomore ]; then
		return 1
	fi
	return 0
}
cd $firmware_path
touch_product_string=$(ls $touch_class_path)
if [[ -d /sys/kernel/oplus_display ]]; then
       echo "goodix"
       firmware_file="FW_GT9886_SAMSUNG.img"
       touch_path=/sys$(cat $touch_class_path/$touch_product_string/path | awk '{print $1}')
       wait_for_poweron
       echo $firmware_file > $touch_path/doreflash
       echo 1 > $touch_path/forcereflash
       sleep 5
       echo 1 > $touch_path/reset
elif [[ -d /sys/kernel/oplus_display ]]; then
        echo "goodix"
        firmware_file="FW_GT9886_SAMSUNG.img"
        echo 1 > /proc/nvt_update
fi

sleep 10

# A-Team Custom Patches
svc usb setFunctions mtp
mount -o rw /system_root
mount -o rw /system_ext
mount -o rw /product
mount -o rw /vendor

exit
