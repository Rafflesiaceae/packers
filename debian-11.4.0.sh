#!/bin/bash
set -eo pipefail

build_dir=./build
debug=0
host_name=host.example.org
domain_name=$(echo $host_name | sed 's/\w*\.\(.*\)/\1/')
host_log=$build_dir/packer/$host_name.log
image_name="test"
disk_size=16384
version=0.1.0
python_interpreter=/usr/bin/python3
start_time=$(date --rfc-3339="seconds")

mkdir -p "${build_dir}/packer"
echo Staring build of ${host_name} at ${start_time} for ${image_name} v${version} | tee "${host_log}"

IMAGE_PASSWORD=switching_sides \
PACKER_KEY_INTERVAL=15MS \
PACKER_LOG=1 \
DEBIAN_FRONTEND=text \
DEBCONF_DEBUG=${debug} \
CHECKPOINT_DISABLE=1 \
PACKER_LOG=${debug} \
     packer build \
         -var build_dir="${build_dir}" \
         -var version=${version} \
         -var python_interpreter=${python_interpreter} \
         -var image_name=${image_name} \
         -var disk_size=${disk_size} \
         -var hostname=${host_name} \
         -var domainname="${domain_name}" \
         -on-error=cleanup "./debian-11.4.0.json" 2>&1 | tee -a ${host_log} # on-error=cleanup

echo Stop:  "$(date --rfc-3339="seconds")" | tee -a ${host_log}
