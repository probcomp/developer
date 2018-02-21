# tools
SHELL := /bin/bash

# env vars
NB_UID := $(shell id -u)

# Default command and help messages
.PHONY: default help
default: help

bash:      ## Run a bash shell inside the app container
up:        ## Launch the dev environment

.PHONY: up
up:
	@NB_UID=${NB_UID} docker-compose -p ${USER} up

.PHONY: down
down:
	@NB_UID=${NB_UID} docker-compose -p ${USER} down

.PHONY: pull
pull:
	@NB_UID=${NB_UID} docker-compose pull

.PHONY: bash
bash:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan -s

.PHONY: ipython
ipython:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan bash -c "source activate python2 && ipython"

.PHONY: bootstrap
bootstrap:
	@bash bin/bootstrap.sh

.PHONY: reinstall
reinstall:
	@bash bin/reinstall.sh

## bayeslite
.PHONY: bayeslite
bayeslite:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan bash -c "source activate python2 && cd bayeslite && rm -rf build && python setup.py build"
.PHONY: bayeslite-develop
bayeslite-develop:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan conda uninstall -n python2 --quiet --yes bayeslite
.PHONY: bayeslite-install
bayeslite-install:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan bash -c "source activate python2 && cd bayeslite && python setup.py install"
.PHONY: bayeslite-test
bayeslite-test:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan bash -c "source activate python2 && cd bayeslite && bash check.sh"

## cgpm
.PHONY: cgpm
cgpm:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan bash -c "source activate python2 && cd cgpm && python setup.py install"
.PHONY: cgpm-develop
cgpm-dev:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan conda uninstall -n python2 --quiet --yes cgpm
.PHONY: cgpm-test
cgpm-test:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan bash -c "source activate python2 && cd cgpm && bash check.sh"

## crosscat
.PHONY: crosscat
crosscat:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan bash -c "source activate python2 && cd crosscat && python setup.py install"
.PHONY: crosscat-develop
crosscat-dev:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan conda uninstall -n python2 --quiet --yes crosscat
.PHONY: crosscat-test
crosscat-test:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan bash -c "source activate python2 && cd crosscat && bash check.sh"

## iventure
.PHONY: iventure
iventure:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan bash -c "source activate python2 && cd iventure && rm -rf build && python setup.py build"
.PHONY: iventure-develop
iventure-develop:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan conda uninstall -n python2 --quiet --yes iventure
.PHONY: iventure-install
iventure-install:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan bash -c "source activate python2 && cd iventure && python setup.py install"
.PHONY: iventure-test
iventure-test:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan bash -c "source activate python2 && cd iventure && bash check.sh"

## tutorials
.PHONY: notebook-test
notebook-test:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -E -u jovyan bash -c "source activate python2 && cd tutorials && python -m pytest"
