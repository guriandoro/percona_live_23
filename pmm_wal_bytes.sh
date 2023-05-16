#!/bin/bash
wal_lsn_initial=`psql -qtc "select pg_current_wal_lsn()"|head -n1|awk '{print $1}'`

while true; do {
  sleep 5
  wal_lsn_incr=`psql -qtc "select pg_current_wal_lsn()"|head -n1|awk '{print $1}'`
  wal_bytes=`psql -qtc "select pg_wal_lsn_diff('${wal_lsn_incr}','${wal_lsn_initial}')"|head -n1|awk '{print $1}'`
  echo "Written: "${wal_bytes}" bytes."
  echo "Last wal_lsn_incr: "${wal_lsn_incr}

  { echo "# HELP postgresql_wal_bytes The number of bytes written to the PostgreSQL WAL logs."
    echo "# TYPE postgresql_wal_bytes COUNTER"
    echo 'postgresql_wal_bytes{service_name="postgres-pl-extending-pmm-agustin-gallego-node1"} ' ${wal_bytes}
  } | tee /tmp/postgresql_wal.prom.tmp

  mv /tmp/postgresql_wal.prom.tmp /usr/local/percona/pmm2/collectors/textfile-collector/medium-resolution/postgresql_wal.prom

}; done
