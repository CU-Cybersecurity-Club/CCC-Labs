# Makefile for building the docker container

LAB=./lab
KEY_DIR=./keys
USER_KEYFILE="$(KEY_DIR)/user-docker-keys"
ROOT_KEYFILE="$(KEY_DIR)/root-docker-keys"
TARGET=docker

docker: ssh-keys ssh-host-keys
	docker-compose build \
		--build-arg KEY_DIR=$(KEY_DIR) \
		--build-arg USER_PUBLIC_KEYFILE=$(USER_KEYFILE).pub \
		--build-arg ROOT_PUBLIC_KEYFILE=$(ROOT_KEYFILE).pub lab

ssh-keys:
	-mkdir -p $(KEY_DIR)
	-test ! -e $(LAB)/$(USER_KEYFILE) && \
		ssh-keygen -q -t rsa -b 4096 -f $(LAB)/$(USER_KEYFILE)
	-test ! -e $(LAB)/$(ROOT_KEYFILE) && \
		ssh-keygen -q -t rsa -b 4096 -f $(LAB)/$(ROOT_KEYFILE)

ssh-host-keys:
	-mkdir -p $(KEY_DIR)
	-test ! -e $(LAB)/$(KEY_DIR)/ssh_host_rsa_key && \
		ssh-keygen -t rsa -b 4096 -f $(LAB)/$(KEY_DIR)/ssh_host_rsa_key -N '' -q
	-test ! -e $(LAB)/$(KEY_DIR)/ssh_host_ecdsa_key && \
		ssh-keygen -t ecdsa -f $(LAB)/$(KEY_DIR)/ssh_host_ecdsa_key -N '' -q
	-test ! -e $(LAB)/$(KEY_DIR)/ssh_host_ed25519_key && \
		ssh-keygen -t ed25519 -f $(LAB)/$(KEY_DIR)/ssh_host_ed25519_key -N '' -q

clean:
	-rm -rf $(LAB)/$(KEY_DIR)
	-docker container prune -f
	-docker rmi ccc-lab:latest
	-docker rmi ccc-metasploit:latest
	-docker system prune -f
