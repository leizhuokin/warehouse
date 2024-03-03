#!/bin/bash
source /etc/profile
DATAX_HOME=${DATAX_HOME}
if [ "${DATAX_HOME}" == "" ];then
	echo "DATAX_HOME 不能为空，需配置环境变量 DATAX_HOME"
	exit 1;
fi
/usr/bin/python ${DATAX_HOME}/bin/datax.py $*
