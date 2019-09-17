#!/bin/bash
mkdir -p /tmp/explorer/db
mkdir -p /tmp/explorer/pdgata
mkdir -p /tmp/explorer/walletstore
mkdir -p /tmp/prometheus/storage
mkdir -p /tmp/grafana/storage
curl https://raw.githubusercontent.com/hyperledger/blockchain-explorer/master/app/persistence/fabric/postgreSQL/db/createdb.sh --output /tmp/explorer/db/createdb.sh
cp ../resources/prometheus.yaml /tmp/prometheus
curl https://raw.githubusercontent.com/hyperledger/blockchain-explorer/master/app/platform/fabric/artifacts/operations/balance-transfer/balance-transfer-grafana-dashboard.json --output /tmp/grafana/grafana-dashboard.json
cp -r ../resources/grafana_conf /tmp/grafana
cp -r ../resources/connection-profile /tmp/explorer