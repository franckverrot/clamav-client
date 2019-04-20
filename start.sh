#!/bin/bash
set -ex

service clamav-daemon start

exec "$@"