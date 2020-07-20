#!/usr/bin/env bash
set -eo pipefail
. ./.cicd/helpers/general.sh

mkdir -p $BUILD_DIR

PRE_COMMANDS="cd $MOUNTED_DIR/build"

if [[ $(uname) == 'Darwin' ]]; then

    # You can't use chained commands in execute
    cd $BUILD_DIR
    TEST="./tools/toolchain-tester/toolchain-tester --cdt $BUILD_DIR/bin ../tests/toolchain/"
    bash -c "$TEST"
    
else # Linux

    ARGS=${ARGS:-"--rm --init -v $(pwd):$MOUNTED_DIR"}

    . $HELPERS_DIR/docker-hash.sh

    TEST="./tools/toolchain-tester/toolchain-tester ../tests/toolchain/"
    COMMANDS="$PRE_COMMANDS && $TEST"

    # Load BUILDKITE Environment Variables for use in docker run
    if [[ -f $BUILDKITE_ENV_FILE ]]; then
        evars=""
        while read -r var; do
            evars="$evars --env ${var%%=*}"
        done < "$BUILDKITE_ENV_FILE"
    fi

    eval docker run $ARGS $evars $FULL_TAG bash -c \"$COMMANDS\"

fi
