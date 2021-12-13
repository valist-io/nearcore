#!/usr/bin/env bash
set -ex

repo_dir=$(realpath -e "$(dirname "${BASH_SOURCE[0]}")/..")

# Builds and starts `neard`, assumes it's running in ${repo_dir}'
# May fail silently, leading to hard to debug CI failures
# TODO: add option to build only and run checks, this will allow us to see those errors synchronously.
(cd "${repo_dir}"; RUST_BACKTRACE=full "${repo_dir}"/scripts/start_unittest.py --local) &
export NEAR_PID=$!
trap 'pkill -15 -P $NEAR_PID' 0

# "${repo_dir}"/scripts/build_wasm.sh

rm -rf "${repo_dir}"/near-api-js "${repo_dir}"/near-shell "${repo_dir}"/create-near-app
git clone https://github.com/near/near-api-js.git "${repo_dir}"/near-api-js
git clone https://github.com/near/near-shell.git "${repo_dir}"/near-shell
git clone https://github.com/near/create-near-app.git "${repo_dir}"/create-near-app

# Make sure to use local nearcore for tests
export NODE_ENV=local
export HOME="{$repo_dir}"/testdir

# Run near-api-js tests
yarn --version
(cd "${repo_dir}"/near-api-js; yarn)
(cd "${repo_dir}"/near-api-js; yarn build)
"${repo_dir}"/scripts/waitonserver.sh

# TODO(#5757) Disabling yarn test for now
# yarn test
# yarn doc

# Run create-near-app tests
# cd ../create-near-app
# yarn
# yarn test

# Run near-shell tests
# cd ../near-shell
# yarn
# HOME=../testdir yarn test
