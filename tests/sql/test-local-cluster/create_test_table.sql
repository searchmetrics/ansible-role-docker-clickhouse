-- merge tree test
CREATE TABLE IF NOT EXISTS test AS test_local
  ENGINE = Distributed(no-replica-cluster, default, test_local, rand());