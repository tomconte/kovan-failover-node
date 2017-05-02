#!/bin/bash

# Executed as Azure user.

ACCOUNT_PHRASE=$1
ACCOUNT_PASSWORD=$2

# Run Parity

parity daemon parity.pid --log-file parity.log --auto-update=all --force-sealing --chain kovan --jsonrpc-apis "web3,eth,net,personal,parity_set"

# Wait a few seconds to let Parity start
# TODO: find a better way

sleep 5

# Create account

json_request='{"jsonrpc":"2.0","method":"parity_newAccountFromPhrase","params":["'${ACCOUNT_PHRASE}'","'${ACCOUNT_PASSWORD}'"],"id":1}'
response=$(echo $json_request | nc -q 1 -U ./.local/share/io.parity.ethereum/jsonrpc.ipc)
address=$(echo $response | python -c 'import sys, json; print json.load(sys.stdin)["result"]')

# Run watchguard Node.JS app

git clone https://github.com/paritytech/kovan-watchguard.git
cd kovan-watchguard
npm install

cp pm2.template.js kovan-watchguard.json
sed -i "s/<address to scan for and sign with>/${address}/" kovan-watchguard.json
sed -i "s/<address to unlock the signer address>/${ACCOUNT_PASSWORD}/" kovan-watchguard.json

pm2 start kovan-watchguard.json
