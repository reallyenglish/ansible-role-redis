#!/bin/sh

set -e

file=$1
if [ -f "${file}" ]; then
  echo "cannot find file: ${file}" >2
fi

file_name=`basename "${file}"`
module_name=`echo "${file_name}" | cut -f1 -d'.'`
dest_dir=`dirname "${file}"`

mod_file="${dest_dir}/${module_name}.mod"
pp_file="${dest_dir}/${module_name}.pp"

checkmodule -M -m -o "${mod_file}" "${file}"
semodule_package -o "${pp_file}" -m "${mod_file}"
semodule -i "${pp_file}"
