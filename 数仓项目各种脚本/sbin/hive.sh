#!/bin/bash
#Hive所在节点
hive_hostname=node01
operate=$1
component=$2
function start_metastore() {
    echo '--------- starting hive metastore ----------'
    ssh "${hive_hostname}" 'source /etc/profile;${HIVE_HOME}/bin/hive --service metastore >> ${JOB_HOME}/logs/hive-${hive_hostname}-metastore.log 2>&1 &'
}
function start_hiveserver2() {
    echo '--------- starting hiveserver2 ----------'
    ssh "${hive_hostname}" 'source /etc/profile;${HIVE_HOME}/bin/hiveserver2 > ${JOB_HOME}/logs/hive-${hive_hostname}-hiveserver2.log 2>&1 &'
}
function stop_metastore() {
    echo '--------- stoping hive metastore ----------'
    ssh "${hive_hostname}" "ps -ef | grep metastore | grep -v grep | awk '{print \$2}' | xargs kill -9"
}
function stop_hiveserver2() {
    echo '--------- stoping hiveserver2 ----------'
    ssh "${hive_hostname}" "ps -ef | grep hiveserver2 | grep -v grep | awk '{print \$2}' | xargs kill -9"
}
function status_jps() {
    echo "--------- status ${hive_hostname} ----------"
    m_id=$(ssh "${hive_hostname}" "ps -ef | grep metastore| grep -v grep | awk '{print \$2}'")
    h_id=$(ssh "${hive_hostname}" "ps -ef | grep hiveserver2| grep -v grep | awk '{print \$2}'")
    if [ "${m_id}" != "" ] ;then
        echo -e "${m_id}\t metastore"
    fi
    if [ "${h_id}" != "" ] ;then
        echo -e "${h_id}\t hiveserver2"
    fi
}
function start_hive() {
    case "${component}" in
        metastore)
            start_metastore
        ;;
        hiveserver2)
            start_hiveserver2
        ;;
        "")
            start_metastore
            sleep 4s
            start_hiveserver2
        ;;
    esac
}
function stop_hive() {
case "${component}" in
    metastore)
        stop_metastore
    ;;
    hiveserver2)
        stop_hiveserver2
    ;;
    "")
        stop_metastore
        stop_hiveserver2
    ;;
esac
}
#获取当前要启动的程序 hdfs,yarn
case "${operate}" in
    start )
        start_hive
    ;;
    stop )
        stop_hive
    ;;
    status )
        status_jps
    ;;
    restart )
        stop_hive
        start_hive
    ;;
    * )
        echo "Usage: $0 {start|stop|restart|status} [metastore|hiveserver2]"
    ;;
esac

