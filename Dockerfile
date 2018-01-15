FROM probcomp/notebook:latest

RUN conda uninstall -n python2 --yes bayeslite
RUN git clone https://github.com/probcomp/bayeslite.git && cd bayeslite && git checkout 20180115-avinson-pip-editable
RUN bash -c "cd bayeslite && source activate python2 && pip install -e ."
