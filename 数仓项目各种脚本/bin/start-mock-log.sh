#!/bin/bash
source /etc/profile
#当前脚本所在目录
CURRENT_DIR=$(cd "$(dirname "$0")" || exit; pwd)
parent_dir=$CURRENT_DIR/../mock/applog
cd "${parent_dir}" || exit
#获取当前日期
#current_date=$(date +"%Y-%m-%d")
#参数变量
arg=""
if [ "$1" != "" ];then
  arg="--mock.date=$1"
fi

nohup java -jar "${parent_dir}/commerce-mock-log-1.0.0.jar" "${arg}" > "${JOB_HOME}"/logs/mock-log.log 2>&1 &



