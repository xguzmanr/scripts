#!/bin/sh
###BEGIN INIT INFO
# Provides:		axiar
# Required-Start:	$remote_fs $syslog
# Required-Stop:	$remote_fs $syslog
# Default-Start:	2 3 4 5
# Defaul-Stop:		0 1 6
# Short-Description:	Start axiar daemon at boot time
# Description:		Enable service provided by daemon.
### END INIT INFO


# shell Script to start-stop AXIAR Daemons
# axiar.sh start  TO starting daemons
# axiar.sh stop for stopping daemons
# axiar.sh restart to restart AXIAR
# axiar.sh status to get status of axiar
# axiar.sh * will provide the usage of the program


ACTIVE_JOBS=999
ACTIVE_PRINTERS=999
ACTIVITY=999

if [ "$AXIAR_POSIX" != "" ]; then
	WORKDIR=$AXIAR_POSIX
else
	WORKDIR=/usr/spool
fi

LOGFILE=$WORKDIR/uprint/axiardaemon.log

DATESTAMP=`date +%Y_%m_%d@%H_%M_%S`

axiar_start(){

## start function
echo "\n\n$DATESTAMP: STARTING AXIAR -----------------------" >> $LOGFILE
rm $WORKDIR/uprint/*.pid 2>> $LOGFILE
echo "Starting udaemon" 
$WORKDIR/uprint/udaemon &  2>> $LOGFILE
		
while [ ! -f $WORKDIR/uprint/udaemon.pid ]; do
	echo sleeping
	sleep 8
done
	echo "Starting Ulpd"
	$WORKDIR/uprint/ulpd & >> $LOGFILE 2>> $LOGFILE
	sleep 8

	#$WORKDIR/uprint/ulisten -p9100 & 2>> $LOGFILE
	#sleep 5

	STATUS=`ps -ef | grep V7 | grep ulpd`
	if [ "$STATUS" = "" ]; then
		echo "STARTUP failed"
	else
		echo "STARTUP completed"
	fi
	##exit 0
}

axiar_stop(){
echo "\n\n$DATESTAMP: STARTING AXIAR SHUTDOWN -----------------------" >> $LOGFILE
## Check for ulisten process
#UPROC=`ps -ef | grep ulisten`
##print $UPROC
#if [ "$UPROC" != "" ]; then
	#ULID=`print $UPROC | awk '{ print $2; exit }'`
#fi
#if [ "$ULID" != "" ]; then
	#kill -9 $ULID
#fi
#while [ $ACTIVITY -gt 0 ]; do
#	$WORKDIR/uprint/urelease -a -H >> $LOGFILE  2>> $LOGFILE
#	ACTIVE_JOBS=$?
#	if [ $ACTIVE_JOBS -eq 255 ]; then
#		echo "$DATESTAMP:    urelease returned error status" >> $LOGFILE
#		exit 0
#	fi
#	$WORKDIR/uprint/uenable -a -D >> $LOGFILE  2>> $LOGFILE
#	ACTIVE_PRINTERS=$?
#	if [ $ACTIVE_PRINTERS -eq 255 ]; then
#		echo "\n\n$DATESTAMP:    uenable returned error status" >> $LOGFILE
#		exit 0
#	fi
#	DATESTAMP=`date +%Y_%m_%d@%H_%M_%S`
#	echo "$DATESTAMP:    $ACTIVE_JOBS active jobs and #$ACTIVE_PRINTERS active printers" >> $LOGFILE
#	ACTIVITY=`expr $ACTIVE_JOBS+$ACTIVE_PRINTERS`	
#	sleep 5					
#done
echo "Stopping AXIAR daemons"
STATUS=`ps -ef | grep V7 | grep udaemon`
	if [ "$STATUS" = "" ]; then
		echo "AXIAR not running"
	else
		$WORKDIR/uprint/ushut  2>> $LOGFILE
		
		echo "Shutdown started"
	fi

##exit 0
}

axiar_kill(){
## Check for  process
UPROC=`ps -ef | grep udaemon`
print $UPROC
if [ "$UPROC" != "" ]; then
	ULID=`print $UPROC | awk '{ print $2; exit }'`
fi
if [ "$ULID" != "" ]; then
	kill -9 $ULID
fi

UPROC2=`ps -ef | grep ulpd`
while [ "$UPROC2" != ""  ]; do
	echo $UPROC2
	if [ "$UPROC2" != "" ]; then
		ULID2=`echo $UPROC2 | awk '{ print $2; exit }'`
	fi
	if [ "$ULID2" != "" ]; then
		kill -9 $ULID2
	fi
	UPROC2=`ps -ef | grep ulpd`
done
echo "Shutdown completed"
	
}

axiar_status(){

##Get Status of AXIAR Daemons
STATUS=`ps -ef | grep udaemon | egrep -v "grep"`

if [ "$STATUS" = "" ]; then
	echo "AXIAR not running"
else
	ps -e -o ppid,pid,user,args | grep V | egrep -v "grep"
	#ps -ef | grep ulisten
fi
	
}

## main call to script
case "$1" in
		'start') 
			axiar_start
			;;
		'stop')
			axiar_stop
			#axiar_kill
			;;
		'restart')
			axiar_stop
			#axiar_kill
			axiar_start
			;;
		 'status')
			axiar_status
			;;
		 *)
			echo "Usage: $0 {start|stop|restart|status}"
			;;
esac

exit 0
