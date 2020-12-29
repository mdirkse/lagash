#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"

find "${SCRIPTDIR}" -name "*.pp" -type f | grep -E -v "/forge_modules/" | xargs puppet-lint --no-80chars-check --no-variable_scope-check --no-documentation-chec
find "${SCRIPTDIR}" -name "*.sh" -exec shellcheck {} \;
