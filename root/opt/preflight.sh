#!/bin/sh
set -eu

# Read optional host UID/GID
PUID="${PUID:-$(id -u acme)}"
PGID="${PGID:-$(id -g acme)}"

USERHOME=$(grep acme /etc/passwd | cut -d ":" -f6)
usermod -d "/root" acme

groupmod -o -g "${PGID}" acme
usermod -o -u "${PUID}" acme >/dev/null

usermod -d "${USERHOME}" acme

# Change permissions on data and cert directories
chown acme:acme "${USERHOME}"
yq .domains[].certs-path "${USERHOME}/config.yaml" | xargs -I {} chown acme:acme "{}"

# Drop privileges and execute
cd "${USERHOME}"
exec gosu acme "$@"
