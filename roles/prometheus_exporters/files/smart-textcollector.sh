#!/bin/bash

set -o errexit
set -o nounset

if (( $# != 1 )); then
  echo "Missing textcollector directory argument"
  exit 1
fi

TEXTFILE_COLLECTOR_DIR=${1}
PROM_FILE=$TEXTFILE_COLLECTOR_DIR/smart.prom

TMP_FILE=$PROM_FILE.$$
[ -e $TMP_FILE ] && rm -f $TMP_FILE

trap "rm -f $TMP_FILE" EXIT

# Metric types
echo "# HELP smart_device_smart_healthy SMART metric device_smart_healthy" >> $TMP_FILE
echo "# TYPE smart_device_smart_healthy gauge" >> $TMP_FILE

echo "# HELP smart_temperature_celsius SMART metric temperature_celsius" >> $TMP_FILE
echo "# TYPE smart_temperature_celsius gauge" >> $TMP_FILE

echo "# HELP smart_device_info Device information, family/model name" >> $TMP_FILE
echo "# TYPE smart_device_info gauge" >> $TMP_FILE

echo "# HELP smart_device_self_test Self test status" >> $TMP_FILE
echo "# TYPE smart_device_self_test gauge" >> $TMP_FILE

devices="$(smartctl --scan-open --json)"
devices_total="$(echo $devices | jq '.devices | length')"

for ((i=0; i < $devices_total; i++)); do
	disk=$(echo $devices | jq -r ".devices[${i}].name")
	type=$(echo $devices | jq -r ".devices[${i}].type")

	# The smartctl call may exit with code 64 if "the device error log contains
	# records of errors" but we don't want to exit due to errexit, so ignore it.
	ret=0; info=$(smartctl -a --json $disk) || ret=$?
	(( ret == 0 )) || (( ret == 64 )) || exit $ret

	status=$(echo $info | jq '.smart_status.passed')
	if [[ "$status" == "true" ]]; then
		echo "smart_device_smart_healthy{disk=\"${disk}\"} 1" >> $TMP_FILE
	else
		echo "smart_device_smart_healthy{disk=\"${disk}\"} 0" >> $TMP_FILE
	fi

        # NVME ssd's don't have an ata_smart_data table
        if [[ "$info" == *"\"ata_smart_data\":"* ]]; then
          progress=$(echo $info | jq '.ata_smart_data.self_test.status.string')
          # When a self test in progress, smartctl omits the status key which is a bug in smartctl but we'll work around it.
          if [[ "$progress" == *"in progress"* ]]; then
            echo "smart_device_self_test{disk=\"${disk}\"} 1" >> $TMP_FILE
          else
            status=$(echo $info | jq '.ata_smart_data.self_test.status.passed')
            if [[ "$status" == "true" ]]; then
                    echo "smart_device_self_test{disk=\"${disk}\"} 1" >> $TMP_FILE
            else
                    echo "smart_device_self_test{disk=\"${disk}\"} 0" >> $TMP_FILE
            fi
          fi
        else
            echo "smart_device_self_test{disk=\"${disk}\"} 1" >> $TMP_FILE
        fi

	echo "smart_temperature_celsius{disk=\"${disk}\"} $(echo $info | jq '.temperature.current')" >> $TMP_FILE

	# disk information
        model_family=$(echo $info | jq -r '.model_family')
        model_name=$(echo $info | jq -r '.model_name')
        serial_number=$(echo $info | jq -r '.serial_number')
	echo "smart_device_info{disk=\"$disk\",type=\"$type\",model_family=\"$model_family\",model_name=\"$model_name\",serial_number=\"$serial_number\"} 1" >> $TMP_FILE
done

mv -f $TMP_FILE $PROM_FILE
