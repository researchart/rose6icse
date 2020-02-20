#!/bin/sh
print_usage()
{
	echo "Usage: $0 RUN_TYPE [PARAMETERS]"
}

boot_windowed()
{
	echo "Interaction with the Android device needed, running in windowed mode"
	adb emu kill
	sleep 5
	./emulator.sh >emulator_log.txt 2>&1 &
	echo "Wait for emulator to boot"
	sleep 5
	status=$(adb shell getprop sys.boot_completed | tr -d '\r' | tr -d '\n')
	while [ "$status" != "1"  ];
	do
		sleep 2
		status=$(adb shell getprop sys.boot_completed | tr -d '\r' | tr -d '\n')
	done
	echo "Emulator boot complete"
}

boot_nw()
{
	echo "No interaction with the Android device needed, running in no-window mode to increase the speed"
	adb emu kill
	sleep 5
	./emulator_nw.sh >emulator_log.txt 2>&1 &
	echo "Wait for emulator to boot"
	sleep 5
	status=$(adb shell getprop sys.boot_completed | tr -d '\r' | tr -d '\n')
	while [ "$status" != "1"  ];
	do
		sleep 2
		status=$(adb shell getprop sys.boot_completed | tr -d '\r' | tr -d '\n')
	done
	echo "Emulator boot complete"
}

###
# Main body
###
now=$(date +%Y%m%d%H%M%S)
if [ "$1" = "running-example" ];
then
	boot_windowed
	rm -rf /home/combodroid/results_$1_$now 
	mkdir /home/combodroid/result_$1_$now
	cd artifact
	bash -x ComboDroid.sh "/home/combodroid/Config_runningExample.txt -v --no-startup" | tee /home/combodroid/result_$1_$now/Log.txt
	cp /home/combodroid/artifact/Coverage.xml /home/combodroid/result_$1_$now/Coverage.xml
	adb emu kill
	exit 0
	exit 0
fi
if [ "$#" -lt 1  ]; 
then
	echo "Error: Not enough argument"
	print_usage
	adb emu kill
	exit 1
fi

re='^[0-9]+$'
echo $1 | egrep $re >/dev/null 2>&1
if [ "$?" -ne "0"  ] ;
then
	echo "Error: RUN_TYPE must be a non-negative number"
	print_usage
	adb emu kill
	exit 1
fi


rm -f /home/combodroid/artifact/Coverage.xml

if [ $1 -eq 0 ];
then
	echo $2
	type=$(cat $2 | grep ComboDroid-type | cut -d'=' -f2 | xargs)
	mkdir -p artifact/traces/traces
	mkdir -p artifact/traces/layouts
	boot_windowed
	rm -rf /home/combodroid/results_$1_$now 
	mkdir /home/combodroid/result_$1_$now
	cd artifact
	bash -x ComboDroid.sh "$2 -v" | tee /home/combodroid/result_$1_$now/Log.txt
	cp /home/combodroid/artifact/Coverage.xml /home/combodroid/result_$1_$now/Coverage.xml
	adb emu kill
	exit 0
fi
if [ $1 -lt 1 -o $1 -gt 17 ];
then
	echo "Error: wronly specified RUN_TYPE"
fi

boot_nw
rm -rf /home/combodroid/results_$1_$2_$now 
mkdir /home/combodroid/result_$1_$2_$now
cd artifact
bash scripts_$2/$1.sh | tee /home/combodroid/result_$1_$2_$now/Log.txt
cp /home/combodroid/artifact/Coverage.xml /home/combodroid/result_$1_$2_$now/Coverage.xml
adb emu kill
