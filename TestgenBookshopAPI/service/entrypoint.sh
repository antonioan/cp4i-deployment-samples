#!/bin/bash

for d in $(find /src /libs -name node_modules -prune -o -name package.json -print); do
	cd $(dirname $d)
	npm install
	cd -
done

node -r ./tracing.js app.js

