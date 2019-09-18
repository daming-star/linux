#!/bin/bash
# mysql数据备份脚本
#备份策略周一咔进行数据库全备，其它天只对个别表进行备份
#脚本时间：2016-5-17
#创建者：han

DBName=mysql 
DBUser=root 
DBpwd="54root%$"
BackupPath="/home/mysql_backup/"
BackupPath_incre="/home/mysql_backup/incre_backup/"
LogFile="/vmanage/monitor/"
today=`date  +%y-%m-%d`
today1=`date +%w`
yesterday=`date -d "1 days ago" +%y-%m-%d`
yesterday1=`date -d "1 days ago" +%w`
yesterday7=`date -d "6 days ago" +%y-%m-%d`

############本地保留13天备份文件##########
del_day=`date -d "13 days ago" +%y-%m-%d`
del_name_all=`ls -l $BackupPath/|grep 20$del_day|awk -F " " '{print $9}'`
del_name_incr=`ls -l $BackupPath_incre|grep 20$del_day|awk -F " " '{print $9}'`

[  $del_name_all ] && rm -rf $BackupPath$del_name_all
[ $del_name_incr ] && rm -rf $BackupPath_incre$del_name_incr


##########备份开始####################
if [ $today1 -eq 1 ] ; then


	echo "-----------#开始备份#----------------" >> $LogFile/databak.log 
	echo $(date +"%y-%m-%d %H:%M:%S") >> $LogFile/databak.log

        innobackupex  --defaults-file=/etc/my.cnf --user=$DBUser --password=$DBpwd  $BackupPath
        if [ $? -eq 0 ] ;then
		echo "$(date +"%y-%m-%d %H:%M:%S") database all_backup SUCCESSFUL " >> $LogFile/databak.log
        else
       		 echo "$(date +"%y-%m-%d %H:%M:%S") database backup failed " >> $LogFile/databak.log
        fi


elif  [ $yesterday1 -eq 1 ] ; then
	echo "-----------$today开始备份#-------">> $LogFile/databak.log
        all_backup=`ls -l $BackupPath|grep 20$yesterday|awk -F " " '{print $9}'`
        innobackupex --user=$DBUser  --password=$DBpwd  --incremental $BackupPath_incre  --incremental-basedir=$BackupPath$all_backup
        if [ $? -eq 0 ] ;then

        echo "$(date +"%y-%m-%d %H:%M:%S") database incremental backup SUCCESSFUL " >> $LogFile/databak.log
        else
        echo "$(date +"%y-%m-%d %H:%M:%S") database incremental backup failed " >> $LogFile/databak.log
        fi

else 
        echo "-----------$today#增量备份开始#--------">> $LogFile/databak.log
        incre_backup=`ls -l $BackupPath_incre|grep 20$yesterday|awk -F " " '{print $9}'`
        innobackupex --user=$DBUser --password=$DBpwd --incremental $BackupPath_incre  --incremental-basedir=$BackupPath_incre$incre_backup
        if [ $? -eq 0 ] ;then
        echo "$(date +"%y-%m-%d %H:%M:%S") database incremental backup SUCCESSFUL " >> $LogFile/databak.log
        else
        echo "$(date +"%y-%m-%d %H:%M:%S") database incremental backup failed " >> $LogFile/databak.log
        fi
fi


