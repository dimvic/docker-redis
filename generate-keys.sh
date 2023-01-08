#!/bin/sh
set -e

TLS_PATH='/tls'

# https://github.com/redis/redis/blob/unstable/utils/gen-test-certs.sh
# https://github.com/redis/redis/blob/eef29b68a2cd94de1f03aa1b7891af75f5cabae2/utils/gen-test-certs.sh

# Generate some self signed certificates:
#
#   ${TLS_PATH}/ca.{crt,key}          Self signed CA certificate.
#   ${TLS_PATH}/redis.{crt,key}       A certificate with no key usage/policy restrictions.
#   ${TLS_PATH}/client.{crt,key}      A certificate restricted for SSL client usage.
#   ${TLS_PATH}/server.{crt,key}      A certificate restricted for SSL server usage.
#   ${TLS_PATH}/redis.dh              DH Params file.

generate_cert() {
    local name=$1
    local cn="$2"
    local opts="$3"

    local keyfile=${TLS_PATH}/${name}.key
    local certfile=${TLS_PATH}/${name}.crt

    [ -f $keyfile ] || openssl genrsa -out $keyfile 2048
    openssl req \
        -new -sha256 \
        -subj "/O=Redis Self Signed/CN=$cn" \
        -key $keyfile | \
        openssl x509 \
            -req -sha256 \
            -CA ${TLS_PATH}/ca.crt \
            -CAkey ${TLS_PATH}/ca.key \
            -CAserial ${TLS_PATH}/ca.txt \
            -CAcreateserial \
            -days 365 \
            $opts \
            -out $certfile
}

mkdir -p ${TLS_PATH}
[ -f ${TLS_PATH}/ca.key ] || openssl genrsa -out ${TLS_PATH}/ca.key 4096
openssl req \
    -x509 -new -nodes -sha256 \
    -key ${TLS_PATH}/ca.key \
    -days 3650 \
    -subj '/O=Redis Self Signed/CN=Certificate Authority' \
    -out ${TLS_PATH}/ca.crt

cat > ${TLS_PATH}/openssl.cnf <<_END_
[ server_cert ]
keyUsage = digitalSignature, keyEncipherment
nsCertType = server

[ client_cert ]
keyUsage = digitalSignature, keyEncipherment
nsCertType = client
_END_

generate_cert server "Server-only" "-extfile ${TLS_PATH}/openssl.cnf -extensions server_cert"
generate_cert client "Client-only" "-extfile ${TLS_PATH}/openssl.cnf -extensions client_cert"
generate_cert redis "Generic-cert"

[ -f ${TLS_PATH}/redis.dh ] || openssl dhparam -out ${TLS_PATH}/redis.dh 2048

chmod -R 644 ${TLS_PATH}
chmod -R 755 ${TLS_PATH}
