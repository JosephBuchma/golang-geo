#!/bin/bash

set -x

export GOPATH=$TDDIUM_REPO_ROOT

# If the bin|pkg|src directories were not supplied by Solano CI's cache:
if [ ! -d bin ] || [ ! -d pkg ] || [ ! -d src ]; then
  go get bitbucket.org/liamstask/goose/cmd/goose
  go get github.com/erikstmartin/go-testdb
fi

# Setup the databases
# postgres
psql -c 'create database points;' -U $TDDIUM_DB_PG_USER -h $TDDIUM_DB_HOST -p $TDDIUM_DB_PG_PORT
# set the db user explicitly since a test will do a string comparison without variable substitution
sed -i.orig "s/user=\$TDDIUM_DB_PG_USER/user=$TDDIUM_DB_PG_USER/g" db/postgres-solano/dbconf.yml
bin/goose -path db/postgres-solano -env test up

# mysql
mysql -e 'create database points;' -u $TDDIUM_DB_MYSQL_USER -h $TDDIUM_DB_HOST -P $TDDIUM_DB_MYSQL_PORT --password=$TDDIUM_DB_MYSQL_PASSWORD
bin/goose -path db/mysql -env test up
