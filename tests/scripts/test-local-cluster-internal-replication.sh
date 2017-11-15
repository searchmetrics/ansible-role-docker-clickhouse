#!/usr/bin/env bash

BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )

servers="172.1.1.1 172.1.1.2"
port="8123"


sql_local="CREATE TABLE IF NOT EXISTS test_local
(
    date Date,
    id UInt32,
    value String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/test_local', '{replica}', date, (id), 8192);"

sql_dist="CREATE TABLE IF NOT EXISTS test AS test_local
  ENGINE = Distributed(test_cluster, default, test_local, rand());"

# create tables
for server in $servers
do
    echo "DROP TABLE IF EXISTS test_local" | curl -XPOST 'http://'$server':'$port'/' --data-binary @-
    echo $sql_local | curl -XPOST 'http://'$server':'$port'/' --data-binary @-

    echo "DROP TABLE IF EXISTS test" | curl -XPOST 'http://'$server':'$port'/' --data-binary @-
    echo $sql_dist | curl -XPOST 'http://'$server':'$port'/' --data-binary @-

done

# insert data
echo "INSERT INTO test(date,id,value) VALUES ('2006-08-08',1,'https://www.searchmetrics.com/')" | curl -XPOST 'http://172.1.1.2:'$port'/' --data-binary @-


# -----------------------------------------


sql_local="CREATE TABLE IF NOT EXISTS test_internal_replication_local
(
    date Date,
    id UInt32,
    value String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/test_internal_replication_local', '{replica}', date, (id), 8192);"

sql_dist="CREATE TABLE IF NOT EXISTS test_internal_replication AS test_internal_replication_local
  ENGINE = Distributed(test_cluster_internal_replication, default, test_internal_replication_local, rand());"

# create tables
for server in $servers
do
    echo "DROP TABLE IF EXISTS test_internal_replication_local" | curl -XPOST 'http://'$server':'$port'/' --data-binary @-
    echo $sql_local | curl -XPOST 'http://'$server':'$port'/' --data-binary @-

    echo "DROP TABLE IF EXISTS  test_internal_replication" | curl -XPOST 'http://'$server':'$port'/' --data-binary @-
    echo $sql_dist | curl -XPOST 'http://'$server':'$port'/' --data-binary @-

done

# insert data
echo "INSERT INTO test_internal_replication(date,id,value) VALUES ('2006-08-08',1,'https://www.searchmetrics.com/')" | curl -XPOST 'http://172.1.1.2:'$port'/' --data-binary @-

