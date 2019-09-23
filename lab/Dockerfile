FROM alpine:3.9

ARG LAB_USER_PASSWORD="toor"
ARG LAB_USER_HOME="/home/ccc"
ARG KEY_DIR
ARG USER_PUBLIC_KEYFILE
ARG ROOT_PUBLIC_KEYFILE

# Packages for building software
RUN apk add --no-cache -q build-base gcc abuild binutils \
		binutils-doc gcc-doc

RUN apk update -q && \
    apk add --no-cache -q openssh nmap bash findutils \
    	python3 python3-dev git vim

RUN ln -s $(which python3) /usr/bin/python

###
### Add user ccc (CU Cybersecurity Club)
###
RUN mkdir -p "${LAB_USER_HOME}"
RUN adduser ccc -s /bin/bash --home "${LAB_USER_HOME}" -D
RUN echo -e "${LAB_USER_PASSWORD}\n${LAB_USER_PASSWORD}" | passwd ccc
RUN chown -R ccc "${LAB_USER_HOME}"
RUN chgrp -R ccc "${LAB_USER_HOME}"

###
### SSH configuration
###
RUN mkdir -p "${LAB_USER_HOME}/.ssh" && \
	mkdir -p /root/.ssh
COPY "${USER_PUBLIC_KEYFILE}" /root/.ssh/authorized_keys
COPY "${ROOT_PUBLIC_KEYFILE}" "${LAB_USER_HOME}/.ssh/authorized_keys"
COPY ssh/sshd_config /etc/ssh/sshd_config

# Generate host keys
COPY "${KEY_DIR}/ssh_host_rsa_key" /etc/ssh/ssh_host_rsa_key
COPY "${KEY_DIR}/ssh_host_ecdsa_key" /etc/ssh/ssh_host_ecdsa_key
COPY "${KEY_DIR}/ssh_host_ed25519_key" /etc/ssh/ssh_host/ed25519_key

###
### Add other tools
###
# TheHarvester: https://github.com/laramies/theHarvester
RUN git clone https://github.com/laramies/theHarvester.git \
		--depth 1 "/usr/share/theHarvester"
RUN python -B -m pip install --no-cache-dir -q \
		-r "/usr/share/theHarvester/requirements.txt"
RUN mkdir -p "/usr/sbin" && \
	ln -s "/usr/share/theHarvester/theHarvester.py" "/usr/sbin/theHarvester"

RUN bash -c "\
	cat <(echo '#!/usr/bin/python') \
		<(tail -n +2 '/usr/share/theHarvester/theHarvester.py') > \
		'/usr/share/theHarvester/theHarvester.py'"

# gobuster: https://github.com/OJ/gobuster/
RUN apk add -q go
RUN go get github.com/OJ/gobuster

# nmap: https://nmap.org/
RUN apk add -q nmap

# wfuzz: https://github.com/xmendez/wfuzz/
RUN apk add -q curl curl-dev
RUN wget -q https://github.com/xmendez/wfuzz/archive/v2.3.4.zip \
		-O /tmp/wfuzz.zip && \
	unzip -qq /tmp/wfuzz.zip -d /usr/share/ && \
	rm /tmp/wfuzz.zip
RUN python -B -m pip install --no-cache-dir \
		-r "/usr/share/wfuzz-2.3.4/requirements.txt"	
RUN printf "#\041/bin/sh\n" > /usr/bin/wfuzz && \
	printf "python3 /usr/share/wfuzz-2.3.4/src/wfuzz-cli.py \"\$@\"\n" \
		>> /usr/bin/wfuzz && \
	chmod 755 /usr/bin/wfuzz

###
### Expose required ports for services
###
EXPOSE 22

###
### Run services when container is started
###
COPY root/run.sh /root/run.sh
CMD /root/run.sh && tail -f /dev/null
