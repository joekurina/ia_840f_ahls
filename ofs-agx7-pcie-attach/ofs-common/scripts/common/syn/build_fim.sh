#!/bin/bash
# Copyright 2023 Intel Corporation
# SPDX-License-Identifier: MIT

##
## Run the full build_fim flow (the "all" stage to build_top.sh)
##
## Two arguments are expected and they are passed to the scripts
## that implement each stage: <build target> <work dir>.
##

SCRIPTNAME="$(basename -- "$0")"
SCRIPT_DIR="$(cd "$(dirname -- "$0")" 2>/dev/null && pwd -P)"

set -e

# IA840F stage guard: before board sourcing, worktree writes or bootstrap.
if [[ "${1:-}" == *ia840f* || "${2:-}" == *ia840f* || "${OFS_BOARD_CORE:-}" == ia840f || -f "${2:-/nonexistent}/syn/board/ia840f/setup/build_gate.tcl" ]]; then
    python3 "$(dirname "${BASH_SOURCE[0]}")/../../../tools/ofss_config/ia840f_experimental_gate.py" native all "${1:-}" "${2:-}" || exit 1
fi


##
## Scripts are NOT sourced in order to avoid polluting the compilation
## stage's environment variables. Compilation with the Quartus GUI and
## build_fim_compile.sh are intended to be identical and loading all
## the environment variables from build_fim_setup.sh would make testing
## this equivalence difficult.
##

"${SCRIPT_DIR}"/build_fim_setup.sh "$@"
"${SCRIPT_DIR}"/build_fim_compile.sh "$@"

# Finish as long as the mode isn't synthesis-only
if [ -z ${ANALYSIS_AND_ELAB_ONLY} ]; then
    "${SCRIPT_DIR}"/build_fim_finish.sh "$@"
fi
