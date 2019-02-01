# docker-mariadb-replication
![repel](https://liquipedia.net/commons/images/thumb/e/ee/Omniknight_degen_aura.png/50px-Omniknight_degen_aura.png)

MariaDB standard master-slave replication and fail-over with Docker 

## Set up Replication 
#### On Master Server

```
./repel.sh --setup --master
```

#### On Slave Server 

```
./repel.sh --setup --slave <MASTER_IP>
```

Set-up is finished, you can test your replication by writing any data in the database.

## Switching roles between master-slave servers 

Make sure your tables are locked on master also make sure that no data is written to the master before the switching and follow the steps in order.

#### On Slave Server 

```
./repel.sh --switch to-master
```

#### On Master Server

```
./repel.sh --switch to-slave <SLAVE_IP>
```
The switch is completed and the data is transferred from the new master to the new slave.

---

#### Environment variables
docker-compose.yml:

      *- MYSQL_ROOT_PASSWORD=test
      *- MYSQL_DATABASE=django_star
      *- MYSQL_USER=star
      *- MYSQL_PASSWORD=test


## Built With

* [MariaDB](https://mariadb.org/about/) - the database management system used
* [Docker](https://www.docker.com/why-docker) - performs operating-system-level virtualization, also known as "containerization"

Thanks for contributing to <a href="https://github.com/armut" target="blank">`Abdullah Akalın`</a> 
