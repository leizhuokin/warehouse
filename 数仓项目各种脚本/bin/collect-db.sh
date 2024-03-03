#!/bin/bash
maxwell_hosts=(node02)

function start() {
    for i in $maxwell_hosts
    do
        echo --------- starting  maxwell on ${i} ----------
        ssh  ${i} 'source /etc/profile;$MAXWELL_HOME/bin/maxwell --config $JOB_HOME/conf/maxwell/config.properties --daemon'
    done
}

function stop() {
    for i in $maxwell_hosts
    do
        echo --------- stoping  maxwell on ${i} ----------
        ssh ${i} "ps -ef | grep com.zendesk.maxwell.Maxwell | grep -v grep | awk '{print \$2}' | xargs kill -9"
    done
}

function status() {
    for i in $maxwell_hosts
    do
        echo --------- status  maxwell on ${i} ----------
        #ps -ef | grep metastore| grep -v grep | awk '{print \$2}'
        m_id=$(ssh ${i} "ps -ef | grep com.zendesk.maxwell.Maxwell | grep -v grep | awk '{print \$2}'")
        echo "${m_id} Maxwell"
    done
}

case $1 in
start)
  start
  ;;
stop)
  stop
  ;;
status)
  status
  ;;
esac
