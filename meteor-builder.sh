#!/bin/sh

BUNDLENAME = `basename "$1"`

git clone $1 $BUNDLENAME
cd $BUNDLENAME
meteor npm install --production
meteor build ../build
cd ..
cp build/$BUNDLENAME.tar.gz /data/bundles
rm -rf build
rm -rf $BUNDLENAME
