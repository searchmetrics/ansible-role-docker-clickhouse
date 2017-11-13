-- merge tree test
CREATE TABLE IF NOT EXISTS test_local
(
    date Date,
    id UInt32,
    value String
)
ENGINE = MergeTree(date, (id), 8192);