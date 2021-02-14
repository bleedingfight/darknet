#!/bin/bash
DATASET_PATH=/home/liushuai/flower_photos/flower
TRAIN_DATASET_PATH=/tmp/flower_photos/export/train
TEST_DATASET_PATH=/tmp/flower_photos/export/test

TEMP_PATH=/tmp/flower_darknet
train_net=${TEMP_PATH}/resnet50_flower.cfg
if [ ! -d ${TEMP_PATH} ];then
	mkdir -p ${TEMP_PATH}
fi
find ${TRAIN_DATASET_PATH} -name '*.jpg' >${TEMP_PATH}/train.list
find ${TEST_DATASET_PATH} -name '*.jpg' >${TEMP_PATH}/test.list
config_path=${TEMP_PATH}/flower.data
backup=${TEMP_PATH}/weights
labels=${TEMP_PATH}/labels.txt
if [ ! -d ${backup} ];then
	mkdir -p ${backup}
fi
if [ -f ${config_path} ];then
	rm -f ${config_path}
fi
printf "\033[32mTrain data path:\033[31m[%s]\033[0m\ntrain list:\033[31m [%s] \033[0m\ntest list:\033[31m[%s]\033[0m\nconfig_path:\033[31m[%s]\033[0m \033[0m \nweight bachup path:\033[31m[%s]\033[0m\n" ${TEMP_PATH} ${TEMP_PATH}/train.list ${TEMP_PATH}/test.list ${config_path} ${backup}

printf "classes=5\ntrain=%s\ntest=%s\nlabels=%s\nbackup=%s\ntop=2\n" ${TEMP_PATH}/train.list ${TEMP_PATH}/test.list ${labels} ${backup}>${config_path}
ls ${DATASET_PATH}>${labels}
darknet_path=`find ${HOME} -name darknet -type d 2>/dev/null |grep darknet`
if [ ! -d ${darknet_path} ];then
	printf "\033[31mCan not find darknet path!\033[0m\n"
else
	cp -r ${darknet_path}/cfg/resnet50_flower.cfg ${train_net}
    darknet_bin=`find ${darknet_path} -name darknet -perm 775 -type f`
	printf "Darknet binary:\033[31m${darknet_bin}\033[0m\n"
	${darknet_bin} classifier train ${config_path} ${train_net}
fi
build/darknet classifier predict /tmp/flower_darknet/flower.data cfg/resnet50_flower.cfg /tmp/flower_darknet/weights/resnet50_flower_last.weights /tmp/flower_photos/export/test/daisy/10437929963_bc13eebe0c.jpg
