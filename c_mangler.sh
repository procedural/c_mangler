#!/bin/bash
cd "$(dirname -- "$(readlink -fn -- "${0}")")"
echo "#pragma once" > /tmp/c_mangler.h
for name in `nm --no-sort --defined-only --extern-only "${1}" | cut -d ' ' -f3`; do
  echo "#define $name _`openssl rand -hex 32`" >> /tmp/c_mangler.h
done
IFS=$'\n'; set -f
for file in `find . -name "*.c" -or -name "*.h"`; do
  if [ "`head -n 1 "${file}"`" != '#include "/tmp/c_mangler.h"' ]; then
    echo '#include "/tmp/c_mangler.h"' > /tmp/c_mangler_temp_file
    cat "${file}" >> /tmp/c_mangler_temp_file
    mv /tmp/c_mangler_temp_file "${file}"
  fi
done
unset IFS; set +f