#!/bin/bash

source /etc/profile
echo "脚本执行啦"  `date` $0 $1 $2 $3 $4
#0403
SpringBoot=$2
port=$3
debugPort=$4

if [ "$1" = "" ];
then
    echo -e "未输入操作名 {start|stop|restart|status}"
    exit 1
fi

if [ "$SpringBoot" = "" ];
then
    echo -e "未输入应用名 "
    exit 1
fi

function start()
{
    count=`ps -ef |grep java|grep $SpringBoot|grep -v grep|wc -l`
    if [ $count != 0 ];then
        echo "$SpringBoot is running..."
    else
        echo "Start $SpringBoot success..."
        BUILD_ID=dontkillme nohup java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$debugPort -Dserver.port=$port -jar $SpringBoot > log.txt &
        #这里的sleep不能省略，省略之后是无法启动项目的。原因未知！！很坑
        sleep 2s
    fi
}

function stop()
{
    echo "Stop $SpringBoot"
    boot_id=`ps -ef |grep java|grep $SpringBoot|grep -v grep|awk '{print $2}'`
    count=`ps -ef |grep java|grep $SpringBoot|grep -v grep|wc -l`

    if [ $count != 0 ];then
        kill $boot_id
        count=`ps -ef |grep java|grep $SpringBoot|grep -v grep|wc -l`

        boot_id=`ps -ef |grep java|grep $SpringBoot|grep -v grep|awk '{print $2}'`
        kill -9 $boot_id
    fi
}

function restart()
{
    stop
    sleep 2
    start
}

function status()
{
    count=`ps -ef |grep java|grep $SpringBoot|grep -v grep|wc -l`
    if [ $count != 0 ];then
        echo "$SpringBoot is running..."
    else
        echo "$SpringBoot is not running..."
    fi
}

case $1 in
    start)
    start;;
    stop)
    stop;;
    restart)
    restart;;
    status)
    status;;
    *)

    echo -e " Usage:  $0  {start|stop|restart|status}  {SpringBootJarName}    Example:   $0  start test.jar "
esac
