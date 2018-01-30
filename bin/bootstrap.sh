#!/bin/bash
set -e

CONDA_DIR=/opt/conda
CONTENT_URL=probcomp-workshop-materials.s3.amazonaws.com/latest.tgz
MINICONDA_VERSION=4.3.30
PATH=$CONDA_DIR/bin:$PATH
PROBCOMP_EDGE_PACKAGES_URL="https://raw.githubusercontent.com/probcomp/notebook/master/files/conda_probcomp_edge.txt"
PROBCOMP_PACKAGES_URL="https://raw.githubusercontent.com/probcomp/notebook/master/files/conda_probcomp.txt"
PYTHON2_PACKAGES_URL="https://raw.githubusercontent.com/probcomp/notebook/master/files/conda_python2.txt"

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
  # Install Python 2 packages
  curl -o /tmp/conda_python2.txt -L $PYTHON2_PACKAGES_URL && \
      conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 \
      --file /tmp/conda_python2.txt
  # Add shortcuts to distinguish pip for python2 and python3 envs
  ln -s $CONDA_DIR/envs/python2/bin/pip $CONDA_DIR/bin/pip2 && \
      ln -s $CONDA_DIR/bin/pip $CONDA_DIR/bin/pip3
}

function installProbcomp {
  # install the probcomp libraries
  ask "use edge packages?" && \
    curl -o /tmp/conda_probcomp.txt -L $PROBCOMP_EDGE_PACKAGES_URL && \
        conda install -n python2 --quiet --yes -c probcomp/label/edge -c cidermole -c fritzo -c ursusest \
        --file /tmp/conda_probcomp.txt && \
        return 0

  curl -o /tmp/conda_probcomp.txt -L $PROBCOMP_PACKAGES_URL && \
      conda install -n python2 --quiet --yes -c probcomp -c cidermole -c fritzo -c ursusest \
      --file /tmp/conda_probcomp.txt
}

function installNotebooks {
  mkdir work && wget --progress=dot:giga -O - https://${CONTENT_URL} | gunzip -c | tar xf - -C work
}

#if [[ ! -e "/usr/local/bin/tini" ]]; then
  #ask "tini not found. install it?"
#fi
if [[ -n "${PROBCOMP_LOCAL_DEV}" ]]; then
  if [[ ! -e "${CONDA_DIR}/bin/conda" ]]; then
    ask "conda not found. install it?" && installConda
  fi

  if [[ -z $(conda list --json notebook | jq '.[].version') ]]; then
    ask "jupyter notebook not installed. install it?" && installJupyter
  fi

  conda list -n python2 >/dev/null
  if [[ ! $? == 0 ]]; then
    ask "python2 environment not installed. install it?" && installPython2
  fi

  if [[ ! -e "./work" ]]; then
    ask "example notebooks not found. install them?" && installNotebooks
  fi
fi

ask "(re)install probcomp packages?" && installProbcomp
