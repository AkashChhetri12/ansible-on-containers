# Ansible in Containers

#### Pre-requisites

* Podman
* Podman network

```
podman network create ansible-network

podman network inspect ansible-network
```

### Server Container
1. Build image using Container file

`podman build -t server:latest -f ./server/Containerfile `

2. Run container using server image

`podman run -itd --name server --network ansible-network localhost/server:latest`

3. Login to container

`podman exec -it server /bin/bash`

4. Generate root password
```
[root@5d59897ea265 /]# passwd
Changing password for user root.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.
```

### Controller Container 
1. Build image using Container file

`podman build -t controller:latest -f ./controller/Containerfile `

2. Run container using controller image

`podman run -itd --name controller --network ansible-network localhost/controller:latest`

3. Login to container

`podman exec -it controller /bin/bash`

4. Generate ssh key for controller to connect with server nodes

`[root@604b92c66c05 /]# ssh-keygen`

5. Copy public key to server node to establish ssh connection
```
[root@604b92c66c05 /]# ssh-copy-id root@server
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@server's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'root@server'"
and check to make sure that only the key(s) you wanted were added.
```

6. Once key is copied, create inventory file and run ansible command. Here, in inventory file you need to add conatiner name.
```
[root@604b92c66c05 /]# echo server > inventory.ini
[root@604b92c66c05 /]# ansible all -m ping -i inventory.ini
server | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
```
