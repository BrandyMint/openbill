#!/usr/bin/env bash

ROOT=$(dirname "$0")
pushd $ROOT
./tests/create.sh && ./tests/all.sh
popd
