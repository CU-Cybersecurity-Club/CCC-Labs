# Makefile for building the docker container

IMG_NAME=ccc-env
KEY_DIR=./keys
USER_KEYFILE="$(KEY_DIR)/user-docker-keys"
ROOT_KEYFILE="$(KEY_DIR)/root-docker-keys"
TARGET=docker

docker: ssh-keys ssh-host-keys
	docker build -t "$(IMG_NAME)" --network host \
		--build-arg KEY_DIR="$(KEY_DIR)" \
		--build-arg USER_PUBLIC_KEYFILE="$(USER_KEYFILE).pub" \
		--build-arg ROOT_PUBLIC_KEYFILE="$(ROOT_KEYFILE).pub" .

ssh-keys:
	-mkdir -p "$(KEY_DIR)"
	-test ! -e "$(USER_KEYFILE)" && \
		ssh-keygen -q -t rsa -b 4096 -f "$(USER_KEYFILE)"
	-test ! -e "$(ROOT_KEYFILE)" && \
		ssh-keygen -q -t rsa -b 4096 -f "$(ROOT_KEYFILE)"

ssh-host-keys:
	-mkdir -p "$(KEY_DIR)"
	-test ! -e "$(KEY_DIR)/ssh_host_rsa_key" && \
		ssh-keygen -t rsa -b 4096 -f "$(KEY_DIR)/ssh_host_rsa_key" -N '' -q
	-test ! -e "$(KEY_DIR)/ssh_host_ecdsa_key" && \
		ssh-keygen -t ecdsa -f "$(KEY_DIR)/ssh_host_ecdsa_key" -N '' -q
	-test ! -e "$(KEY_DIR)/ssh_host_ed25519_key" && \
		ssh-keygen -t ed25519 -f "$(KEY_DIR)/ssh_host_ed25519_key" -N '' -q

clean:
	-rm -rf "$(KEY_DIR)"
	-docker container prune -f
	-docker rmi "$(IMG_NAME)"
	-docker system prune -f
