#!/bin/bash

rm -rf secrets
mkdir -p secrets

cat <<WHITELIST > secrets/cors_whitelist.txt
http://localhost:8040
WHITELIST

openssl genpkey -algorithm RSA -out secrets/jwt_private.pem -pkeyopt rsa_keygen_bits:4096
openssl rsa -pubout -in secrets/jwt_private.pem -out secrets/jwt_public.pem

MYSQL_ROOT_PASSWORD=`openssl rand -hex 16`

WEBAPI_DOMAIN=0.0.0.0
WEBAPI_PORT=8040

JWT_ACCESS_TOKEN_TIMEOUT=10800
JWT_REFRESH_TOKEN_TIMEOUT=2592000
JWT_ISSUE_URL=
JWT_AUDIENCE=app-auth

DB_HOST=localhost
DB_PORT=9000
DB_USER=root
DB_NAME=owl-update-db
DB_POOL_SIZE=10

cat <<CONFIG > .env
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}

# Web API endpoint
WEBAPI_DOMAIN=${WEBAPI_DOMAIN}
WEBAPI_PORT=${WEBAPI_PORT}

JWT_ACCESS_TOKEN_TIMEOUT=${JWT_ACCESS_TOKEN_TIMEOUT}
JWT_REFRESH_TOKEN_TIMEOUT=${JWT_REFRESH_TOKEN_TIMEOUT}
JWT_ISSUE_URL=${JWT_ISSUE_URL}
JWT_AUDIENCE=${JWT_AUDIENCE}
JWT_PRIVATE_KEY_PATH=`pwd`/secrets/jwt_private.pem
JWT_PUBLIC_KEY_PATH=`pwd`/secrets/jwt_public.pem

CORS_WHITELIST_FILE=`pwd`/secrets/cors_whitelist.txt
GIT_PATH=`pwd`/storage/

LLAMA_HOST_URL=http://owl-update-llama:8000
EMBEDDING_HOST_URL=http://owl-update-embedding:8000


# DB
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_USER=${DB_USER}
DB_PASS=${MYSQL_ROOT_PASSWORD}
DB_NAME=${DB_NAME}
DB_POOL_SIZE=${DB_POOL_SIZE}

CONFIG

cat <<CONFIG > .env.docker
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}

# Web API endpoint
WEBAPI_DOMAIN=${WEBAPI_DOMAIN}
WEBAPI_PORT=${WEBAPI_PORT}


JWT_ACCESS_TOKEN_TIMEOUT=${JWT_ACCESS_TOKEN_TIMEOUT}
JWT_REFRESH_TOKEN_TIMEOUT=${JWT_REFRESH_TOKEN_TIMEOUT}
JWT_ISSUE_URL=${JWT_ISSUE_URL}
JWT_AUDIENCE=${JWT_AUDIENCE}
JWT_PRIVATE_KEY_PATH=/app/secrets/jwt_private.pem
JWT_PUBLIC_KEY_PATH=/app/secrets/jwt_public.pem

CORS_WHITELIST_FILE=/app/secrets/cors_whitelist.txt
GIT_PATH=/app/git/

LLAMA_HOST_URL=http://owl-update-llama:8000
EMBEDDING_HOST_URL=http://owl-update-embedding:8000


# DB
DB_HOST=owl-update-db
DB_PORT=3306
DB_USER=${DB_USER}
DB_PASS=${MYSQL_ROOT_PASSWORD}
DB_NAME=${DB_NAME}
DB_POOL_SIZE=${DB_POOL_SIZE}

CONFIG
