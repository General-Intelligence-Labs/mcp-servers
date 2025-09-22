#!/usr/bin/env bash

# Care must be taken to ensure that we don't polute stdout, even during the
# build.  Redirect all important output to stderr.

REPO=https://github.com/github/github-mcp-server.git
REVISION=v0.15.0

binary=github-mcp-server/cmd/github-mcp-server/github-mcp-server
lockfile=lock.pid

function build_binary() {
    sleep 5
    git clone -q ${REPO}
    pushd github-mcp-server 1>&2
      git checkout ${REVISION}
      pushd cmd/github-mcp-server 1>&2
        go build
      popd 1>&2
    popd 1>&2
}


# Lock for build checking
while !(set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null; do
    echo "failed to lock ${lockfile} ..." 1>&2
    sleep 2
done

# Delete the file if the process exits prematurely
trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT

if ! [ -e ${binary} ] ; then
    echo "Building ${binary}..." 1>&2
    build_binary
else
    echo "Found ${binary}..." 1>&2
fi

# Release the lock and unset `trap` so other process' lock files are untouched
rm -f "$lockfile"
trap - INT TERM EXIT

${binary} stdio
