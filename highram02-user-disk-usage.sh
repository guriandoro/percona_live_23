#!/bin/bash

# /usr/local/percona/pmm2/tools/highram02-user-disk-usage.sh

declare -a HOME_USAGE;
declare -a BIGDISK_USAGE;

PROM_FILE="/usr/local/percona/pmm2/collectors/textfile-collector/low-resolution/highram02-user-disk-usage.prom"
echo > ${PROM_FILE};

i=0;
for USER_NAME in `ls -1 /home/ | grep ".*\..*" | tr '\n' ' '`; do
  #echo "User is:" $USER_NAME;
  HOME_USAGE[$i]=`sudo -s -u $USER_NAME du -sb /home/$USER_NAME/ 2>/dev/null | awk '{print $1}'`;
  #echo "User's home dir is using: "${HOME_USAGE[$i]};
  
  #echo;
  i=$((${i}+1));
done;

i=0;
for DIR_NAME in `ls -1 /bigdisk/ | tr '\n' ' '`; do
  #echo "Dir is:" $DIR_NAME;
  BIGDISK_USAGE[$i]=`sudo -s du -sb /bigdisk/$DIR_NAME/ 2>/dev/null | awk '{print $1}'`;
  #echo "Dir is using: "${BIGDISK_USAGE[$i]};
  
  #echo;
  i=$((${i}+1));
done;

#home dir
{ echo "# HELP highram_home_space_usage The total number of bytes used in the home directory per user"
  echo "# TYPE highram_home_space_usage counter"
} >> ${PROM_FILE};

i=0;
for USER_NAME in `ls -1 /home/ | grep ".*\..*" | tr '\n' ' '`; do
  if [[ ${HOME_USAGE[$i]} -gt 0 ]]; then
    echo highram_home_space_usage\{node_name=\"highram02\",user=\"${USER_NAME}\"\} ${HOME_USAGE[$i]} \
      >> ${PROM_FILE};
  fi
  i=$((${i}+1));
done;

#bigdisk dir
{ echo "# HELP highram_bigdisk_space_usage The total number of bytes used in the home directory per user"
  echo "# TYPE highram_bigdisk_space_usage counter"
} >> ${PROM_FILE};

i=0;
for DIR_NAME in `ls -1 /bigdisk/ | tr '\n' ' '`; do
  if [[ ${BIGDISK_USAGE[$i]} -gt 0 ]]; then
    echo highram_bigdisk_space_usage\{node_name=\"highram02\",user=\"${DIR_NAME}\"\} ${BIGDISK_USAGE[$i]} \
      >> ${PROM_FILE};
  fi
  i=$((${i}+1));
done;

chown pmm-agent:pmm-agent ${PROM_FILE};

exit 0;
