#!/bin/bash
set -e

PROBCOMP_EDGE_PACKAGES_URL="https://raw.githubusercontent.com/probcomp/notebook/master/files/conda_probcomp_edge.txt"
PROBCOMP_PACKAGES_URL="https://raw.githubusercontent.com/probcomp/notebook/master/files/conda_probcomp.txt"
PROBCOMP_REPOS="bayeslite cgpm crosscat iventure notebook Venturecxx"

function ask() {
    echo -e -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function installProbcompDocker {
  # install the probcomp libraries
  ask "use edge packages?" && \
    docker-compose -p ${USER} exec notebook bash -c "wget -O /tmp/conda_probcomp.txt --quiet $PROBCOMP_EDGE_PACKAGES_URL && \
        conda install -n python2 --quiet --yes -c probcomp/label/edge -c cidermole -c fritzo -c ursusest \
        --file /tmp/conda_probcomp.txt && \
        conda remove -n python2 --quiet --yes --force qt pyqt" && \
        return 0

  docker-compose -p ${USER} exec notebook bash -c "wget -O /tmp/conda_probcomp.txt --quiet $PROBCOMP_PACKAGES_URL && \
      conda install -n python2 --quiet --yes -c probcomp -c cidermole -c fritzo -c ursusest \
      --file /tmp/conda_probcomp.txt && \
      conda remove -n python2 --quiet --yes --force qt pyqt"
}

ask "reinstall probcomp packages? (notebook container must be running)" && installProbcompDocker
