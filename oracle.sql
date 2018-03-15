--登录
sqlplus / as sysdba
sqlplus sys/password as sysdba
sqlplus user/password
sqlplus user/password@instance
--启动数据库
startup
startup nomount dbname
startup open dbname
startup nomount
alter database mount
alter database open
startup restrict
startup force
--连接数据库
conn sys/password as sysdba
conn sys/password as sysdba
conn user/password
conn user/password@instance

--安装Oracle 12.2.0.1
--Centos7 minimal x86_64 cpu:4c memory:4G disk:30G swap:4G 
vi /etc/sysconfig/network-scripts/ifcfg-ens33
BOOTPROTO=static
IPADDR1=172.16.123.136
GATEWAY0=172.16.123.1
ONBOOT=yes
vi /etc/selinux/config
SELINUX=disabled
systemctl stop firewalld
systemctl disable firewalld
vi /etc/hostname
odb1
vi /etc/hosts
172.16.123.136 odb1
--安装依赖包
yum install binutils compat-libcap1 compat-libstdc++-33 compat-libstdc++-33.i686 glibc glibc.i686 glibc-devel glibc-devel.i686 ksh libaio libaio.i686 libaio-devel libaio-devel.i686 libX11 libX11.i686 libXau libXau.i686 libXi libXi.i686 libXtst libXtst.i686 libgcc libgcc.i686 libstdc++ libstdc++.i686 libstdc++-devel libstdc++-devel.i686 libxcb libxcb.i686 make nfs-utils net-tools smartmontools sysstat unixODBC unixODBC-devel gcc gcc-c++ libXext libXext.i686 zlib-devel zlib-devel.i686
--创建用户和组
groupadd oinstall
groupadd dba
groupadd oper
useradd -g oinstall -G dba,oper oracle
passwd oracle
--配置/etc/sysctl.conf
vi /etc/sysctl.conf
fs.file-max = 6815744
kernel.sem = 250 32000 100 128
kernel.shmmni = 4096
kernel.shmall = 1073741824
kernel.shmmax = 4398046511104
kernel.panic_on_oops = 1
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500
--使配置生效
sysctl -p
--配置/etc/security/limits.conf
vi /etc/security/limits.conf
oracle   soft   nofile    1024
oracle   hard   nofile    65536
oracle   soft   nproc    16384
oracle   hard   nproc    16384
oracle   soft   stack    10240
oracle   hard   stack    32768
oracle   hard   memlock    134217728
oracle   soft   memlock    134217728
--创建目录
mkdir -p /u01/app/oracle/product/12.2.0.1/db_1
chown -R oracle:oinstall /u01
chmod 775 /u01
--配置环境变量
vi /home/oracle/.bash_profile
# Oracle Settings  
export TMP=/tmp  
export TMPDIR=$TMP  
  
export ORACLE_HOSTNAME=odb1  
export ORACLE_UNQNAME=cdb
export ORACLE_BASE=/u01/app/oracle  
export ORACLE_HOME=$ORACLE_BASE/product/12.2.0.1/db_1  
export ORACLE_SID=cdb1  
  
export PATH=/usr/sbin:$PATH  
export PATH=$ORACLE_HOME/bin:$PATH  
  
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib  
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
--下载解压
yum install unzip
scp linuxx64_12201_database.zip oracle@172.16.123.136:/home/oracle
su - oracle
unzip linuxx64_12201_database.zip
cd database
--编辑应答文件
vi install.rsp
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v12.2.0
oracle.install.option=INSTALL_DB_SWONLY
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oracle/oraInventory
ORACLE_HOME=/u01/app/oracle/product/12.2.0.1/db_1
ORACLE_BASE=/u01/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.OSDBA_GROUP=dba
oracle.install.db.OSOPER_GROUP=oper
oracle.install.db.OSBACKUPDBA_GROUP=dba
oracle.install.db.OSDGDBA_GROUP=dba
oracle.install.db.OSKMDBA_GROUP=dba
oracle.install.db.OSRACDBA_GROUP=dba
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=cdb1
oracle.install.db.config.starterdb.SID=cdb1
oracle.install.db.config.starterdb.characterSet=AL32UTF8
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
DECLINE_SECURITY_UPDATES=true
--开始安装
./runInstaller -force -silent -noconfig -responseFile /home/oracle/database/install.rsp
Starting Oracle Universal Installer...

Checking Temp space: must be greater than 500 MB.   Actual 18291 MB    Passed
Checking swap space: must be greater than 150 MB.   Actual 4095 MB    Passed
Preparing to launch Oracle Universal Installer from /tmp/OraInstall2018-03-15_05-10-52AM. Please wait ...[oracle@odb1 database]$ [WARNING] [INS-32055] The Central Inventory is located in the Oracle base.
   ACTION: Oracle recommends placing this Central Inventory in a location outside the Oracle base directory.
You can find the log of this install session at:
 /u01/app/oracle/oraInventory/logs/installActions2018-03-15_05-10-52AM.log
The installation of Oracle Database 12c was successful.
Please check '/u01/app/oracle/oraInventory/logs/silentInstall2018-03-15_05-10-52AM.log' for more details.

As a root user, execute the following script(s):
	1. /u01/app/oracle/oraInventory/orainstRoot.sh
	2. /u01/app/oracle/product/12.2.0.1/db_1/root.sh



Successfully Setup Software.
--root执行两个脚本
exit
/u01/app/oracle/oraInventory/orainstRoot.sh
Changing permissions of /u01/app/oracle/oraInventory.
Adding read,write permissions for group.
Removing read,write,execute permissions for world.

Changing groupname of /u01/app/oracle/oraInventory to oinstall.
The execution of the script is complete.
/u01/app/oracle/product/12.2.0.1/db_1/root.sh
Check /u01/app/oracle/product/12.2.0.1/db_1/install/root_odb1_2018-03-15_05-42-25-790094180.log for the output of root script
--编辑监听配置应答文件
su - oracle
cd database/response
cat netca.rsp | grep -Ev "^#|^$"
[GENERAL]
RESPONSEFILE_VERSION="12.2"
CREATE_TYPE="CUSTOM"
[oracle.net.ca]
INSTALLED_COMPONENTS={"server","net8","javavm"}
INSTALL_TYPE=""typical""
LISTENER_NUMBER=1
LISTENER_NAMES={"LISTENER"}
LISTENER_PROTOCOLS={"TCP;1521"}
LISTENER_START=""LISTENER""
NAMING_METHODS={"TNSNAMES","ONAMES","HOSTNAME"}
NSN_NUMBER=1
NSN_NAMES={"EXTPROC_CONNECTION_DATA"}
NSN_SERVICE={"PLSExtProc"}
NSN_PROTOCOLS={"TCP;HOSTNAME;1521"}
--配置，添加监听
netca -silent -responsefile /home/oracle/database/response/netca.rsp

Parsing command line arguments:
    Parameter "silent" = true
    Parameter "responsefile" = /home/oracle/database/response/netca.rsp
Done parsing command line arguments.
Oracle Net Services Configuration:
Profile configuration complete.
Oracle Net Listener Startup:
    Running Listener Control:
      /u01/app/oracle/product/12.2.0.1/db_1/bin/lsnrctl start LISTENER
    Listener Control complete.
    Listener started successfully.
Listener configuration complete.
Oracle Net Services configuration successful. The exit code is 0
lsnrctl status

LSNRCTL for Linux: Version 12.2.0.1.0 - Production on 15-MAR-2018 05:53:29

Copyright (c) 1991, 2016, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=odb1)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 12.2.0.1.0 - Production
Start Date                15-MAR-2018 05:51:43
Uptime                    0 days 0 hr. 1 min. 46 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/oracle/product/12.2.0.1/db_1/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/odb1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=odb1)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
The listener supports no services
The command completed successfully
--编辑创建数据库的应答文件
cd
vi dbca.rsp
responseFileVersion=/oracle/assistants/rspfmt_dbca_response_schema_v12.2.0  
gdbName=cdb1  
sid=cdb1  
databaseConfigType=SI  
RACOneNodeServiceName=  
policyManaged=false  
createServerPool=false  
serverPoolName=  
cardinality=  
force=false  
pqPoolName=  
pqCardinality=  
createAsContainerDatabase=true  
numberOfPDBs=1  
pdbName=cdb1pdb  
useLocalUndoForPDBs=true  
pdbAdminPassword=  
nodelist=  
templateName=/u01/app/oracle/product/12.2.0.1/db_1/assistants/dbca/templates/General_Purpose.dbc  
sysPassword=  
systemPassword=  
serviceUserPassword=  
emConfiguration=  
emExpressPort=5500  
runCVUChecks=false  
dbsnmpPassword=  
omsHost=  
omsPort=0  
emUser=  
emPassword=  
dvConfiguration=false  
dvUserName=  
dvUserPassword=  
dvAccountManagerName=  
dvAccountManagerPassword=  
olsConfiguration=false  
datafileJarLocation={ORACLE_HOME}/assistants/dbca/templates/  
datafileDestination={ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/  
recoveryAreaDestination={ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME}  
storageType=FS  
diskGroupName=  
asmsnmpPassword=  
recoveryGroupName=  
characterSet=AL32UTF8  
nationalCharacterSet=AL16UTF16  
registerWithDirService=false  
dirServiceUserName=  
dirServicePassword=  
walletPassword=  
listeners=LISTENER  
variablesFile=  
variables=DB_UNIQUE_NAME=cdb1,ORACLE_BASE=/u01/app/oracle,PDB_NAME=,DB_NAME=cdb1,ORACLE_HOME=/u01/app/oracle/product/12.2.0.1/db_1,SID=cdb1  
initParams=undo_tablespace=UNDOTBS1,memory_target=796MB,processes=300,db_recovery_file_dest_size=2780MB,nls_language=AMERICAN,dispatchers=(PROTOCOL=TCP) (SERVICE=cdb1XDB),db_recovery_file_dest={ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME},db_block_size=8192BYTES,diagnostic_dest={ORACLE_BASE},audit_file_dest={ORACLE_BASE}/admin/{DB_UNIQUE_NAME}/adump,nls_territory=AMERICA,local_listener=LISTENER_CDB1,compatible=12.2.0,control_files=("{ORACLE_BASE}/oradata/{DB_UNIQUE_NAME}/control01.ctl", "{ORACLE_BASE}/fast_recovery_area/{DB_UNIQUE_NAME}/control02.ctl"),db_name=cdb1,audit_trail=db,remote_login_passwordfile=EXCLUSIVE,open_cursors=300  
sampleSchema=false  
memoryPercentage=40  
databaseType=MULTIPURPOSE  
automaticMemoryManagement=true  
totalMemory=0
--创建数据库
dbca -silent -createDatabase  -responseFile  /home/oracle/dbca.rsp
[WARNING] [DBT-06801] Specified Fast Recovery Area size (2,780 MB) is less than the recommended value.
   CAUSE: Fast Recovery Area size should at least be three times the database size (2,730 MB).
   ACTION: Specify Fast Recovery Area Size to be at least three times the database size.
Enter SYS user password: 

Enter SYSTEM user password: 

Enter PDBADMIN User Password: 

[WARNING] [DBT-06208] The 'SYS' password entered does not conform to the Oracle recommended standards.
   CAUSE: 
a. Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].
b.The password entered is a keyword that Oracle does not recommend to be used as password
   ACTION: Specify a strong password. If required refer Oracle documentation for guidelines.
[WARNING] [DBT-06208] The 'SYSTEM' password entered does not conform to the Oracle recommended standards.
   CAUSE: 
a. Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].
b.The password entered is a keyword that Oracle does not recommend to be used as password
   ACTION: Specify a strong password. If required refer Oracle documentation for guidelines.
[WARNING] [DBT-06208] The 'PDBADMIN' password entered does not conform to the Oracle recommended standards.
   CAUSE: 
a. Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].
b.The password entered is a keyword that Oracle does not recommend to be used as password
   ACTION: Specify a strong password. If required refer Oracle documentation for guidelines.
[WARNING] [DBT-06801] Specified Fast Recovery Area size (2,780 MB) is less than the recommended value.
   CAUSE: Fast Recovery Area size should at least be three times the database size (3,571 MB).
   ACTION: Specify Fast Recovery Area Size to be at least three times the database size.
Copying database files
1% complete
13% complete
25% complete
Creating and starting Oracle instance
26% complete
30% complete
31% complete
35% complete
38% complete
39% complete
41% complete
Completing Database Creation
42% complete
43% complete
44% complete
46% complete
49% complete
50% complete
Creating Pluggable Databases
55% complete
75% complete
Executing Post Configuration Actions
100% complete
Look at the log file "/u01/app/oracle/cfgtoollogs/dbca/cdb1/cdb1.log" for further details.
--查看状态
sqlplus / as sysdba
SQL*Plus: Release 12.2.0.1.0 Production on Thu Mar 15 06:46:35 2018

Copyright (c) 1982, 2016, Oracle.  All rights reserved.


Connected to:
Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production
select open_mode from v$database;

OPEN_MODE
--------------------
READ WRITE

select status from v$instance;

STATUS
------------
OPEN

--关闭数据库
shutdown immediate
Database closed.
Database dismounted.
ORACLE instance shut down.

shutdown normal
shutdown immediate
shutdown abort
shutdown transactional
