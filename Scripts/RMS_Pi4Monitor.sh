#!/bin/bash

# monitor the logfile and if the capture process stops, restart it
logger 'RMS pi4 watchdog process starting'
hn=`hostname`
MAILRECIP=markmcintyre99@googlemail.com

cd /home/pi/RMS_data/logs
dead="no"
while [ "$dead" != "yes" ]
do
  fn=`ls -1tr log* | tail -1`
  logf=`find . -name $fn -mmin +1 -ls`
  dayt=`wc -l $fn | awk '{print $1}'`
  if [[ "$logf" !=  "" && $dayt -gt 30 ]] ; then
    done=`grep Archiving $fn`
    if [ "$done" != "" ] ; then
        logger 'RMS Pi4 watchdog process finished cleanly'
        exit 0
    fi
    touch /home/pi/source/RMS/.crash
    logger 'RMS Pi4 watchdog RMS stopped acquisition'
    killall python
    sleep 2
    cd ~/source/RMS
    lxterminal -e Scripts/RMS_StartCapture.sh -r
    cd /home/pi/RMS_data/logs
    echo From: pi@${hn} > ./stopped.txt
    echo To: $MAILRECIP >> ./stopped.txt
    echo Subject: process stopped >> ./stopped.txt
    echo stopped at `date +%Y%m%d-%H%M%S` >> ./stopped.txt
    echo $logf >>  ./stopped.txt
    /usr/bin/msmtp -t < ./stopped.txt
    logger 'RMS Pi4 watchdog continuing...'
  fi
  sleepint=20
  echo sleeping for $sleepint secs
  sleep $sleepint
done
logger 'watchdog exiting...'

exit 0

