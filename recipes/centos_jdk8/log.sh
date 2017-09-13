#!/bin/bash
BASE_DIR=~/che/ws-agent/logs
LOG_DIR=$BASE_DIR/`date +%Y/%m/%d`
LS=$(ls -l $LOG_DIR/* 2>/dev/null | wc -l)

run_thread (){
  tail -F -n +0 $LOG_DIR/* &
  THREAD_PID=$!
}

cleanup () {
  pgrep -P $$ | xargs -i kill {}
  exit
}

trap cleanup SIGHUP SIGINT SIGTERM

while [ ! -d $LOG_DIR ] || [ "$LS" == 0 ] ; do
  LOG_DIR=$BASE_DIR/`date +%Y/%m/%d`
  LS=$(ls -l $LOG_DIR/* 2>/dev/null | wc -l)
  sleep 5
done

run_thread

OLD_LOG_DIR=$LOG_DIR
OLD_LS=$(ls -l $LOG_DIR/* 2>/dev/null | wc -l)
while [ 1 ]; do
  LS=$(ls -l $LOG_DIR/* 2>/dev/null | wc -l)
  if [ "$LS" != "$OLD_LS" ]; then
    OLD_LS=$(ls -l $LOG_DIR/* 2>/dev/null | wc -l)
    kill $THREAD_PID
    run_thread
  else
    DIR=$BASE_DIR/`date +%Y/%m/%d`
    if [ -d $DIR ] && [ $DIR != $OLD_LOG_DIR ]; then
      LOG_DIR=$DIR
      OLD_LOG_DIR=$LOG_DIR
      kill $THREAD_PID
      run_thread
    fi
  fi
  sleep 5
done
