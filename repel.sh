#!/bin/bash

OP=$1
ROLE=$2
i=1
sp="/-\|"

if [[ "$OP" == "--switch" ]]
    then
        if [[ "$ROLE" == "to-master" ]]
            then
                echo "Switching to master."

                docker exec replication sh -c "mysql -uroot -ptest -e\"set global read_only=0\""
                docker exec replication sh -c 'sed -i "s/^read_only.*/read_only=0/" "/etc/mysql/my.cnf"'

                switch_sql="STOP SLAVE; RESET SLAVE ALL;"
                docker exec replication mysql -uroot -ptest -e "$switch_sql"
                echo "OK! Now, you are master."
                echo "To complete the switch operation, please run this script with to-slave option on the other machine."
        elif [[ "$ROLE" == "to-slave" ]]
            then
                echo "Switching to slave."

                SLAVE_IP=$3
                if [[ -n "$SLAVE_IP" ]]
                    then
                        echo "Slave ip is $SLAVE_IP"
                else
                    echo "Please specify the slave node ip. Aborted."
                    exit 1
                fi

                docker exec replication sh -c "mysql -uroot -ptest -e\"set global read_only=1\""
                docker exec replication sh -c 'sed -i "s/^read_only.*/read_only=1/" "/etc/mysql/my.cnf"'

                MS_STATUS=`docker exec replication sh -c 'mysql -uroot -ptest -h'$SLAVE_IP' -e "SHOW MASTER STATUS"'`
                CURRENT_LOG=`echo $MS_STATUS | awk '{print $5}'`
                CURRENT_POS=`echo $MS_STATUS | awk '{print $6}'`
                echo "[Debug] Log: $CURRENT_LOG, Pos: $CURRENT_POS"

                start_slave_stmt="CHANGE MASTER TO MASTER_HOST='$SLAVE_IP', MASTER_USER='replicator_slave', MASTER_PASSWORD='111', MASTER_LOG_FILE='$CURRENT_LOG', MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
                docker exec replication sh -c "mysql -uroot -ptest -e \"$start_slave_stmt\""
                echo "OK! Now, you are slave."
        else
            echo -e "Please specify the switch direction which can be one of the following:\n\tto-master\n\tto-slave"
        fi
elif [[ "$OP" == "--setup" ]]
    then
        MASTER_IP=$3
        if [[ "$ROLE" == "--master" ]]
            then
                echo "Master!"
                docker-compose up --build -d mariadb

                until docker exec replication sh -c 'mysql -uroot -ptest -e ";"' &> /dev/null
                do
                    printf "\b${sp:i++%${#sp}:1}"
                done
                echo -ne "\033[0K\r"

                priv_stmt='GRANT REPLICATION SLAVE ON *.* TO "replicator_slave"@"%" IDENTIFIED BY "111"; FLUSH PRIVILEGES;'
                docker exec replication sh -c "mysql -u root -ptest -e '$priv_stmt'"
                echo "OK!"
        elif [[ "$ROLE" == "--slave" ]]
            then
                if [ -n "$MASTER_IP" ];
                    then
                        echo "Master ip is $MASTER_IP"
                else
                    echo "Please specify the master node ip. Aborted."
                    exit 1
                fi

                echo "Slave!"
                docker-compose up --build -d mariadb

                until docker exec replication sh -c 'mysql -uroot -ptest -e ";"'  &> /dev/null
                do
                    printf "\b${sp:i++%${#sp}:1}"
                done
                echo -ne "\033[0K\r"

                docker exec replication sh -c 'mysql -uroot -ptest -e "set global server_id=2"'
                docker exec replication sh -c 'sed -i "s/^server-id.*/server-id=2/" "/etc/mysql/my.cnf"'

                docker exec replication sh -c "mysql -uroot -ptest -e\"set global read_only=1\""
                docker exec replication sh -c 'sed -i "s/^read_only.*/read_only=1/" "/etc/mysql/my.cnf"'

                priv_stmt='GRANT REPLICATION SLAVE ON *.* TO "replicator_slave"@"%" IDENTIFIED BY "111"; FLUSH PRIVILEGES;'
                docker exec replication sh -c "mysql -u root -ptest -e '$priv_stmt'"

                MS_STATUS=`docker exec replication sh -c 'mysql -uroot -ptest -h'$MASTER_IP' -e "SHOW MASTER STATUS"'`
                CURRENT_LOG=`echo $MS_STATUS | awk '{print $5}'`
                CURRENT_POS=`echo $MS_STATUS | awk '{print $6}'`
                echo "Log: $CURRENT_LOG, Pos: $CURRENT_POS"

                start_slave_stmt="CHANGE MASTER TO MASTER_HOST='$MASTER_IP', MASTER_USER='replicator_slave', MASTER_PASSWORD='111', MASTER_LOG_FILE='$CURRENT_LOG', MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
                docker exec replication sh -c "mysql -uroot -ptest -e \"$start_slave_stmt\""
                echo "OK!"
        else
            echo -e "Please specify the role which can be one of the following:\n\t--master\n\t--slave"
        fi
else
    echo -e "Unrecognized operation. Operation can be one of these:\n\t--switch\n\t--setup."
fi
