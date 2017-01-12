# ansible-role-redis

Install and configures redis and sentinel.

## Notes for all users

Most of default values are respected but `protected-mode` is `no` by default in
the role. It is user's responsibility to protect redis and sentinel.

## Notes for Ubuntu and CentOS users

The role installs redis version 2.x.

## Notes for Ubuntu users

Standalone redis configuration should work, but sentinel will not work. See
[issue #18](https://github.com/reallyenglish/ansible-role-redis/issues/18) and
[issue #19](https://github.com/reallyenglish/ansible-role-redis/issues/19).

# Requirements

At least one "save $N" as a key must be defined in `redis_sentinel_config`. See
Example Playbook.

# Role Variables

## Variables for `redis`

| Variable | Description | Default |
|----------|-------------|---------|
| `redis_user` | redis user | `{{ __redis_user }}` |
| `redis_group` | redis group | `{{ __redis_group }}` |
| `redis_package` | redis server package | `{{ __redis_package }}` |
| `redis_service` | redis service name | `{{ __redis_service }}` |
| `redis_conf_dir` | dirname of `redis.conf` | `{{ __redis_conf_dir }}` |
| `redis_conf_file` | path to `redis.conf` | `{{ redis_conf_dir }}/redis.conf` |
| `redis_conf_file_ansible` | static config file for redis | `{{ redis_conf_file }}.ansible` |
| `redis_enable` | enable redis. if true, `tasks/redis.yml` is invoked | `true` |
| `redis_config_default` | dict of defaults for `redis.conf` | `{{ __redis_config_default }}` |
| `redis_config` | dict that overrides `redis_config_default` | `{}` |

## Variables for `sentinel`

| Variable | Description | Default |
|----------|-------------|---------|
| `redis_sentinel_group` | list of sentinel nodes. The first one is the master | `[]` |
| `redis_sentinel_service` | service name of sentinel | `{{ __redis_sentinel_service }}` |
| `redis_sentinel_conf_file` | path to `sentinel.conf` | `{{ __redis_sentinel_conf_file }}` |
| `redis_sentinel_conf_file_ansible` | path to static config file for redis | `{{ redis_sentinel_conf_file }}.ansible` |
| `redis_sentinel_enable` | enable sentinel. `tasks/sentinel.yml` is invoked | `false` |
| `redis_sentinel_password` | password for `sentinel auth-pass` | `""` |
| `redis_sentinel_master_name` | `master-name`, which is used for several sentinel commands | `""` |
| `redis_sentinel_master_port` | port to monitor redis | `6379` |
| `redis_sentinel_quorum` | number of quorum | `2` |
| `redis_sentinel_parallel_syncs` | `sentinel parallel-syncs` | `1` |
| `redis_sentinel_down_after_milliseconds` | `sentinel down-after-milliseconds` | `5000` |
| `redis_sentinel_failover_timeout` | `sentinel failover-timeout` | `180000` |
| `redis_sentinel_logdir` | path to log directory for `sentinel.log` | `{{ __redis_sentinel_logdir }}` |
| `redis_sentinel_logfile` | path to`sentinel.log` | `{{ redis_sentinel_logdir }}/sentinel.log` |
| `redis_sentinel_config_default` | dict of defaults for `sentinel.conf` | see below |
| `redis_sentinel_config` | dict that overrides `redis_sentinel_config_default` | `{}` |

## `redis_sentinel_config_default`

```yaml
redis_sentinel_config_default:
  port: 26379
  dir: /tmp
  logfile: "{{ redis_sentinel_logfile }}"
  protected-mode: "no"
  sentinel auth-pass: "{{ redis_sentinel_master_name }} {{ redis_sentinel_password }}"
```
When you set `bind`, the first IP address MUST NOT be `127.0.0.1` (at least in
redis 3.2.6). If you want `sentinel` to bind to `127.0.0.1` and others, place it
to the end.

## Debian

| Variable | Default |
|----------|---------|
| `__redis_user` | `redis` |
| `__redis_group` | `redis` |
| `__redis_package` | `redis-server` |
| `__redis_service` | `redis-server` |
| `__redis_conf_dir` | `/etc/redis` |
| `__redis_config_default` | see below |
| `__redis_sentinel_logdir` | `/var/log/redis` |

### `__redis_config_default` for Debian

```yaml
__redis_config_default:
  # derived from /etc/redis/redis.conf of redis-server 2:2.8.4-2
  daemonize: "yes"
  pidfile: /var/run/redis/redis-server.pid
  port: 6379
  bind: 127.0.0.1
  timeout: 0
  tcp-keepalive: 0
  loglevel: notice
  logfile: /var/log/redis/redis-server.log
  databases: 16
  stop-writes-on-bgsave-error: "yes"
  rdbcompression: "yes"
  rdbchecksum: "yes"
  dbfilename: dump.rdb
  dir: /var/lib/redis
  slave-serve-stale-data: "yes"
  slave-read-only: "yes"
  repl-disable-tcp-nodelay: "no"
  slave-priority: 100
  appendonly: "no"
  appendfilename: "appendonly.aof"
  appendfsync: everysec
  no-appendfsync-on-rewrite: "no"
  auto-aof-rewrite-percentage: 100
  auto-aof-rewrite-min-size: 64mb
  lua-time-limit: 5000
  slowlog-log-slower-than: 10000
  slowlog-max-len: 128
  notify-keyspace-events: '""'
  hash-max-ziplist-entries: 512
  hash-max-ziplist-value: 64
  list-max-ziplist-entries: 512
  list-max-ziplist-value: 64
  set-max-intset-entries: 512
  zset-max-ziplist-entries: 128
  zset-max-ziplist-value: 64
  activerehashing: "yes"
  client-output-buffer-limit normal: 0 0 0
  client-output-buffer-limit slave: 256mb 64mb 60
  client-output-buffer-limit pubsub: 32mb 8mb 60
  hz: 10
  aof-rewrite-incremental-fsync: "yes"
```

## FreeBSD

| Variable | Default |
|----------|---------|
| `__redis_user` | `redis` |
| `__redis_group` | `redis` |
| `__redis_package` | `redis` |
| `__redis_service` | `redis` |
| `__redis_conf_dir` | `/usr/local/etc/redis` |
| `__redis_config_default` | see below |
| `__redis_sentinel_logdir` | `/var/log/redis` |

### `__redis_config_default` for FreeBSD

```yaml
__redis_config_default:
  # derived from /usr/local/etc/redis.conf.sample of redis-3.2.6 except "save"
  bind: 127.0.0.1
  protected-mode: "yes"
  port: 6379
  tcp-backlog: 511
  timeout: 0
  tcp-keepalive: 300
  daemonize: "yes"
  supervised: "no"
  pidfile: /var/run/redis/redis.pid
  loglevel: notice
  logfile: /var/log/redis/redis.log
  databases: 16
  stop-writes-on-bgsave-error: "yes"
  rdbcompression: "yes"
  rdbchecksum: "yes"
  dbfilename: dump.rdb
  dir: /var/db/redis/
  slave-serve-stale-data: "yes"
  slave-read-only: "yes"
  repl-diskless-sync: "no"
  repl-diskless-sync-delay: 5
  repl-disable-tcp-nodelay: "no"
  slave-priority: 100
  appendonly: "no"
  appendfilename: '"appendonly.aof"'
  appendfsync: everysec
  no-appendfsync-on-rewrite: "no"
  auto-aof-rewrite-percentage: 100
  auto-aof-rewrite-min-size: 64mb
  aof-load-truncated: "yes"
  lua-time-limit: 5000
  slowlog-log-slower-than: 10000
  slowlog-max-len: 128
  latency-monitor-threshold: 0
  notify-keyspace-events: '""'
  hash-max-ziplist-entries: 512
  hash-max-ziplist-value: 64
  list-max-ziplist-size: -2
  list-compress-depth: 0
  set-max-intset-entries: 512
  zset-max-ziplist-entries: 128
  zset-max-ziplist-value: 64
  hll-sparse-max-bytes: 3000
  activerehashing: "yes"
  "client-output-buffer-limit normal": 0 0 0
  "client-output-buffer-limit slave": 256mb 64mb 60
  "client-output-buffer-limit pubsub": 32mb 8mb 60
  hz: 10
  aof-rewrite-incremental-fsync: "yes"
```

## OpenBSD

| Variable | Default |
|----------|---------|
| `__redis_user` | `_redis` |
| `__redis_group` | `_redis` |
| `__redis_package` | `redis` |
| `__redis_service` | `redis` |
| `__redis_conf_dir` | `/etc/redis` |
| `__redis_config_default` | see below |
| `__redis_sentinel_logdir` | `/var/log/redis` |

### `__redis_config_default` for OpenBSD

```yaml
__redis_config_default:
  # derived from /usr/local/share/examples/redis/redis.conf of redis-3.2.1 except "save" and "logfile"
  bind: 127.0.0.1
  protected-mode: "yes"
  port: 6379
  tcp-backlog: 511
  timeout: 0
  tcp-keepalive: 300
  daemonize: "yes"
  supervised: "no"
  pidfile: /var/run/redis/redis.pid
  loglevel: notice
  syslog-enabled: "yes"
  syslog-ident: redis
  syslog-facility: daemon
  databases: 16
  stop-writes-on-bgsave-error: "yes"
  rdbcompression: "yes"
  rdbchecksum: "yes"
  dbfilename: dump.rdb
  dir: /var/redis
  slave-serve-stale-data: "yes"
  slave-read-only: "yes"
  repl-diskless-sync: "no"
  repl-diskless-sync-delay: 5
  repl-disable-tcp-nodelay: "no"
  slave-priority: 100
  maxclients: 96
  appendonly: "no"
  appendfilename: "appendonly.aof"
  appendfsync: everysec
  no-appendfsync-on-rewrite: "no"
  auto-aof-rewrite-percentage: 100
  auto-aof-rewrite-min-size: 64mb
  aof-load-truncated: "yes"
  lua-time-limit: 5000
  slowlog-log-slower-than: 10000
  slowlog-max-len: 128
  latency-monitor-threshold: 0
  notify-keyspace-events: '""'
  hash-max-ziplist-entries: 512
  hash-max-ziplist-value: 64
  list-max-ziplist-size: -2
  list-compress-depth: 0
  set-max-intset-entries: 512
  zset-max-ziplist-entries: 128
  zset-max-ziplist-value: 64
  hll-sparse-max-bytes: 3000
  activerehashing: "yes"
  client-output-buffer-limit normal: 0 0 0
  client-output-buffer-limit slave: 256mb 64mb 60
  client-output-buffer-limit pubsub: 32mb 8mb 60
  hz: 10
  aof-rewrite-incremental-fsync: "yes"
```

## RedHat

| Variable | Default |
|----------|---------|
| `__redis_user` | `redis` |
| `__redis_group` | `redis` |
| `__redis_package` | `redis` |
| `__redis_service` | `redis` |
| `__redis_conf_dir` | `/etc` |
| `__redis_config_default` | see below |
| `__redis_sentinel_logdir` | `/var/log/redis` |

### `__redis_config_default` for RedHat

```yaml
__redis_config_default:
  # derived from /etc/redis.conf of redis-2.8.19-2.el7.x86_64
  # except "save"
  daemonize: "no"
  pidfile: /var/run/redis/redis.pid
  port: 6379
  tcp-backlog: 511
  bind: 127.0.0.1
  timeout: 0
  tcp-keepalive: 0
  loglevel: notice
  logfile: /var/log/redis/redis.log
  databases: 16
  stop-writes-on-bgsave-error: "yes"
  rdbcompression: "yes"
  rdbchecksum: "yes"
  dbfilename: dump.rdb
  dir: /var/lib/redis/
  slave-serve-stale-data: "yes"
  slave-read-only: "yes"
  repl-diskless-sync: "no"
  repl-diskless-sync-delay: 5
  repl-disable-tcp-nodelay: "no"
  slave-priority: 100
  appendonly: "no"
  appendfilename: "appendonly.aof"
  appendfsync: everysec
  no-appendfsync-on-rewrite: "no"
  auto-aof-rewrite-percentage: 100
  auto-aof-rewrite-min-size: 64mb
  aof-load-truncated: "yes"
  lua-time-limit: 5000
  slowlog-log-slower-than: 10000
  slowlog-max-len: 128
  latency-monitor-threshold: 0
  notify-keyspace-events: '""'
  hash-max-ziplist-entries: 512
  hash-max-ziplist-value: 64
  list-max-ziplist-entries: 512
  list-max-ziplist-value: 64
  set-max-intset-entries: 512
  zset-max-ziplist-entries: 128
  zset-max-ziplist-value: 64
  hll-sparse-max-bytes: 3000
  activerehashing: "yes"
  client-output-buffer-limit normal: 0 0 0
  client-output-buffer-limit slave: 256mb 64mb 60
  client-output-buffer-limit pubsub: 32mb 8mb 60
  hz: 10
  aof-rewrite-incremental-fsync: "yes"
```

# Dependencies

```yaml
dependencies:
  - { role: reallyenglish.redhat-repo, when: ansible_os_family == 'RedHat' }
```

# Example Playbook

```yaml
- hosts: localhost
  pre_tasks:
  roles:
    - reallyenglish.redhat-repo
    - ansible-role-redis
  vars:
    redis_config:
      databases: 17
      save 900: 1
    redis_password: password
    redhat_repo_extra_packages:
      - epel-release
    redhat_repo:
      epel:
        mirrorlist: "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-{{ ansible_distribution_major_version }}&arch={{ ansible_architecture }}"
        gpgcheck: yes
        enabled: yes
```

# License

```
Copyright (c) 2016 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
