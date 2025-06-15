#!/usr/bin/env bash

# Use gcc-toolset-13
source /opt/rh/gcc-toolset-13/enable

# Python virtual environment
PYEXE=python3.12
THIS_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))
VENV_DIR=${THIS_DIR}/.venv
PYREQS_FILE=requirements.txt
VENV_REQS=${THIS_DIR}/${PYREQS_FILE}
VENV_NAME=$(basename ${THIS_DIR})
export VENV_ACT=${VENV_DIR}/bin/activate

# Ariane repo
export ARIANE=${THIS_DIR}

# Toolchain directory
export RISCV=/opt/ariane/ariane-toolchain-20250309

# Questa support
export QUESTA_HOME=/opt/intelFPGA_pro/24.2/questa_fse

# ########################
# ## Helper functions   ##
# ########################

function prepend_path_unique() {
    if [ -n "${PATH}" ]; then
        export PATH=$1:$(sed -r "s,(:$1$)|($1:),,g" <<< "$PATH")
    else
        export PATH=$1
    fi
}

function create_venv() {
    ${PYEXE} -m venv --prompt ${VENV_NAME} ${VENV_DIR}
    . ${VENV_ACT}
    python -m pip install --upgrade pip
    pip install wheel
    if [ ! -f ${VENV_REQS} ]; then
        printf "\n\t${PYREQS_FILE} not found...skipping\n\n"
    else
        printf "\n\tInstalling packages listed in ${PYREQS_FILE}...\n\n"
        pip install -r ${VENV_REQS}
    fi
}

function venv_setup() {
    if [ ! -d ${VENV_DIR} ]; then
        printf " - Python virtual environment NOT found\n"
        printf "  -> Setting up Python virtual environment\n"
        create_venv
    else
        printf " - Python virtual environment found\n"
        printf "  -> Activating Python virtual environment\n"
        . ${VENV_ACT}
    fi
}

# ########################
# ## Setup & run        ##
# ########################

# Create the venv if it does not already exist and/or activate it
venv_setup

# Add Questasim to the path
prepend_path_unique ${QUESTA_HOME}/bin

# Add custom local tools to the path (to override system versions)
prepend_path_unique ${ARIANE}/tools/verilator/bin
prepend_path_unique ${ARIANE}/tools/spike/bin

# Return to setup dir
cd ${THIS_DIR}
