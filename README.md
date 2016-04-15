ansible-role-redis
==================

Install redis

Requirements
------------

None

Role Variables
--------------

| variable | description | default |
|----------|-------------|---------|
| redis\_user | redis user name | redis |
| redis\_group | redis group name | redis |
| redis\_conf\_dir | basedir of redis.conf | "{{ \_\_redis\_conf\_dir }}" |
| redis\_config\_daemonize | daemonize | "yes" |
| redis\_config\_pidfile | pidfile | "{{ \_\_redis\_config\_pidfile }}" |
| redis\_config\_port | port | 6379 |
| redis\_config\_tcp\_backlog| tcp-backlog |511 |
| redis\_config\_timeout | timeout | 0 |
| redis\_config\_tcp\_keepalive | tcp-keepalive | 0 |
| redis\_config\_loglevel | loglevel | notice |
| redis\_config\_logfile | logfile | "{{ \_\_redis\_config\_logfile }}" |
| redis\_config\_databases | databases | 16 |
| redis\_config\_save | save | [ "900 1", "300 10", "60, 10000" ] |
| redis\_config\_stop\_writes\_on\_bgsave\_error | stop-writes-on-bgsave-error | "yes" |
| redis\_config\_rdbcompression | rdbcompression | "yes" |
| redis\_config\_rdbchecksum | rdbchecksum | "yes" |
| redis\_config\_dbfilename | dbfilename | dump.rdb |
| redis\_config\_dir | dir | "{{ \_\_redis\_config\_dir }}" |
| redis\_config\_slave\_serve\_stale\_data | slave-serve-stale-data | "yes" |
| redis\_config\_slave\_read\_only | slave-read-only | "yes" |
| redis\_config\_repl\_diskless\_sync | repl-diskless-sync | "no" |
| redis\_config\_repl\_diskless\_sync\_delay | repl-diskless-sync-delay | 5 |
| redis\_config\_repl\_disable\_tcp\_nodelay | repl-disable-tcp-nodelay | "no" |
| redis\_config\_slave\_priority | slave-priority | 100 |
| redis\_config\_appendonly | appendonly | "no" |
| redis\_config\_appendfilename | appendfilename | appendonly.aof |
| redis\_config\_appendfsync | appendfsync | everysec |
| redis\_config\_no\_appendfsync\_on\_rewrite | no-appendfsync-on-rewrite | "no" |
| redis\_config\_auto\_aof\_rewrite\_percentage | auto-aof-rewrite-percentage | 100 |
| redis\_config\_auto\_aof\_rewrite\_min\_size | auto-aof-rewrite-min-size | 64mb |
| redis\_config\_aof\_load\_truncated | aof-load-truncated | "yes" |
| redis\_config\_lua\_time\_limit | lua-time-limit | 5000 |
| redis\_config\_slowlog\_log\_slower\_than | slowlog-log-slower-than | 10000 |
| redis\_config\_slowlog\_max\_len | slowlog-max-len | 128 |
| redis\_config\_latency\_monitor\_threshold | latency-monitor-threshold | 0 |
| redis\_config\_notify\_keyspace\_events | notify-keyspace-events | "" |
| redis\_config\_hash\_max\_ziplist\_entries | hash-max-ziplist-entries | 512 |
| redis\_config\_hash\_max\_ziplist\_value | hash-max-ziplist-value | 64 |
| redis\_config\_list\_max\_ziplist\_entries | list-max-ziplist-entries | 512 |
| redis\_config\_list\_max\_ziplist\_value | list-max-ziplist-value | 64 |
| redis\_config\_set\_max\_intset\_entries | set-max-intset-entries | 512 |
| redis\_config\_zset\_max\_ziplist\_entries | zset-max-ziplist-entries | 128 |
| redis\_config\_zset\_max\_ziplist\_value | zset-max-ziplist-value | 64 |
| redis\_config\_hll\_sparse\_max\_bytes | hll-sparse-max-bytes | 3000 |
| redis\_config\_activerehashing | activerehashing | "yes" |
| redis\_config\_client\_output\_buffer\_limit | client-output-buffer-limit | [ "normal 0 0 0", "slave 256mb 64mb 60", "pubsub 32mb 8mb 60" ]
| redis\_config\_hz | hz | 10 |
| redis\_config\_aof\_rewrite\_incremental\_fsync | aof-rewrite-incremental-fsync | "yes" |

Dependencies
------------

None

Example Playbook
----------------

    - hosts: servers
      roles:
         - ansible-role-redis
      vars:
         redis_config_tcp_backlog: 512

License
-------

BSD

Author Information
------------------

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
