# Define variables
CONTROLLER_DOCKERFILE := Controller/Containerfile
WORKER_DOCKERFILE := Server/Containerfile
SSH_FOLDER := ssh_keys


# Default target - Help document
help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  help        : Show this help document"
	@echo "  all         : Check SSH folder, build Controller and Server Container images (default)"
	@echo "  build-controller : Build Controller Container image"
	@echo "  build-server : Build Server Container image"
	@echo "  check-ssh   : Check SSH folder and generate keys if needed"
	@echo "  run-setup   : Will run demo setup with a controller and two server nodes"
	


all: check-ssh build-controller build-server

# Build the Controller Container image
build-controller: check-ssh
	@echo "Building Controller Container image..."
	podman build -t controller -f $(CONTROLLER_DOCKERFILE) .
	@echo "Controller Container image built successfully."

# Build the Server Container image
build-server: check-ssh
	@echo "Building Server Container image..."
	podman build -t server -f $(WORKER_DOCKERFILE) .
	@echo "Server Container image built successfully."

# Check if the SSH folder exists, create it if not, and generate SSH keys
check-ssh:
	@echo "Checking for SSH folder and keys..."
	@if [ ! -d "$(SSH_FOLDER)" ] && [ ! -f "$(SSH_FOLDER)/id_rsa*" ]; then \
		mkdir -p $(SSH_FOLDER); \
		ssh-keygen -t rsa -b 4096 -f $(SSH_FOLDER)/id_rsa -q -N '""'; \
		echo "SSH folder created with keys"; \
	else \
		echo "SSH folder already exists"; \
	fi

# This setup will bringup a controller and two nodes
run-setup:
	@ echo "################# SETUP START #################" 
	@ echo "Create Ansible Network" 
	podman network create --ignore ansible-network 

	@echo "Running Controller..."
	podman run -itd --name controller --network ansible-network localhost/controller:latest

	@echo "Running Server1..."
	podman run -itd --name srvr1 --network ansible-network localhost/server:latest

	@echo "Running Server2..."
	podman run -itd --name srvr2 --network ansible-network localhost/server:latest

	@ echo "################# SETUP END #################" 

.PHONY: all build-controller build-server check-ssh help
