#!/bin/sh
export ACME_PACKAGED=1
exec /usr/share/acme.sh/acme.sh "$@"