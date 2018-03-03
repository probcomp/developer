<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Overview](#overview)
- [Installation](#installation)
	- [Bootstrapping Your Environment](#bootstrapping-your-environment)
	- [Starting Your Environment](#starting-your-environment)
	- [Making Local Changes Take Effect](#making-local-changes-take-effect)
		- [Enable Development Mode](#enable-development-mode)
		- [Build](#build)
- [Running Tests](#running-tests)
	- [Testing Locally](#testing-locally)
	- [Testing on Travis](#testing-on-travis)
- [Releases](#releases)
	- [Releasing Conda Packages](#releasing-conda-packages)
	- [Releasing the Docker Image](#releasing-the-docker-image)
- [Common Commands](#common-commands)
	- [Start the developer environment](#start-the-developer-environment)
	- [Start a bash shell](#start-a-bash-shell)
	- [Start an ipython shell](#start-an-ipython-shell)
	- [Pull the latest version of the image (always try this first if you're having issues)](#pull-the-latest-version-of-the-image-always-try-this-first-if-youre-having-issues)
	- [Reinstalling the probcomp conda packages](#reinstalling-the-probcomp-conda-packages)
	- [Stop and remove the notebook container](#stop-and-remove-the-notebook-container)
- [Docker Tips](#docker-tips)
	- [Increasing D4M Resources](#increasing-d4m-resources)
	- [Sharing the same Docker host with multiple developers](#sharing-the-same-docker-host-with-multiple-developers)
    - [Make additional host directories available inside the container](#make-additional-host-directories-available-inside-the-container)
    - [Using a remote server as a Docker host](#using-a-remote-server-as-a-docker-host)

<!-- /TOC -->
## Overview

This repository contains the developer playground/workstation environment for the [MIT Probabilistic Computing Project](http://probcomp.csail.mit.edu/) [probcomp/notebook](https://hub.docker.com/r/probcomp/notebook/) image. It contains the full probcomp software stack in addition to enabling active development on the various repositories including [bayeslite](https://github.com/probcomp/bayeslite), [cgpm](https://github.com/probcomp/cgpm), [crosscat](https://github.com/probcomp/crosscat), [iventure](https://github.com/probcomp/iventure) and [venturecxx](https://github.com/probcomp/Venturecxx).

## Installation

The docker image and commands in this documentation are tested with docker version `17.12.0-ce` and docker-compose version `1.8.0`. We recommend using these minimum versions.

### Bootstrapping Your Environment

The playground depends on local copies of various probcomp repos in a relative path to this directory. See the [docker-compose.yml](https://github.com/probcomp/developer/blob/master/docker-compose.yml) file for the full list or run the `make bootstrap` command:

```
$ make bootstrap
bayeslite repo not found at ../bayeslite. cloning...
Cloning into '../bayeslite'...
cgpm repo not found at ../cgpm. cloning...
Cloning into '../cgpm'...
crosscat repo not found at ../crosscat. cloning...
Cloning into '../crosscat'
.
.
```

### Starting Your Environment

Start your environment with the `make up` command. Other functionality in this documentation depends on the notebook container being running. Paste the URL from the output into your browser to access the jupyter environment and the tutorial notebooks.

```
$ make up
notebook_1  | Enabling develop on: bayeslite
notebook_1  |   Uninstalling bayeslite conda package
notebook_1  |   Creating bayeslite.egg-link
notebook_1  |   Building bayeslite
notebook_1  | Set username to: jovyan
notebook_1  | usermod: no changes
notebook_1  | Set jovyan UID to: 501
notebook_1  | Granting jovyan sudo access and appending /opt/conda/bin to sudo PATH
notebook_1  | Execute the command: jupyter notebook
notebook_1  | [I 07:20:25.408 NotebookApp] Writing notebook server cookie secret to /home/jovyan/.local/share/jupyter/runtime/notebook_cookie_secret
notebook_1  | [W 07:20:25.630 NotebookApp] WARNING: The notebook server is listening on all IP addresses and not using encryption. This is not recommended.
notebook_1  | [I 07:20:25.636 NotebookApp] Serving notebooks from local directory: /home/jovyan
notebook_1  | [I 07:20:25.636 NotebookApp] 0 active kernels
notebook_1  | [I 07:20:25.636 NotebookApp] The Jupyter Notebook is running at:
notebook_1  | [I 07:20:25.636 NotebookApp] http://[all ip addresses on your system]:8888/?token=cd76eccc16179d46ef93ff866f318940a20b41a9883c7106
notebook_1  | [I 07:20:25.636 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
notebook_1  | [C 07:20:25.637 NotebookApp]
notebook_1  |
notebook_1  |     Copy/paste this URL into your browser when you connect for the first time,
notebook_1  |     to login with a token:
notebook_1  |         http://localhost:8888/?token=cd76eccc16179d46ef93ff866f318940a20b41a9883c7106
```

### Making Local Changes Take Effect

The instructions below assume active development on the [bayeslite](https://github.com/probcomp/bayeslite) repo but this playground environment supports all of the other probcomp public repos as well.

#### Enable Development Mode

Development is enabled by default for the `bayeslite` repo. If you wish to add other repos, pass the `DEVELOP_REPOS` variable to your `make up` command. You can, of course, alternately edit your [docker-compose.yml](https://github.com/probcomp/developer/blob/master/docker-compose.yml#L11) file directly to pass in different environment vairables. If you've already started your environment and want to add repos, run `make down` first.

```
$ make up
notebook_1  | Enabling develop on: bayeslite
.
.
```

```
$ DEVELOP_REPOS="bayeslite iventure" make up
notebook_1  | Enabling develop on: bayeslite iventure
.
.
```

#### Build

Build local sources with `make <REPO_NAME>` to make your changes take effect:

```
make bayeslite
```

## Running Tests

### Testing Locally

Run a repo's test suite with `make <REPO_NAME>-test`:

```
make bayeslite-test
```

### Testing on Travis

[Travis test runs](https://travis-ci.org/probcomp/) can be run automatically by opening a PR against any of the probcomp repos. Additionally, tests automatically run every 24 hours against the master branch to give insight into test stability.

## Releases

### Releasing Conda Packages

Releasing software to the [probcomp anaconda.org channel](https://anaconda.org/probcomp/) occurs automatically when any of the following occurs. The conda label of the package is determined by the event type:

* Adding a tag to master (releases a `main` package)
* Committing or merging a PR to master (releases an `edge` package)
* Adding a tag to a non-master branch (releases a `dev` package)

`main` packages are typically incorporated into the Dockerfile while `edge` packages ensure integration tests against other repos pass and `dev` packages are used for arbitrary additional functionality or testing.

### Releasing the Docker Image

The `probcomp/notebook:latest` and `probcomp/notebook:edge` images are automatically built on any commit to the [probcomp/notebook](https://github.com/probcomp/notebook) repo's master branch. Tagged images are automatically created by pushing a tag to the master branch.

Additionally, the `probcomp/notebook:edge` image is built daily by a [travis job](https://travis-ci.org/probcomp/notebook) to ensure that the latest edge packages are available in said image.

## Common Commands

### Start the developer environment

```
make up
```

### Start a bash shell

```
make bash
```

### Start an ipython shell

```
make ipython
```

### Pull the latest version of the image (always try this first if you're having issues)

```
make pull
```

### Reinstalling the probcomp conda packages

Reset your environment by reinstalling the packages. Effectively the same thing as removing and recreating the container. You can optionally install `edge` versions of packages:

```
make reinstall
```

### Stop and remove the notebook container

```
make down
```

## Docker Tips

### Increasing D4M Resources

The default D4M resource limits are too low for the developer playground. It's recommended that you allocate at least 8GB of RAM and all CPU cores to D4M. Any unused resources will still be available to OSX.

<img src="https://github.com/probcomp/developer/blob/master/images/resources.png" width="250">

If you have sufficient system resources, allocate 32GB of RAM to D4M for optimal developer environment performance.

<img src="https://github.com/probcomp/developer/blob/master/images/resources_high.png" width="250">

### Sharing the same Docker host with multiple developers

Since the `docker-compose.yml` maps port `8888` to the host system, you won't be able to run multiple copies unless you change the port in `docker-compose.yml`.

Additionally, the Makefile automatically prepends your username to container names to avoid namespace collisions.

### Make additional host directories available inside the container

To make additional host directories available from inside the container add additional entries to the YAML list in `docker-compose.yml` at the keypath `services` `notebook` `volumes`. For more information see the [official Docker documentation for the `volumes` key](https://docs.docker.com/compose/compose-file/#volumes).

Additionally, the `Makefile` automatically prepends your username to container names to avoid namespace collisions.

### Using a remote server as a Docker host

If you are using a remote server as a Docker host you will need to ensure that your user is a part of the `docker` group. See the [post-install steps for Linux from the official Docker documentation](https://docs.docker.com/install/linux/linux-postinstall/) for details.

If you are using a remote server as a Docker host and will be using the Jupyter notebook interface you will need to make whichever port is mapped to the remote host system (`8888` by default) accessible by the machine on which you will be running your web browser. The easiest way to do this is via [local port forwarding](https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding#Local_Port_Forwarding).
