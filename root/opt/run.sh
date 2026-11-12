#!/bin/sh
set -eu

if [ ! -f "./renewal_crontab" ]; then
    echo "$(shuf -i 0-59 -n 1) $(shuf -i 0-23 -n 1) * * * acme.sh --cron" > ./renewal_crontab
fi

if [ ! -d ".acme.sh" ]; then
    echo "Installing acme.sh"
    acme.sh --install
    echo "Installed acme.sh"
fi

# Get account info and register
EMAIL=$(yq .account.email config.yaml)
SERVER=$(yq .account.server config.yaml)

if [ ! "$(find . -name account.json)" ]; then
    echo "Registering account"
    acme.sh --register-account \
        --email "${EMAIL}" \
        --server "${SERVER}"
fi

# request certs for domains and install
for i in $(yq '.domains | keys[]' config.yaml); do
    domain=$(yq ".domains[${i}].domain" config.yaml)
    dns=$(yq ".domains[${i}].dns" config.yaml)
    keylength=$(yq ".domains[${i}].keylength" config.yaml)
    certs_path=$(yq ".domains[${i}].certs-path" config.yaml)
    cert_file=$(yq ".domains[${i}].cert-file" config.yaml)
    key_file=$(yq ".domains[${i}].key-file" config.yaml)
    ca_file=$(yq ".domains[${i}].ca-file" config.yaml)
    fullchain_file=$(yq ".domains[${i}].fullchain-file" config.yaml)

    alts=$(yq '.domains['${i}'].alts | select(length > 0) | "-d " + join(" -d ")' config.yaml)

    if [ $(find "${certs_path}" -name "${key_file}") ]; then
        continue
    fi

    echo "Requesting cert for ${domain}"
    acme.sh --issue \
        --force \
        --dns "${dns}" \
        -d "${domain}" ${alts} \
        --keylength "${keylength}" \
        --server "${SERVER}"

    acme.sh --install-cert \
        -d "${domain}" \
        --cert-file "${certs_path}/${cert_file}" \
        --key-file "${certs_path}/${key_file}" \
        --ca-file "${certs_path}/${ca_file}" \
        --fullchain-file "${certs_path}/${fullchain_file}"

    # Enable web-data group to read key as well
    chmod g+r "${certs_path}/${key_file}"
done

echo 'Listing certs'
acme.sh --list

# Keep the container running
exec /usr/local/bin/supercronic ./renewal_crontab
