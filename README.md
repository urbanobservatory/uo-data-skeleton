# Urban Observatory Data Skeleton

This a **skeleton** repo for configuring and orchestrating **Urban Observatory In a Box** federated network of sensors and services. This codebase is based on implementations instrumented at [The Newcastle Urban Observatory](https://urbanobservatory.ac.uk/).

---

⚠️ **IMPORTANT**⚠️

This code is work in progress and experimental.

---

## Specification

This repository is used for spinning up Urban Observatory services. It uses [uo-data-box](https://github.com/urbanobservatory/uo-data-box) as codebase and `.env` & `*.sh` files for controlling [docker-compose](https://docs.docker.com/compose/overview/) files and various other scripts.

## Authors

uo-data-skeleton has been developed by:

- Aare Puussaar (Newcastle University)

Contributors:

- Luke Smith (Newcastle University)

## Deployment

> **NOTE!** This guide assumes that both [uo-data-box](https://github.com/urbanobservatory/uo-data-box) and [uo-data-skeleton](https://github.com/urbanobservatory/uo-data-skeleton) are checked out on the installation VM(s). `UO-INSTANCE` is referred to as application or instance and`UO-BROKERS` are referred to as list broker environments to provide brokerage for, separated by a dot (e.g. `BROKER.RunService1`, `BROKER.RunService2`).

### Configuration

All the services in [uo-data-box](https://github.com/urbanobservatory/uo-data-box) and [/shared](/shared) are configures using deployment specific `.env` variables files located in [/config](/config) which are loaded in using service(s) scripts.

```bash
# use example to create your UO-INSTANCE configuration
cp config/instance.env.example config/${UO-INSTANCE}.env

```

**Variables**

> **NOTE!** Variables services need different set of variables to start. When connecting to database using `docker` networks you _MUST_ use `container_name` (`UO_DB_HOST` variable) and default port to connect. If changing default `UO_*_AMQP_USERNAME`, `UO_*_QUEUE` or `UO_BROKER_EXCHANGE_COV` variables, RabbitMQ `definitions.json` file needs to be changed manually.

| Name                                 | Usage                                             |                        Values                         |
| :----------------------------------- | ------------------------------------------------- | :---------------------------------------------------: |
| UO_INSTANCE                          | The instance name of deployment                   |                    example `city`                     |
| UO_DOMAIN                            | The deployment domain/location                    |                  example `newcastle`                  |
| UO_HOST                              | The hostname of the UO installation               |           example `urbanobservatory.ac.uk`            |
| UO_QUEUE_HOST                        | The hostname of your `rabbitmq`                   |                                                       |
| UO_DATA_HOST                         | The hostname of your `database`                   |                                                       |
| UO_WEB_HOST                          | The hostname of your `webservice`                 |                                                       |
| UO_WEB_FILE_BASE                     | The base URL of your `file` service               |                                                       |
| UO_API_BASE                          | The base URL of your `api` service                |                                                       |
| UO_API_URL_EXCLUSIONS                | The variable for stripping URLs for `api` service | Example `'"Urban Sciences Building: "+"Floor 1: "'`\* |
| UO_API_RESTRICT_KEY                  | The key for restricting data from `api` service   |  Example `0a8e3548-0110-474f-8e23-f5322aed344c`\*\*   |
| UO_WEBSOCKET_SERVER_PORT             | The stream websocket port                         |                                                       |
| UO_DB_ORGANISATION                   | The organisation of your `database`               |                     example `uo`                      |
| UO_DB_SYSTEM                         | The system of your `database`                     |                    example `city`                     |
| TABLE_PREFIX                         | The table prefix of your `database`               |   example `${UO_DB_ORGANISATION}_${UO_DB_SYSTEM}_`    |
| POSTGRES_DB                          | The name of your `database`                       |    example `${UO_DB_ORGANISATION}-${UO_DB_SYSTEM}`    |
| POSTGRES_USER                        | The username for your `database`                  |                  example `uo-admin`                   |
| POSTGRES_PASSWORD                    | The password for your `database`                  |                       `*******`                       |
| POSTGRES_PORT                        | The port number for your `database`               |                    example `5432`                     |
| UO_DB_HOST                           | The docker hostname of your `database`            |         default `${UO_INSTANCE}-timescaledb`          |
| UO_DB_PORT                           | The docker port of your `database`                |                    default `5432`                     |
| UO_DB_NAME                           | The docker name of your `database`                |               default `${POSTGRES_DB}`                |
| UO_DB_USER                           | The docker username for your `database`           |              default `${POSTGRES_USER}`               |
| UO_DB_PASS                           | The docker password for your `database`           |            default `${POSTGRES_PASSWORD}`             |
| DB_TYPE                              | The type of your `database` (for backups)         |                  default `timescale`                  |
| DB_BACKUP_MONITOR_PORT               | The backup monitor `port`                         |                    example `8084`                     |
| DIFF_SCHEDULE                        | The schedule to run the diff backup on            |        [\* \* \* \* \*](https://crontab.guru/)        |
| SCHEMA_SCHEDULE                      | The schedule to run the schema backup on          |                      (optional)                       |
| FULL_SCHEDULE                        | The schedule to run the full backup on            |                      (optional)                       |
| RABBITMQ_HOST                        | The hostname of your `rabbitmq`                   |              default `${UO_QUEUE_HOST}`               |
| RABBITMQ_NODENAME                    | The nodename of your `rabbitmq` instance          |         default `uo-${UO_INSTANCE}@rabbitmq`          |
| RABBITMQ_PORT_ADMIN                  | The admin UI port of your `rabbitmq`              |                    example `5672`                     |
| RABBITMQ_PORT_DATA                   | The data port of your `rabbitmq`                  |                    example `15672`                    |
| RABBITMQ_PORT_MONITOR                | The monitor port of your `rabbitmq`               |                    example `15692`                    |
| UO_MASTER_BROKER_AMQP_HOST           | The storage queue hostname                        |              default `${RABBITMQ_HOST}`               |
| UO_MASTER_BROKER_AMQP_PORT           | The storage queue port                            |            default `${RABBITMQ_PORT_DATA}`            |
| UO_MASTER_BROKER_AMQP_USERNAME       | The storage queue username                        |                    default `store`                    |
| UO_MASTER_BROKER_AMQP_PASSWORD       | The storage queue password                        |                       `*******`                       |
| UO_MASTER_BROKER_AMQP_QUEUE          | The storage queue name                            |               default `uo.master.store`               |
| UO_BROKER_AMQP_HOST                  | The broker service queue name                     |              default `${RABBITMQ_HOST}`               |
| UO_BROKER_AMQP_PORT                  | The broker service queue port                     |            default `${RABBITMQ_PORT_DATA}`            |
| UO_BROKER_AMQP_USERNAME              | The broker service queue username                 |                   default `broker`                    |
| UO_BROKER_AMQP_PASSWORD              | The broker service queue password                 |                       `*******`                       |
| UO_BROKER_EXCHANGE_COV               | The broker service exchange name                  |                   default `uo.raw`                    |
| UO_BROKER_CONFIGURATION              | The broker service feeds config name              |                example `IMG.OpenFeeds`                |
| UO_BROKER_CONFIGURATION_USERNAME     | The broker service basic auth username            |                (optional) example `uo`                |
| UO_BROKER_CONFIGURATION_PASSWORD     | The broker service basic auth password            |                 (optional) `*******`                  |
| UO_BROKER_CONFIGURATION_PORT         | The broker service server port                    |               (optional) default `8080`               |
| UO_BROKER_CONFIGURATION_API_USERNAME | The broker service API auth username              |                (optional) example `uo`                |
| UO_BROKER_CONFIGURATION_API_PASSWORD | The broker service API auth password              |                 (optional) `*******`                  |
| UO_STREAM_AMQP_HOST                  | The stream service queue hostname                 |              default `${RABBITMQ_HOST}`               |
| UO_STREAM_AMQP_PORT                  | The stream service queue port                     |            default `${RABBITMQ_PORT_DATA}`            |
| UO_STREAM_AMQP_USERNAME              | The broker service queue username                 |                   default `stream`                    |
| UO_STREAM_AMQP_PASSWORD              | The broker service queue password                 |                       `*******`                       |
| UO_STREAM_QUEUE                      | The broker service queue name                     |              default `uo.master.stream`               |
| CODE_BASE_DIR                        | The location of the `uo-data-box` codebase        |               default `../uo-data-box`                |
| FILE_SERVICE_DIR                     | The location of the public files to serve         |    default `../../${CODE_BASE_DIR}/archive/public`    |
| BACKUP_DIR                           | The location of database backups                  |                 default `/srv/backup`                 |

**\*** `UO_API_URL_EXCLUSIONS` purpose is to strip the provided phrases from the algorithm that generates URLs, so for example an entity called "Urban Sciences Building: Floor 1" becomes simply `/sensors/entity/floor-1/`.
**\*\*** `UO_API_RESTRICT_KEY` is bespoke variable used in one of UO deployments to restrict data access on the API.

### Building master image:

```bash
./build.sh ${UO-INSTANCE} [docker-compose options]
```

### DB service:

```bash
./db-service.sh ${UO-INSTANCE} start [docker-compose options]
```

### Queue services:

> **NOTE!** Queue services use [RabbitMQ](https://www.rabbitmq.com/) configuration from `definitions.json` which is injected with passwords from `.env` variables on service startup and copied to `uo-data-box` codebase next to rabbitmq compose file. See the template configuration in [/config](/config). Also make sure to check if exposed `ports` are not already taken on host before running.

```bash
./queue-services.sh ${UO-INSTANCE} start [docker-compose options]
```

### Data services:

```bash
./data-services.sh ${UO-INSTANCE} start [docker-compose options]
```

### Broker services:

> **NOTE!** check if exposed service `port` is not already taken on host before running. Codebase includes an example of UTMC services that requires a custom `docker-compose` file. It uses proprietary image in the pipeline, but it is still included as example of broker configuration.

```bash
./broker-services.sh ${UO-INSTANCE} ${UO-BROKERS} start [docker-compose options]
```

### Web services (APIs, streams, docs):

```bash
# create additional networks if needed
docker network create web # used as traefik network
docker network create ${UO-INSTANCE}-stream
docker network create ${UO-INSTANCE}-api

./web-services.sh ${UO-INSTANCE} start [docker-compose options]
```

> **NOTE!** Current docker compose setup for web services is using [Traefik 1.7](https://doc.traefik.io/traefik/v1.7/) as a reverse proxy to assign services endpoints and deal with API rate limits. That means that traefik needs to be installed an started in the container on network called `web`.

### File service (hosting uploaded files on web):

```bash
# user .env variable as file path that is being exposed using nginx
./file-service.sh ${UO-INSTANCE} start [docker-compose options]
```

### Backup service

```bash
# add backup folders to your host machine, for example:
mkdir -p /srv/backup/${UO-INSTANCE}/data # add backup data location
mkdir -p /srv/backup/${UO-INSTANCE}/cache # add diff cache location

./backup-service-new.sh ${UO-INSTANCE} start [docker-compose options]
```

## Monitor services (web and data):

```bash
./monitor-services.sh ${UO-INSTANCE} {data|web}
```

## Optimisation

### Cluster data

```bash
./cluster-data.sh ${UO-INSTANCE}
```

### Analyse data

```bash
./analyse-data.sh ${UO-INSTANCE}
```

## Utilities

### Filter data

```bash
# uses start, end date and storage table names as command line arguments
./filter-data.sh ${UO-INSTANCE} start_date end_date uo_data_real [uo_data_int uo_data_bool uo_data_string uo_data_json]
```

### Restore backup data

```bash
# table=restore normal tables, data=restore data (hyper) tables
# filespath is the location of backup files (for folder /* is needed)
./restore-data.sh ${UO-INSTANCE} {tables|data|temp} filespath
# also creates a logfile (in the same directory) of fails when restoring files
```

## License

UO DATA SKELETON is provided under [MIT](https://github.com/urbanobservatory/uo-data-box/blob/main/LICENSE):

    Copyright (c), 2021 Urban Observatory at Newcastle University, Aare Puussaar, Luke Smith

    <urbanobservatory@ncl.ac.uk>
    <aare.puussaar@ncl.ac.uk>
    <luke.smith@ncl.ac.uk>

    Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    	https://opensource.org/licenses/MIT

    Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Future Ideas

- add configurable queue name and user variables
- multiple broker authentication handling for endpoints
- implement API key keys
