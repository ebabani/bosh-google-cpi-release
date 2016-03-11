#!/usr/bin/env bash

set -e

source bosh-cpi-src/ci/tasks/utils.sh
source /etc/profile.d/chruby-with-ruby-2.1.2.sh

check_param google_project
check_param google_region
check_param google_zone
check_param google_json_key_data

echo "Creating google json key..."
mkdir -p $HOME/.config/gcloud/
echo "${google_json_key_data}" > $HOME/.config/gcloud/application_default_credentials.json

echo "Configuring google account..."
gcloud auth activate-service-account --key-file $HOME/.config/gcloud/application_default_credentials.json
gcloud config set project ${google_project}
gcloud config set compute/region ${google_region}
gcloud config set compute/zone ${google_zone}

echo "Tearing down google infrastructure..."
set +e
gcloud -q compute firewall-rules delete bosh-ci-intenal
gcloud -q compute firewall-rules delete bosh-ci-external
gcloud -q compute networks delete bosh-ci
gcloud -q compute addresses delete bosh-ci-director
gcloud -q compute addresses delete bosh-ci-bats
set -e
