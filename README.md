# Ansible Role - ClickHouse Server for Docker
[![Build Status](https://api.travis-ci.org/searchmetrics/ansible-role-docker-clickhouse.svg?branch=master)](https://travis-ci.org/searchmetrics/ansible-role-docker-clickhouse) [![Ansible Role](https://img.shields.io/ansible/role/21659.svg)](https://galaxy.ansible.com/searchmetrics/ansible-role-docker-clickhouse/)

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

clickhouse server settings
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
  
clickhouse user profiles
```yml
# ------------------------ 
# default user settings:
#   networks: 
#       - <ip>::/0</ip>
#   profile: default
#   quota:   default
# ------------------------
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
Server with default config:
```yml
- hosts: localhost
  become: yes
  roles:
    - ansible-role-docker-clickhouse
```

Server with custom config:
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

Server with custom users & profiles:
- set password for default user
```yml
- hosts: localhost
  become: yes
  vars:
    - clickhouse_docker_user_profiles:
        default:
          max_memory_usage:     10000000000
          max_execution_time:   60
          max_rows_to_read:     1000000000
          max_result_rows:      1000000000
        readonly:
          readonly: 1
    - clickhouse_docker_users:
        default:
          password: root
        ro_user:
          password: ""
          profile: readonly
  roles:
    - ansible-role-docker-clickhouse
```

Local ClickHouse Cluster:
- ansible playbook yml: [tests/test-local-cluster.yml](tests/test-local-cluster.yml)
- good for local config testing
```yml
- hosts: localhost
  remote_user: root
  tasks:
    - name: Create a ClickHouse docker network
      docker_network:
        name: ClickNetwork
        ipam_options:
          subnet: '172.1.1.0/24'
          gateway: 172.1.1.100
          iprange: '172.1.1.0/24'


- hosts: localhost
  remote_user: root
  vars:
    - clickhouse_docker_container_name: "clickhouse-1"
    - clickhouse_docker_version: 1.1.54310
    - clickhouse_docker_host_data_folder: "/tmp/docker-clickhouse-data/1"
    - clickhouse_docker_host_config_folder: "/tmp/docker-clickhouse-config/1"
    - clickhouse_docker_host_task_queue_folder: "/tmp/docker-clickhouse-task-queue/1"
    - clickhouse_docker_network_mode: bridge
    - clickhouse_docker_networks:
        - { name: "ClickNetwork", ipv4_address: "172.1.1.1" }
    - clickhouse_docker_config:
        interserver_http_host:  172.1.1.1
    - clickhouse_docker_remote_servers:
        no-replica-cluster:
          - shard: { replica: [ { host: 172.1.1.1, port: 9000 } ] }
          - shard: { replica: [ { host: 172.1.1.2, port: 9000 } ] }
          - shard: { replica: [ { host: 172.1.1.3, port: 9000 } ] }
  roles:
    - ansible-role-docker-clickhouse


- hosts: localhost
  remote_user: root
  vars:
    - clickhouse_docker_container_name: "clickhouse-2"
    - clickhouse_docker_version: 1.1.54310
    - clickhouse_docker_host_data_folder: "/tmp/docker-clickhouse-data/2"
    - clickhouse_docker_host_config_folder: "/tmp/docker-clickhouse-config/2"
    - clickhouse_docker_host_task_queue_folder: "/tmp/docker-clickhouse-task-queue/2"
    - clickhouse_docker_network_mode: bridge
    - clickhouse_docker_networks:
        - { name: "ClickNetwork", ipv4_address: "172.1.1.2" }
    - clickhouse_docker_config:
        interserver_http_host:  172.1.1.2
    - clickhouse_docker_remote_servers:
        no-replica-cluster:
          - shard: { replica: [ { host: 172.1.1.1, port: 9000 } ] }
          - shard: { replica: [ { host: 172.1.1.2, port: 9000 } ] }
          - shard: { replica: [ { host: 172.1.1.3, port: 9000 } ] }
  roles:
    - ansible-role-docker-clickhouse

- hosts: localhost
  remote_user: root
  vars:
    - clickhouse_docker_container_name: "clickhouse-3"
    - clickhouse_docker_version: 1.1.54310
    - clickhouse_docker_host_data_folder: "/tmp/docker-clickhouse-data/3"
    - clickhouse_docker_host_config_folder: "/tmp/docker-clickhouse-config/3"
    - clickhouse_docker_host_task_queue_folder: "/tmp/docker-clickhouse-task-queue/3"
    - clickhouse_docker_network_mode: bridge
    - clickhouse_docker_networks:
        - { name: "ClickNetwork", ipv4_address: "172.1.1.3" }
    - clickhouse_docker_config:
        interserver_http_host:  172.1.1.3
    - clickhouse_docker_remote_servers:
        no-replica-cluster:
          - shard: { replica: [ { host: 172.1.1.1, port: 9000 } ] }
          - shard: { replica: [ { host: 172.1.1.2, port: 9000 } ] }
          - shard: { replica: [ { host: 172.1.1.3, port: 9000 } ] }
  roles:
    - ansible-role-docker-clickhouse
```

##  License

MIT

##  Author Information

This role was created by [Jens Schröder](https://github.com/jens-schroeder-sm)\
Role owner is [Searchmetrics GmbH](https://www.searchmetrics.com)