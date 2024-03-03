#!/bin/bash

CURRENT_DIR=$(cd "$(dirname "$0")" || exit; pwd)
ds_bin_dir=$CURRENT_DIR/ds
function start_ds() {
  ${ds_bin_dir}/start-all.sh
}

function stop_ds() {
  ${ds_bin_dir}/stop-all.sh
}
function status_ds() {
  ${ds_bin_dir}/status-all.sh
}

case "$1" in
	start )
		start_ds
		;;
	stop )
		stop_ds
		;;
	restart )
		stop_ds
		start_ds
		;;
	status )
		status_ds
		;;
	* )
		echo "Usage: $0 {start|stop|restart|status}"
		;;
esac
