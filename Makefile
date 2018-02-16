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
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook sudo -u jovyan -s

.PHONY: ipython
ipython:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook bash -c "source activate python2 && ipython"

.PHONY: bootstrap
bootstrap:
	@bash bin/bootstrap.sh

.PHONY: reinstall
reinstall:
	@bash bin/reinstall.sh

## bayeslite
.PHONY: bayeslite
bayeslite:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook bash -c "source activate python2 && cd bayeslite && python setup.py install"
.PHONY: bayeslite-dev
bayeslite-dev:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook conda uninstall -n python2 --quiet --yes bayeslite
.PHONY: bayeslite-test
bayeslite-test:
	@NB_UID=${NB_UID} docker-compose -p ${USER} exec notebook bash -c "source activate python2 && cd bayeslite && python -m pytest --pyargs bayeslite -k 'not __ci_'"

## cgpm
.PHONY: cgpm
cgpm:
	@docker-compose -p ${USER} exec notebook bash -c "source activate python2 && cd cgpm && python setup.py install"
.PHONY: cgpm-dev
cgpm-dev:
	@docker-compose -p ${USER} exec notebook conda uninstall -n python2 --quiet --yes cgpm
.PHONY: cgpm-test
cgpm-test:
	@docker-compose -p ${USER} exec notebook bash -c "source activate python2 && cd cgpm && python -m pytest --pyargs cgpm -k 'not __ci_'"

## crosscat
.PHONY: crosscat
crosscat:
	@docker-compose -p ${USER} exec notebook bash -c "source activate python2 && cd crosscat && python setup.py install"
.PHONY: crosscat-dev
crosscat-dev:
	@docker-compose -p ${USER} exec notebook conda uninstall -n python2 --quiet --yes crosscat
.PHONY: crosscat-test
crosscat-test:
	@docker-compose -p ${USER} exec notebook bash -c "source activate python2 && cd crosscat && python -m pytest --pyargs crosscat"

## iventure
.PHONY: iventure
iventure:
	@docker-compose -p ${USER} exec notebook bash -c "source activate python2 && cd iventure && python setup.py install"
.PHONY: iventure-dev
iventure-dev:
	@docker-compose -p ${USER} exec notebook conda uninstall -n python2 --quiet --yes iventure
.PHONY: iventure-test
iventure-test:
	@docker-compose -p ${USER} exec notebook bash -c "source activate python2 && cd iventure && python -m pytest --pyargs iventure -k 'not __ci_'"
