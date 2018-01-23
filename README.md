# developer

## Docker vs Local Dev

Makefile commands and the bootstrap.sh script default to docker-based development. To change to local dev, run or add the following to your .bashrc:

```
export PROBCOMP_LOCAL_DEV=yes
```

## Local copies of repos

The environment assumes a relative path to git clones of the probcomp repos such as:

```
../bayeslite
../cgpm
../crosscat
```

Clone these yourself or run the bootstrap script to download them automatically.

## Common Commands

### Start Jupyter

```
make up
```

Output will show you a local URL to access jupyter:

```
notebook_1  |     Copy/paste this URL into your browser when you connect for the first time,
notebook_1  |     to login with a token:
notebook_1  |         http://localhost:8888/?token=b032fbc6928fdaecc3bd7800f1b90f36a5a4ed99d5c7d59a
```

### Start ipython

```
make ipython
```

### Enable development mode

When you first setup your devlopment environment or if you restart the docker container, you'll need to enable development mode by first uninstalling the conda package. Run `make <REPO_NAME>-dev` to uninstall the conda package and use your local repo instead:

```
make bayeslite-dev
```

### Installing and/or making local changes take effect

Build and install from local sources and re-run to make changes take effect with `make <REPO_NAME>`:

```
make bayeslite
```

### Run a shell inside the docker container

```
make shell
```
