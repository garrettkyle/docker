# Docker

- There are two options to store files on the host machine, volumes and bind mounts (NFS etc, but that's another story)
- Volumes are stored in the hosts's filesystem in `/var/lib/docker/volumes/`
- Per Docker docs, volumes are listed as the "best" way to persist data in Docker
- Both bind mounts and volumes are mounted to containers using the `-v or --volume` flag, seems like they want you to use `--mount` instead though, use mount as default
- After some quick searching it seems volumes are preferably in most situations other than maybe container development, but you would switch to a volume for prod anyways
- create a volume via `docker volume create`
- volumes are stored within a directory on the docker host. volumes can be mounted to multiple containers simultaneously
- The volume will work akin to a shared filesystem like NFS, and can have multiple containers mapped into it and a change on one is immediately
reflected on the others
- Volumes that are no longer being used will not be automatically removed, need to run `docker volume prune` to clean them up
- If you don't explicitly create the volume ahead of time, the volume is created the first time it's mounted into a container
- Volumes don't have to be local, they can be on remote hosts/cloud providers etc (though I'm sure that brings performance penalties)
- Create volumes via `docker volume create <VOLUME_NAME>`
- List volumes via `docker volume ls`
- Inspect (show details) of a volume via `docker volume inspect <VOLUME_NAME>`
- Remove a volume via `docker volume rm <VOLUME_NAME>`

```
docker run -d \
  --name devtest \
  --mount source=myvol2,target=/app \
  nginx:latest
```
The code above would start a detached docker nginx:latest container, call it devtest and mount a local docker host volume in a folder called `myvol12` and mount it to `/app` inside the contianer

- Can mount volumes as readonly
- Can use `volume-subpath`  to mount a volume to a subfolder of a volume as their root
- Looks like there is a variety of storage drivers to try out, like s3 and others, probably wanna try getting some s3 one working
- docker has the following network drivers
  - `bridge` which is the default network driver and allows other containers on the same bridge to talk to each other. used when you want containers to talk to eachother but be isolated from host network, containers can talk to eachother via their IP addresses. can also use a user-defined bridge network.  this one is the new default one to use
  - `host` removes network isolation betwen docker container and the host, it becomes a 1:1 mapping.  The use case seems to be high performance networking applications
  - `overlay` Creates a virtual network that can span multiple docker hosts, kind of like bridge, but spread over many docker hosts, not just on a single one
  - `macvlan` Allows you to asssign a MAC address to each container.  Only really used when you have layer 2 networking constraints it seems.
  - `none` not even sure why/when you would use this one

- The `--network container:<name|id>` option allows a container to share the network namespace of another running container.  This means that this container will literally share the same network interface, IP addy, hostname etc of the container you map it to. It looks like this is useful for sidecar containers, need to chase that down.  Yeah it looks like that is the main use case for this. cuz then you don't ned to configure the sidecar container to access the bridge network etc, it's already locally on the same network, probably just a different port internally.  Def need to explore this.
- When you start a docker container in `bridge` aka default mode, no ports are exposed outside of the container.  To expose a port you run the command `-p <DOCKER_HOST_PORT>:<DOCKER_CONTAINER_PORT>`
- If you include the localhost IP address (127.0.0.1, or ::1) with the publish flag, only the Docker host and its containers can access the published container port. ie: `docker run -p 127.0.0.1:8080:80 nginx`
- You don't need to expose ports to allow docker contianers to talk to each other, the bridge network thing fixes that and allows them all to chat with each other
- By default the container gets an IP address for each docker network it attaches to
- Docker can set up iptables for bridge networks, no iptables rules are created for `ipvlan`, `macvlan` or `host` networks
- Probably use chatgpt to write the various fw rules for me
- Create a user-defined bridge instead of the default bridge to enable the containers to resolve eachother by name or alias.  
- All containers without a `--network` parameter are attached to default bridge network which may allow containers to talk to eachother that shouldn't be able to
- You can connect or disconnect a container to a user-defined bridge on the fly.  to remove a container from default bridge network you need to stop and recreate it with new network options
- User-defined bridge networks are created and configured using `docker network create`
- One downside of user-defined bridges is that they don't automatically share environment variables as they do with the default bridge.  you can work around this by using a docker volume that they all talk to, or else a `docker-compose` file 
- Containers connected to the same user-defined bridge network effectively expose all ports to each other. For a port to be accessible to containers or non-Docker hosts on different networks, that port must be published using the `-p` or `--publish` flag.
- Refer here for `--option` that can be passed when creating a user-defined bridge network: https://docs.docker.com/engine/network/drivers/bridge/
- Create a user-defined network bridge via `docker network create <NETWORK_BRIDGE_NAME>`
- To delete the user-defined network bridge, it's `docker network rm <NETWORK_BRIDGE_NAME>`.  Be sure to disconnect any containers from the network bridge prior to deletion.
```
docker create --name my-nginx \
  --network my-net \
  --publish 8080:80 \
  nginx:latest
  ```
The command above will create an nginx container with port 8080 on the docker host machine mapped to port 80 on the docker container and binds to the user-defined bridge network called `my-net`

To connect a running container to an existing user-defined bridge, use the following command:  `docker network connect <BRIDGE_NAME> <CONTAINER_NAME>` ie `docker network connect my-net my-nginx`

To disconnect a running container from a user-defined bridge use this command:  `docker network disconnect my-net my-nginx`
- Per the docker documentation use of the default bridge network is considered legacy and is not recommended for production
- Due to limitations set by the Linux kernel, bridge networks become unstable and inter-container communications may break when 1000 containers or more connect to a single network
- To configure the restart policy for a container, use the `--restart` flag when using the `docker run` command
- There are different restart policies, the ones that makes the most sense to me are `on-failure[:max-retries]` and `always`
- A restart policy only takes effect after a container starts successfully. Starting successfully means that the container is up for at least 10 seconds and Docker has started monitoring it. This prevents a container which doesn't start at all from going into a restart loop
- If you manually stop a container, the restart policy is ignored until the Docker daemon restarts or the container is manually restarted. This prevents a restart loop.
- Docker can enforce hard or soft memory limits. Hard limits let the container use no more than a fixed amount of memory. When memory reservation is set, Docker detects memory contention or low memory and forces containers to restrict their consumption to a reservation limit..  soft limits are more like the max desired use
- To see container performance metrics use the command `docker stats`
- `docker run [OPTIONS] IMAGE[:TAG|@DIGEST] [COMMAND] [ARG...]`
- `docker run -it <IMAGENAME> sh`  will launch the container and then start an interactive shell within that container - need to circle back on how to connect into that, i think it was docker exec something
- By default the container launches into the foreground and as soon as you exit it, it's destroyed.  To make it persist you use the `-d` flag for `docker run`
- Use the `docker logs` command to view log files from the container (wonder where they are stored at and can they be exported?)
- You can specify memory and cpu constraints for containers via `docker run` parameters
- When you run a container, you can override that CMD instruction just by specifying a new `CMD` option in your `docker run` command
- You can override the container's default entrypoint via something like this: `docker run -it --entrypoint /bin/bash example/redis` so you load into bash on the container instead of redis itself
- In addition to `ENV` environment variables that are baked into the image by the dockerfile, you can pass in additional variables or overwrite them via a command such as `docker run -e "deep=purple" --rm alpine env`
Can set health checks like the following:
```
docker run --name=test -d \
    --health-cmd='stat /etc/passwd || exit 1' \
    --health-interval=2s \
    busybox sleep 1d
```
The example above would check if a file called /etc/passwd was present every 2s and if it wasn't then it woud exit 1 as an error
- The default user in a container is `root`. You can overrride this via passing the `-u` option in `docker run`
- can also change the working directory (aka container root directory) via `WORKDIR` in the dockerfile.  `docker run --rm -w /my/workdir alpine`
- use the `docker images` command to display the currently cached contianer images on that docker host machine
- By default, when the Docker daemon terminates, it shuts down running containers. You can configure the daemon so that containers remain running if the daemon becomes unavailable. This functionality is called live restore.
- Add the configuration to the daemon configuration file. On Linux, this defaults to `/etc/docker/daemon.json`
```
{
  "live-restore": true
}
```
## PROMETHEUS FOR DOCKER:  https://docs.docker.com/engine/daemon/prometheus/

- looks to be quite a few ways to get logs from docker, method is called a logging driver and there is a bunch for different providers like cloudwatch and fluentd

# Dockerfile

- Look up `.dockerignore` file options 
- The `RUN` instruction will execute any commands to create a new layer on top of the current image
- The `ADD` instruction copies new files or directories from `<src>` and adds them to the filesystem of the image at the path `<dest>`. Files and directories can be copied from the build context, a remote URL, or a Git repository. 
- `ADD` if source is a URL it'll basically wget that and dump it at the destination.  if pointed at git it will auto-clone the repo
- This is the preferred way to format this `ENTRYPOINT ["executable", "param1", "param2"]` ie: `ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]`
- `CMD` vs `ENTRYPOINT` boils down to `CMD` should be used as a way of defining default arguments for an `ENTRYPOINT` command or for executing an ad-hoc command in a container
- The `VOLUME` instruction creates a mount point with the specified name and marks it as holding externally mounted volumes from native host or other containers. The value can be a JSON array, VOLUME ["/var/log/"], or a plain string with multiple arguments, such as VOLUME /var/log or VOLUME /var/log /var/db
- The `USER` instruction sets the user name (or UID) and optionally the user group (or GID) to use as the default user and group for the remainder of the current stage
- `WORKDIR` specifies the root working directory in the container
- `HEALTHCHECK` example
```
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost/ || exit 1
```

Sample Dockerfile - Health check will fail if not a webserver being used
```
ARG DEBIAN_FRONTEND=noninteractive
FROM ImageName
RUN <<EOF
apt-get update
apt-get install -y curl
EOF
EXPOSE 80/tcp
EXPOSE 80/udp
ENV MY_NAME="John Doe"
ENV MY_DOG=Rex\ The\ Dog
ENV MY_CAT=fluffy
ADD file1.txt file2.txt /usr/src/things/
ADD https://example.com/archive.zip /usr/src/things/
ADD git@github.com:user/repo.git /usr/src/things/
VOLUME ["/data"]
WORKDIR /path/to/workdir
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost/ || exit 1
```

- To build the image you use `docker build` command 
- An example, given that the `Dockerfile` is in the same directory you run this command from `docker build -t myapp:1.0 .`

- `docker build -t devops:1.0 .` and then `docker run -itd devops:1.0` to launch it then `docker exec-it <CONTAINERID_OR_NAME> /bin/bash`
