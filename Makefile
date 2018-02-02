# tools
SHELL := /bin/bash

# env vars
NB_UID := $(shell id -u)
NB_GID := $(shell id -g)

# Default command and help messages
.PHONY: default help
default: help

bash:      ## Run a bash shell inside the app container
shell:     ## Run a bayeslite shell
up:        ## Launch the dev environment

.PHONY: up
up:
ifdef PROBCOMP_LOCAL_DEV
	@bash -c "source activate python2 && jupyter notebook --ip=0.0.0.0"
else
	@NB_UID=${NB_UID} NB_GID=${NB_GID} docker-compose up
endif

.PHONY: bash
bash:
	@docker-compose exec notebook bash

.PHONY: shell
shell:
ifdef PROBCOMP_LOCAL_DEV
	@bash -c "source activate python2 && cd ../bayeslite && python shell/scripts/bayeslite -m"
else
	@docker-compose exec notebook bash -c "source activate python2 && python bayeslite/shell/scripts/bayeslite -m"
endif

.PHONY: ipython
ipython:
ifdef PROBCOMP_LOCAL_DEV
	@bash -c "source activate python2 && ipython"
else
	@docker-compose exec notebook bash -c "source activate python2 && ipython"
endif

.PHONY: bootstrap
bootstrap:
ifdef PROBCOMP_LOCAL_DEV
	@bash bin/bootstrap.sh
else
	@docker-compose exec notebook bash /home/jovyan/developer/bin/bootstrap.sh
endif

.PHONY: bayeslite
bayeslite:
ifdef PROBCOMP_LOCAL_DEV
	@bash -c "source activate python2 && cd ../bayeslite && python setup.py install"
else
	@docker-compose exec notebook bash -c "source activate python2 && cd bayeslite && python setup.py install"
endif

.PHONY: bayeslite-dev
bayeslite-dev:
ifdef PROBCOMP_LOCAL_DEV
	@conda uninstall -n python2 --quiet --yes bayeslite
else
	@docker-compose exec notebook conda uninstall -n python2 --quiet --yes bayeslite
endif

.PHONY: bayeslite-test
bayeslite-test:
ifdef PROBCOMP_LOCAL_DEV
	@bash -c "source activate python2 && cd ../bayeslite && python -m pytest --pyargs bayeslite -k 'not __ci_'"
else
	@docker-compose exec notebook bash -c "source activate python2 && cd bayeslite && python -m pytest --pyargs bayeslite -k 'not __ci_'"
endif
