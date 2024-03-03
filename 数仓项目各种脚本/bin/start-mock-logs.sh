#!/bin/bash
source /etc/profile
log_hosts=(node01 node02)
for i in ${log_hosts[*]}; do
  echo "-------start on ${i} mock log service---------"
  ssh "$i" "source /etc/profile;start-mock-log.sh $1"
done
