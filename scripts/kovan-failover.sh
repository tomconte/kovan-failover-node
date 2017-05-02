#!/bin/bash

# Executed as root.

PARITY_URL='https://vanity-service.ethcore.io/parity-binaries?version=beta&format=json&os=linux&architecture=x86_64'
USER_SCRIPT='kovan-failover-user.sh'

AZUREUSER=$1
ARTIFACTS_URL=$2
ACCOUNT_PHRASE=$3
ACCOUNT_PASSWORD=$4

HOMEDIR="/home/${AZUREUSER}"

# Install Node.JS

apt-get update && apt-get -y install nodejs nodejs-legacy npm git

# Install PM2

npm install pm2 -g

# Install Parity

cd $(mktemp -d)

json=$(curl --silent ${PARITY_URL})
echo $json

parity_file=$(echo ${json} | python -c 'import sys, json; print json.load(sys.stdin)[0]["files"][1]["name"]')
parity_deb=$(echo ${json} | python -c 'import sys, json; print json.load(sys.stdin)[0]["files"][1]["downloadUrl"]')
wget --no-verbose $parity_deb
dpkg -i $parity_file

# Run script as regular user

cd ${HOMEDIR}
wget --no-verbose "${ARTIFACTS_URL}scripts/${USER_SCRIPT}"
chown ${AZUREUSER} ${USER_SCRIPT}
chmod +x ${USER_SCRIPT}
su -l ${AZUREUSER} -c "${HOMEDIR}/${USER_SCRIPT} \"${ACCOUNT_PHRASE}\" \"${ACCOUNT_PASSWORD}\""
