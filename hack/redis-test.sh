#!/usr/bin/env bash

RANDOM_ID="$(od -x /dev/urandom | head -1 | awk '{print $2$4}')"
INPUT_FILE="pwgen_${RANDOM_ID}.out"

_exit() {
  rm "${INPUT_FILE}"
}

trap _exit EXIT

echo >&2 "Generating input file: ${INPUT_FILE}"
pwgen 512 20000 > "${INPUT_FILE}"

echo >&2 "Starting Redis test"
while read -r val; do
  key="$(echo -n $val | md5)";
  res="$(redis-cli --raw set "${key}" "${val}")";
  if [[ $? -ne 0 ]] || [[ "${res:-fail}" != "OK" ]]; then
    echo "failed: $res"
    sleep 0.5
  else
    echo -n .
  fi
done < "${INPUT_FILE}"
