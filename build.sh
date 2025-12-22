#!/bin/bash
set -e

docker build -t ghcr.io/netwarlan/cs16-snowsk337 "$@" .
