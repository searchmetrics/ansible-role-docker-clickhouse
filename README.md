# Ansible Role - ClickHouse Server for Docker
[![Build Status](https://api.travis-ci.org/searchmetrics/ansible-role-docker-clickhouse.svg?branch=master)](https://travis-ci.org/searchmetrics/ansible-role-docker-clickhouse)

An ansible role to start and run a ClickHouse server docker container. 
You can change any server setting (listen host (bind address), ports, etc.),
define user profiles, user password or user quotas.

## Requirements
This role requires Ansible 2.0 or higher.

## Role Variables

host & docker vars
```yml
# host
clickhouse_docker_host_data_folder: "/docker/clickhouse-data"
clickhouse_docker_host_config_folder: "/docker/clickhouse-config"
clickhouse_docker_host_task_queue_folder: "/docker/clickhouse-task-queue"

# docker
clickhouse_docker_version: latest
clickhouse_docker_network_mode: host
clickhouse_docker_container_name: clickhouse
clickhouse_docker_bind_mounts:
  - "{{clickhouse_docker_host_data_folder}}:/var/lib/clickhouse"
  - "{{clickhouse_docker_host_config_folder}}:/etc/clickhouse-server/conf.d"
  - "{{clickhouse_docker_host_task_queue_folder}}:/clickhouse/task_queue"
```

clickhouser server settings
```yml
clickhouse_docker_config:
  listen_host:  127.0.0.1
  http_port:    8123
  tcp_port:     9000

clickhouse_docker_config_resharding:
  - /clickhouse/task_queue

clickhouse_docker_config_distributed_ddl:
  - /clickhouse/task_queue/ddl
```  
  
clickhouser user profiles  
```yml
  
# user defaults:
#   networks: 
#       - <ip>::/0</ip>
#   profile: default
#   quota: default
clickhouse_docker_users:
  default:
    password: test
  ro_user:
    password: test
    profile: readonly  

clickhouse_docker_user_profiles:
  - readonly:
    - readonly: 1  
```

## Example Playbook
Single server with default config:
```yml
- hosts: localhost
  become: yes
  roles:
    - ansible-role-docker-clickhouse
```

Single server with custom config:
- changed ClickHouse server version
- changed HTTP & TCP ports
- changed listen_host (bind address)
```yml
- hosts: localhost
  become: yes
  vars:
    - clickhouse_docker_version: 1.1.54304
    - clickhouse_docker_config:
        http_port:    8124
        tcp_port:     9001
        listen_host:  0.0.0.0
  roles:
    - ansible-role-docker-clickhouse
```

##  License

MIT

##  Author Information

This role was created by [Jens Schröder](https://github.com/jens-schroeder-sm)\
Role owner is [Searchmetrics GmbH](https://www.searchmetrics.com)