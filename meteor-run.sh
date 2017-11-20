#!/bin/sh

tar -zxf /data/bundles/$1
cd bundle/programs/server
npm install
cd ../..
node ./main.js