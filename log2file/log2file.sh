#!/system/bin/sh

SDCARD_PATH=/mnt/internal_sd

FILE_MAX_SIZE=$((1024*1024*20))
LOGCAT_PID=-1
KMSG_PID=-1
MAX_INDEX=4

ANDROID_LOG_FILE_PATH=${SDCARD_PATH}/log/android
ANDROID_LOG_FILE=${ANDROID_LOG_FILE_PATH}/android.log
KERNEL_LOG_FILE_PATH=${SDCARD_PATH}/log/kernel
KERNEL_LOG_FILE=${KERNEL_LOG_FILE_PATH}/kernel.log

while [ ! -d ${SDCARD_PATH}/Android ] ; do
	echo "log2file: ${SDCARD_PATH}/Android no exist and wait 3s."
	sleep 3
done

ANDROID_INDEX_FILE=${ANDROID_LOG_FILE_PATH}/index.txt
if [ -f ${ANDROID_INDEX_FILE} ]
then
	ANDROID_INDEX=`cat ${ANDROID_INDEX_FILE}`
else
	ANDROID_INDEX=0
fi

KERNEL_INDEX_FILE=${KERNEL_LOG_FILE_PATH}/index.txt
if [ -f ${KERNEL_INDEX_FILE} ]
then
	KERNEL_INDEX=`cat ${KERNEL_INDEX_FILE}`
else
	KERNEL_INDEX=0
fi

if [ ! -d ${ANDROID_LOG_FILE_PATH} ]
then
    mkdir -p ${ANDROID_LOG_FILE_PATH}
fi

if [ ! -d ${KERNEL_LOG_FILE_PATH} ]
then
    mkdir -p ${KERNEL_LOG_FILE_PATH}
fi

logcat2file() {
	if [ ${LOGCAT_PID} != -1 ]; then
		kill -9 ${LOGCAT_PID}
	fi

	if [ ${ANDROID_LOG_FILE} != ${ANDROID_LOG_FILE_PATH}/android.log ]; then
		logcat -c
	fi
	
	ANDROID_LOG_FILE=${ANDROID_LOG_FILE_PATH}/android_${ANDROID_INDEX}.log
	logcat -v time > ${ANDROID_LOG_FILE} &
	LOGCAT_PID=$!
	
	echo "log2file: logcat2file pid=${LOGCAT_PID}, file=${ANDROID_LOG_FILE}"
}

kmsg2file() {
	if [ ${KMSG_PID} != -1 ]; then
		kill -9 ${KMSG_PID}
	fi
	
	KERNEL_LOG_FILE=${KERNEL_LOG_FILE_PATH}/kernel_${KERNEL_INDEX}.log
	cat /proc/kmsg > ${KERNEL_LOG_FILE} &
	KMSG_PID=$!
	
	echo "log2file: kmsg2file pid=${KMSG_PID}, file=${KERNEL_LOG_FILE}"
}

kmsg2file
logcat2file
while true ; do
	afilesize=`ls -l ${ANDROID_LOG_FILE} | busybox awk '{ print $4 }'`
	kfilesize=`ls -l ${KERNEL_LOG_FILE} | busybox awk '{ print $4 }'`
	echo "log2file: ${ANDROID_LOG_FILE} size=${afilesize}, FILE_MAX_SIZE=${FILE_MAX_SIZE}"
	echo "log2file: ${KERNEL_LOG_FILE} size=${kfilesize}, FILE_MAX_SIZE=${FILE_MAX_SIZE}"

	if [ ${afilesize} -gt ${FILE_MAX_SIZE} ]
	then
		if [ ${ANDROID_INDEX} -gt ${MAX_INDEX} ]
		then
			ANDROID_INDEX=0
		else
			ANDROID_INDEX=`busybox expr ${ANDROID_INDEX} + 1`
		fi
		echo "${ANDROID_INDEX}" > ${ANDROID_INDEX_FILE}
		
		logcat2file
	fi
	
	if [ ${kfilesize} -gt ${FILE_MAX_SIZE} ]
	then
		if [ ${KERNEL_INDEX} -gt ${MAX_INDEX} ]
		then
			KERNEL_INDEX=0
		else
			KERNEL_INDEX=`busybox expr ${KERNEL_INDEX} + 1`
		fi
		echo "${KERNEL_INDEX}" > ${KERNEL_INDEX_FILE}
		
		kmsg2file
	fi
	
	sleep 3
done

exit 0