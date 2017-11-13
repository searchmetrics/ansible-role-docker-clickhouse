#!/usr/bin/env bash

BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )

servers="172.1.1.1 172.1.1.2 172.1.1.3"
port="8123"

# create tables
for server in $servers
do

    cat $BASE_DIR/tests/sql/test-local-cluster/create_test_local_table.sql | POST 'http://'$server':'$port'/'
    cat $BASE_DIR/tests/sql/test-local-cluster/create_test_table.sql | POST 'http://'$server':'$port'/'

done

# insert data
echo "INSERT INTO test(date,id,value) VALUES ('2006-08-08',1,'https://www.searchmetrics.com/')" | POST 'http://172.1.1.1:'$port'/'
echo "INSERT INTO test_local(date,id,value) VALUES ('2016-06-01',2,'https://clickhouse.yandex/')" | POST 'http://172.1.1.2:'$port'/'
