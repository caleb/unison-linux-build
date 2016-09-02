FROM debian:jessie
MAINTAINER Caleb Land <caleb@land.fm>

#
# Install and configure a passwordless openssh-server
#
# This installs a wrapper for sshd that copies the environment to /etc/environment
# so that user log ins get the docker environment variables
#
RUN apt-get update \
&&  apt-get install -y openssh-server \
&&  rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/run/sshd \
&&  passwd -d root \
&&  passwd -u -d www-data \
&&  chsh -s /bin/bash www-data \
# Configure PAM to allow passwordless access
&&  echo "# PAM configuration for the Secure Shell service" > /etc/pam.d/sshd \
&&  echo "auth    required pam_unix.so nullok" >> /etc/pam.d/sshd \
&&  echo "session required pam_env.so" >> /etc/pam.d/sshd \
&&  echo "session required pam_env.so user_readenv=1 envfile=/etc/default/locale" >> /etc/pam.d/sshd \
# Copy the sshd pam service to sshd.real since that's what it's run as with the wrapper
&&  cp /etc/pam.d/sshd /etc/pam.d/sshd.real \
# Configure sshd
&&  echo "Port 22" > /etc/ssh/sshd_config \
&&  echo "Protocol 2" >> /etc/ssh/sshd_config \
&&  echo "HostKey /etc/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config \
&&  echo "HostKey /etc/ssh/ssh_host_dsa_key" >> /etc/ssh/sshd_config \
&&  echo "HostKey /etc/ssh/ssh_host_ecdsa_key" >> /etc/ssh/sshd_config \
&&  echo "HostKey /etc/ssh/ssh_host_ed25519_key" >> /etc/ssh/sshd_config \
&&  echo "UsePrivilegeSeparation yes" >> /etc/ssh/sshd_config \
&&  echo "KeyRegenerationInterval 3600" >> /etc/ssh/sshd_config \
&&  echo "ServerKeyBits 1024" >> /etc/ssh/sshd_config \
&&  echo "SyslogFacility AUTH" >> /etc/ssh/sshd_config \
&&  echo "LogLevel INFO" >> /etc/ssh/sshd_config \
&&  echo "LoginGraceTime 120" >> /etc/ssh/sshd_config \
&&  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
&&  echo "StrictModes yes" >> /etc/ssh/sshd_config \
&&  echo "RSAAuthentication yes" >> /etc/ssh/sshd_config \
&&  echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config \
&&  echo "IgnoreRhosts yes" >> /etc/ssh/sshd_config \
&&  echo "RhostsRSAAuthentication no" >> /etc/ssh/sshd_config \
&&  echo "HostbasedAuthentication no" >> /etc/ssh/sshd_config \
&&  echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config \
&&  echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config \
&&  echo "PrintMotd no" >> /etc/ssh/sshd_config \
&&  echo "PrintLastLog yes" >> /etc/ssh/sshd_config \
&&  echo "TCPKeepAlive yes" >> /etc/ssh/sshd_config \
&&  echo "AcceptEnv LANG LC_*" >> /etc/ssh/sshd_config \
&&  echo "Subsystem sftp /usr/lib/openssh/sftp-server" >> /etc/ssh/sshd_config \
&&  echo "UsePAM yes" >> /etc/ssh/sshd_config \
&&  echo "UseDNS no" >> /etc/ssh/sshd_config \
&&  echo "PermitUserEnvironment yes" >> /etc/ssh/sshd_config \
# Create the sshd wrapper
&&  mv /usr/sbin/sshd /usr/sbin/sshd.real \
&&  echo "#!/usr/bin/env bash" > /usr/sbin/sshd \
&&  echo "env > /etc/environment" >> /usr/sbin/sshd \
&&  echo 'exec /usr/sbin/sshd.real "${@}"' >> /usr/sbin/sshd \
&&  chmod +x /usr/sbin/sshd \
# Add the current path to /etc/profile
&&  echo "PATH=\"$PATH\"" >> /etc/profile

RUN apt-get update
RUN apt-get install -y build-essential ocaml
RUN apt-get install -y emacs-nox

ADD unison-2.48.4.tar.gz /
RUN cd /src \
&&  make UISTYLE=text NATIVE=true STATIC=true \
&&  mv unison /usr/local/bin \
&&  mv unison-fsmonitor /usr/local/bin

CMD /usr/sbin/sshd -D
