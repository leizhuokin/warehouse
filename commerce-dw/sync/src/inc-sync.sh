#!/bin/bash
FLUME_HOME=$FLUME_HOME
FLUME_CONF_HOME=${JOB_CONF}
if [ "${FLUME_HOME}" == "" ];then
	echo "FLUME_HOME 不能为空，需配置环境变量 FLUME_HOME"
	exit 1;
fi
case $1 in
"start")
        echo " --------启动 node03 业务数据增量同步 flume-------"
        ssh node03 "nohup ${FLUME_HOME}/bin/flume-ng agent --name a1 --conf conf --conf-file ${FLUME_CONF_HOME}/kafka_to_hdfs_inc_sync.conf >/dev/null 2>&1 &"
;;
"stop")

        echo " --------停止 node03 业务数据增量同步 flume-------"
        ssh node03 "ps -ef | grep kafka_to_hdfs_inc_sync | grep -v grep |awk '{print \$2}' | xargs -n1 kill"
;;
esac