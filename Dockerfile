FROM probcomp/notebook:latest

# need conda-build for develop command to work. pin to 2.1.10 due to: https://github.com/conda/conda-build/issues/1990
RUN conda install --quiet --yes conda-build=2.1.10
RUN conda remove --quiet --yes --force qt pyqt
