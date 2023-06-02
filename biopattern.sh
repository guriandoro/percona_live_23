#!/bin/bash

# /usr/local/percona/pmm2/tools/highram02-testing-instances-usage.sh

PROM_FILE="/usr/local/percona/pmm2/collectors/textfile-collector/high-resolution/biopattern.prom"
echo > ${PROM_FILE};

chown pmm-agent:pmm-agent ${PROM_FILE};

for i in `seq 15`; do
  ebpf_biopattern_array_str=`/usr/share/bcc/tools/biopattern 1 1 | tail -n1 | awk '{print $3,$4,$5,$6}'`
  IFS=' ' read -r -a ebpf_biopattern_array <<< $ebpf_biopattern_array_str
  
  echo > ${PROM_FILE};
  echo "ebpf_biopattern_rnd{node_name=\"ip-172-31-93-148.ec2.internal-mysql\",disk=\"nvme2n1\"} ${ebpf_biopattern_array[0]}" >> ${PROM_FILE};
  echo "ebpf_biopattern_seq{node_name=\"ip-172-31-93-148.ec2.internal-mysql\",disk=\"nvme2n1\"} ${ebpf_biopattern_array[1]}" >> ${PROM_FILE};
  echo "ebpf_biopattern_cnt{node_name=\"ip-172-31-93-148.ec2.internal-mysql\",disk=\"nvme2n1\"} ${ebpf_biopattern_array[2]}" >> ${PROM_FILE};
  echo "ebpf_biopattern_kbs{node_name=\"ip-172-31-93-148.ec2.internal-mysql\",disk=\"nvme2n1\"} ${ebpf_biopattern_array[3]}" >> ${PROM_FILE};

  # 15 times x 3 seconds + 15 times x 1 second command
  sleep 3;
done;

exit 0;

# crontab -e
# * * * * * /usr/local/percona/pmm2/tools/biopattern.sh
