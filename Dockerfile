FROM probcomp/notebook:latest

RUN conda uninstall -n python2 --yes bayeslite
COPY bin/docker-entrypoint.sh /usr/bin
