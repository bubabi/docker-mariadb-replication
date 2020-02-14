# docker-mariadb-replication
![repel](https://liquipedia.net/commons/images/thumb/e/ee/Omniknight_degen_aura.png/50px-Omniknight_degen_aura.png)

MariaDB standard master-slave replication and fail-over with Docker. The replication can run on two remote servers. In addition, master and slave roles can be switching between servers for testing fail-over.

## Set up Replication 
#### Master Server

```
./repel.sh --setup --master
```

#### Slave Server

Slave runs **read_only=1** mode to ensure that slaves accept updates only from the master server and not from clients.

```
./repel.sh --setup --slave <MASTER_IP>
```

Set-up is finished, you can test your replication by writing any data in the database.

## Switching roles between master-slave servers 

Make sure your tables are locked on master also make sure that no data is written to the master before the switching and follow the steps in order.

#### Slave Server 

```
./repel.sh --switch to-master
```

#### Master Server

```
./repel.sh --switch to-slave <SLAVE_IP>
```
The switch is completed and the data is transferred from the new master to the new slave.

---

#### Environment variables
docker-compose.yml:
```
...
environment:
     MYSQL_ROOT_PASSWORD=test
     MYSQL_DATABASE=mydb
     MYSQL_USER=test_user
     MYSQL_PASSWORD=test
```
## Built With

* [MariaDB](https://mariadb.org/about/) - the database management system used
* [Docker](https://www.docker.com/why-docker) - performs operating-system-level virtualization, also known as "containerization"

#### References	

* https://github.com/vbabak/docker-mysql-master-slave	

* https://github.com/bergerx/docker-mysql-replication

:tada: Thanks for contributing to <a href="https://github.com/armut" target="blank">`Abdullah Akalın`</a> 
