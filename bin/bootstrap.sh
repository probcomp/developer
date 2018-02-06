#!/bin/bash
set -e

CONDA_DIR=/opt/conda
CONTENT_URL=probcomp-workshop-materials.s3.amazonaws.com/latest.tgz
MINICONDA_VERSION=4.3.30
PATH=$CONDA_DIR/bin:$PATH
PROBCOMP_EDGE_PACKAGES_URL="https://raw.githubusercontent.com/probcomp/notebook/master/files/conda_probcomp_edge.txt"
PROBCOMP_PACKAGES_URL="https://raw.githubusercontent.com/probcomp/notebook/master/files/conda_probcomp.txt"
PROBCOMP_REPOS="bayeslite cgpm crosscat iventure workshop-materials"
PYTHON2_PACKAGES_URL="https://raw.githubusercontent.com/probcomp/notebook/master/files/conda_python2.txt"

export MPLBACKEND=Agg
export XDG_CACHE_HOME=$HOME/.cache/

## local dev is unsupported but you can use it by adding the following to your bashrc
#export MPLBACKEND=Agg
#export PATH=/opt/conda/bin:$PATH
#export PROBCOMP_LOCAL_DEV=yes
#export XDG_CACHE_HOME=$HOME/.cache/
#source activate python2
#alias pytest=py.test

function ask() {
    echo -e -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function installTini {
  sudo bash -c "wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
      echo \"1361527f39190a7338a0b434bd8c88ff7233ce7b9a4876f3315c22fce7eca1b0 *tini\" | sha256sum -c - && \
      mv tini /usr/local/bin/tini && \
      chmod +x /usr/local/bin/tini"
}

function installConda {
  sudo bash -c "mkdir -p $CONDA_DIR && \
      chown $(id -u):$(id -g) $CONDA_DIR"

  # Install conda
  cd /tmp && \
      wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
      echo "0b80a152332a4ce5250f3c09589c7a81 *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
      /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
      rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
      $CONDA_DIR/bin/conda config --system --prepend channels conda-forge && \
      $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
      $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
      $CONDA_DIR/bin/conda update --all --quiet --yes && \
      conda clean -tipsy
}

function installJupyter {
  conda install --quiet --yes \
      'notebook=5.2.*' \
      'jupyterhub=0.8.*' \
      'jupyterlab=0.30.*' \
      && conda clean -tipsy && \
      jupyter labextension install @jupyterlab/hub-extension@^0.7.0 && \
      npm cache clean && \
      rm -rf $CONDA_DIR/share/jupyter/lab/staging
}

function installPython2 {
  # remove existing env if it exists
  conda remove --name python2 --all --yes --quiet >/dev/null 2>&1
  # Install Python 2 packages
  curl -o /tmp/conda_python2.txt -L $PYTHON2_PACKAGES_URL && \
      conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 \
      --file /tmp/conda_python2.txt && \
      conda remove -n python2 --quiet --yes --force qt pyqt
  # Add shortcuts to distinguish pip for python2 and python3 envs
  ln -sf $CONDA_DIR/envs/python2/bin/pip $CONDA_DIR/bin/pip2 && \
      ln -sf $CONDA_DIR/bin/pip $CONDA_DIR/bin/pip3
  # Import matplotlib the first time to build the font cache.
  $CONDA_DIR/envs/python2/bin/python -c "import matplotlib.pyplot"

  # Install Python 2 kernel spec globally to avoid permission problems when NB_UID
  # switching at runtime and to allow the notebook server running out of the root
  # environment to find it. Also, activate the python2 environment upon kernel
  # launch.
  sudo bash -c "pip install kernda --no-cache && \
      $CONDA_DIR/envs/python2/bin/python -m ipykernel install && \
      kernda -o -y /usr/local/share/jupyter/kernels/python2/kernel.json && \
      pip uninstall kernda -y"
}

function installProbcompLocal {
  # install the probcomp libraries
  ask "use edge packages?" && \
    wget -O /tmp/conda_probcomp.txt --quiet $PROBCOMP_EDGE_PACKAGES_URL && \
        conda install -n python2 --quiet --yes -c probcomp/label/edge -c cidermole -c fritzo -c ursusest \
        --file /tmp/conda_probcomp.txt && \
        conda remove -n python2 --quiet --yes --force qt pyqt && \
        return 0

  wget -O /tmp/conda_probcomp.txt --quiet $PROBCOMP_PACKAGES_URL && \
      conda install -n python2 --quiet --yes -c probcomp -c cidermole -c fritzo -c ursusest \
      --file /tmp/conda_probcomp.txt && \
      conda remove -n python2 --quiet --yes --force qt pyqt
}

function installProbcompDocker {
  # install the probcomp libraries
  ask "use edge packages?" && \
    docker-compose exec notebook bash -c "wget -O /tmp/conda_probcomp.txt --quiet $PROBCOMP_EDGE_PACKAGES_URL && \
        conda install -n python2 --quiet --yes -c probcomp/label/edge -c cidermole -c fritzo -c ursusest \
        --file /tmp/conda_probcomp.txt && \
        conda remove -n python2 --quiet --yes --force qt pyqt" && \
        return 0

  wget -O /tmp/conda_probcomp.txt --quiet $PROBCOMP_PACKAGES_URL && \
      docker-compose exec notebook bash -c "conda install -n python2 --quiet --yes -c probcomp -c cidermole -c fritzo -c ursusest \
      --file /tmp/conda_probcomp.txt && \
      conda remove -n python2 --quiet --yes --force qt pyqt"
}

function installNotebooks {
  mkdir work && wget --progress=dot:giga -O - https://${CONTENT_URL} | gunzip -c | tar xf - -C work
}

for i in ${PROBCOMP_REPOS}; do
  if [[ ! -e "../${i}" ]]; then
    ask "${i} repo not found at ../${i}. clone it?" && git clone git@github.com:probcomp/${i}.git ../
  fi
done

#if [[ ! -e "/usr/local/bin/tini" ]]; then
  #ask "tini not found. install it?"
#fi

if [[ -n "${PROBCOMP_LOCAL_DEV}" ]]; then
  if [[ ! -e "/usr/bin/jq" ]]; then
    echo "jq not found. please install it."
    exit 0
  fi
  if [[ ! -e "${CONDA_DIR}/bin/conda" ]]; then
    ask "conda not found. install it?" && installConda
  fi

  if [[ -z $(conda list --json notebook | jq '.[].version') ]]; then
    ask "jupyter notebook not installed. install it?" && installJupyter
  fi

  ask "(re)install python2 environment?" && installPython2

  if [[ ! -e "./work" ]]; then
    ask "example notebooks not found. install them?" && installNotebooks
  fi
  ask "(re)install probcomp packages?" && installProbcompLocal
fi

ask "(re)install probcomp packages? (notebook container must be running)" && installProbcompDocker
