#!/bin/bash

# /usr/local/percona/pmm2/tools/highram02-testing-instances-usage.sh

declare -a ANYDBVER_INSTANCES;
declare -a MYSQL_INSTANCES;
declare -a MONGO_INSTANCES;
declare -a POSTGRES_INSTANCES;
declare -a VAGRANT_INSTANCES;

PROM_FILE="/usr/local/percona/pmm2/collectors/textfile-collector/low-resolution/highram02-testing-instances-usage.prom"
echo > ${PROM_FILE};

i=0;
for USER_NAME in `ls -1 /home/ | grep ".*\..*" | tr '\n' ' '`; do
  #echo "User is:" $USER_NAME;
  ANYDBVER_INSTANCES[$i]=`lxc ls 2>/dev/null | grep $USER_NAME | grep -c RUNNING`;
  #echo "User is running anydbvers: "${ANYDBVER_INSTANCES[$i]};
  MYSQL_INSTANCES[$i]=`ps -u $USER_NAME -f 2>/dev/null | grep -c mysqld_saf[e]`;
  #echo "User is running mysqls: "${MYSQL_INSTANCES[$i]};
  MONGO_INSTANCES[$i]=`ps -u $USER_NAME -f 2>/dev/null | grep -c mongo[d]`;
  #echo "User is running mongos: "${MONGO_INSTANCES[$i]};
  POSTGRES_INSTANCES[$i]=`ps -u $USER_NAME -f 2>/dev/null | grep -c "postgres: checkpointe[r]"`;
  #echo "User is running postgres: "${POSTGRES_INSTANCES[$i]};
  VAGRANT_INSTANCES[$i]=`sudo -s -u $USER_NAME vagrant global-status --prune 2>/dev/null | grep -c running`;
  #echo "User is running vagrants: "${VAGRANT_INSTANCES[$i]};

  #echo;
  i=$((${i}+1));
done;

#anydbver
{ echo "# HELP highram_usage_anydbver The total number of anydbver instances running per user"
  echo "# TYPE highram_usage_anydbver counter"
} >> ${PROM_FILE};

i=0;
for USER_NAME in `ls -1 /home/ | grep ".*\..*" | tr '\n' ' '`; do
  if [[ ${ANYDBVER_INSTANCES[$i]} -gt 0 ]]; then
    echo highram_usage_anydbver\{node_name=\"highram02\",user=\"${USER_NAME}\"\} ${ANYDBVER_INSTANCES[$i]} \
      >> ${PROM_FILE};
  fi
  i=$((${i}+1));
done;

#mysql
{ echo "# HELP highram_usage_mysql The total number of mysql instances running per user"
  echo "# TYPE highram_usage_mysql counter"
} >> ${PROM_FILE};

i=0;
for USER_NAME in `ls -1 /home/ | grep ".*\..*" | tr '\n' ' '`; do
  if [[ ${MYSQL_INSTANCES[$i]} -gt 0 ]]; then
    echo highram_usage_mysql\{node_name=\"highram02\",user=\"${USER_NAME}\"\} ${MYSQL_INSTANCES[$i]} \
      >> ${PROM_FILE};
  fi
  i=$((${i}+1));
done;

#mongodb
{ echo "# HELP highram_usage_mongodb The total number of mongodb instances running per user"
  echo "# TYPE highram_usage_mongodb counter"
} >> ${PROM_FILE};

i=0;
for USER_NAME in `ls -1 /home/ | grep ".*\..*" | tr '\n' ' '`; do
  if [[ ${MONGO_INSTANCES[$i]} -gt 0 ]]; then
    echo highram_usage_mongodb\{node_name=\"highram02\",user=\"${USER_NAME}\"\} ${MONGO_INSTANCES[$i]} \
      >> ${PROM_FILE};
  fi
  i=$((${i}+1));
done;

#postgresql
{ echo "# HELP highram_usage_postgresql The total number of postgresql instances running per user"
  echo "# TYPE highram_usage_postgresql counter"
} >> ${PROM_FILE};

i=0;
for USER_NAME in `ls -1 /home/ | grep ".*\..*" | tr '\n' ' '`; do
  if [[ ${POSTGRES_INSTANCES[$i]} -gt 0 ]]; then
    echo highram_usage_postgresql\{node_name=\"highram02\",user=\"${USER_NAME}\"\} ${POSTGRES_INSTANCES[$i]} \
      >> ${PROM_FILE};
  fi
  i=$((${i}+1));
done;

#vagrant
{ echo "# HELP highram_usage_vagrant The total number of vagrant instances running per user"
  echo "# TYPE highram_usage_vagrant counter"
} >> ${PROM_FILE};

i=0;
for USER_NAME in `ls -1 /home/ | grep ".*\..*" | tr '\n' ' '`; do
  if [[ ${VAGRANT_INSTANCES[$i]} -gt 0 ]]; then
    echo highram_usage_vagrant\{node_name=\"highram02\",user=\"${USER_NAME}\"\} ${VAGRANT_INSTANCES[$i]} \
      >> ${PROM_FILE};
  fi
  i=$((${i}+1));
done;

chown pmm-agent:pmm-agent ${PROM_FILE};

exit 0;


# crontab -e
# 0 * * * * /usr/local/percona/pmm2/tools/highram02-testing-instances-usage.sh
