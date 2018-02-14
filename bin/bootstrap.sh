#!/bin/bash
set -e

PROBCOMP_REPOS="bayeslite cgpm crosscat iventure notebook Venturecxx"

for i in ${PROBCOMP_REPOS}; do
  if [[ ! -e "../${i}" ]]; then
    echo "${i} repo not found at ../${i}. cloning..." && git clone https://github.com/probcomp/${i}.git ../${i}
  fi
done
