# Docker image for FACT_core
This repository mainly contains the `Dockerfile` and `docker-compose.yml` to
build and run a containerized installation of FACT_core.
FACT is split in two images (backend and frontend).

Because FACT uses docker itself, the docker socket from the host will be
passed to the container. Please make sure that your user is a member of the
`docker` group.

# Installation
## Download this repository and the submodules
```sh
git clone --depth=1 https://github.com/ElDavoo/FACT_docker.git
cd FACT_docker
git submodule update --init --recursive
```
## Take a look
Take a look at the docker-compose.yml file and the Dockerfiles.  

1) You might want to customize the nginx config.
2) You might want not to build the images but use the official ones.
3) You might want to not use some services, like cloudflare tunnel and/or radare2.  

### Install config files
```sh
$ cp uwsgi_config.ini.sample uwsgi_config.ini
$ cp fact-core-config.sample fact-core-config.toml
```
Then, edit them as you wish.  

## Composing the environment file
```sh
$ ./start.py compose-env \
    --firmware-file-storage-dir path_to_fw_data_dir > .env
$ echo FACT_DOCKER_POSTGRES_PASSWORD=mypassword >> .env
$ echo FACT_DOCKER_AUTH_DATA_FILE=fact_users.db >> .env
$ docker volume create fact_postgres_data
```
If you are using cloudflare tunnel, 
```sh
$ echo TUNNEL_TOKEN=your-tunnel-token >> .env
```
## Initialize the database (only for the first time)
Build the base and service container:  
```sh
make common scripts
```
Initialize the database:  
```sh
./start.py initialize-db \
    --network fact_docker_fact-network
```
## Pull the plugins' containers
```sh
./start.py pull
```
## Build and run
```sh
$ cd fact_extractor
$ docker build -t fact_extractor .
$ cd ..
$ docker compose up -d --build
```

To shut down the containers use `docker compose stop` (Or press Ctrl+C).
When you want to start them again use `docker compose start`.  

Use `./start.py --help` to get help about the usage of the script.

## Development of FACT\_core in FACT\_docker
Since the FACT\_core is pretty invasive is might be desirable to not install FACT on your system and use this docker image instead.
To have access to a FACT installation you can for example start the container with `--entrypoint /bin/bash`.

## Bugs
FACT\_docker is in early stages and has some bugs that currently can't be fixed due to FACT\_core's architecture.
These bugs are documented here.

### Docker in docker
As FACT uses docker heavily, we pass the docker socket to the container.

One use of docker is the unpacker. Docker is started with something along the
lines of
`docker run -v PATH_ON_DOCKER_HOST:HARDCODED_PATH_USED_IN_THE_CONTAINER unpacker`.

This means that when FACT runs inside a container it must have access to
`PATH_ON_DOCKER_HOST`.
Currently `PATH_ON_DOCKER_HOST` is not always a subdirectory of `docker-mount-base-dir`.
This mostly affects tests (where test data is mounted in containers).
