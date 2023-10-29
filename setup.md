# Ansible in Containers



## Automated setup using Makefile

#### Pre-requisites

* Podman

#### 1. List all the supported command
```
$ make help
Usage: make [target]
Targets:
  help        : Show this help document
  all         : Check SSH folder, build Controller and Server Container images (default)
  build-controller : Build Controller Container image
  build-server : Build Server Container image
  check-ssh   : Check SSH folder and generate keys if needed
  run-setup   : Will run demo setup with a controller and two server nodes
```

#### 2. For Building Controller Image 

`make build-controller`

#### 3. For Building Server Image 

`make build-server`

#### 4. To Build Both Images 

`make all`

#### 5. Run initial setup

`make run-setup`

## Manual setup

#### Pre-requisites

* Podman
* Podman network

```
podman network create ansible-network

podman network inspect ansible-network
```

### Server Container
1. Build image using Container file

`podman build -t server:latest -f ./server/Containerfile .`

2. Run container using server image

`podman run -itd --name server --network ansible-network localhost/server:latest`

3. Login to container

`podman exec -it server /bin/bash`



### Controller Container 
1. Build image using Container file

`podman build -t controller:latest -f ./Controller/Containerfile .`

2. Run container using controller image

`podman run -itd --name controller --network ansible-network localhost/controller:latest`

3. Login to container

`podman exec -it controller /bin/bash`

4. Run ssh command to connect to server nodes

```
[auto_user@6dcdb14467e6 .ssh]$ ssh auto_user@srvr1
The authenticity of host 'srvr1 (10.89.1.6)' can't be established.
ECDSA key fingerprint is SHA256:SOMEHASH##################    
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'srvr1,10.89.1.6' (ECDSA) to the list of known hosts.
[auto_user@6c6be5867de9 ~]$
```

6. Once key is copied, create inventory file and run ansible command. Here, in inventory file you need to add conatiner name.
```
[auto_user@6dcdb14467e6 /]# echo srvr1 > inventory.ini
[auto_user@6dcdb14467e6 /]# ansible all -m ping -i inventory.ini --become-user auto_user
server | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
```
