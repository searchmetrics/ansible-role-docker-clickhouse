#!/usr/bin/env bash

BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )

servers="172.1.1.1 172.1.1.2 172.1.1.3"
port="8123"


sql1="CREATE TABLE IF NOT EXISTS test_local
(
    date Date,
    id UInt32,
    value String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/1/test_local', '1', date, (id), 8192);"

sql2="CREATE TABLE IF NOT EXISTS test_local
(
    date Date,
    id UInt32,
    value String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/1/test_local', '2', date, (id), 8192);"

sql3="CREATE TABLE IF NOT EXISTS test_local
(
    date Date,
    id UInt32,
    value String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/2/test_local', '1', date, (id), 8192);"


# create local tables
echo $sql1 | curl -XPOST 'http://172.1.1.1:'$port'/' --data-binary @-
echo $sql2 | curl -XPOST 'http://172.1.1.2:'$port'/' --data-binary @-
echo $sql3 | curl -XPOST 'http://172.1.1.3:'$port'/' --data-binary @-


sql_dist="CREATE TABLE IF NOT EXISTS test AS test_local
  ENGINE = Distributed(test-cluster, default, test_local, rand());"

# create distributed tables
for server in $servers
do

    echo $sql_dist | curl -XPOST 'http://'$server':'$port'/' --data-binary @-

done


# insert data
echo "INSERT INTO test_local(date,id,value) VALUES ('2006-08-08',1,'https://www.searchmetrics.com/')" | curl -XPOST 'http://172.1.1.1:'$port'/' --data-binary @-
echo "INSERT INTO test_local(date,id,value) VALUES ('2016-06-01',2,'https://clickhouse.yandex/')" | curl -XPOST 'http://172.1.1.3:'$port'/' --data-binary @-
