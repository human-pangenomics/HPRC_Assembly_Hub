# include with
#   ROOT=../..
#   include ${ROOT}/defs.mk

.SECONDARY:

MAKEFLAGS += --no-builtin-rules
SHELL = /bin/bash -e -o pipefail

BINDIR = ${ROOT}/bin

PYTHON = python3
FLAKE8 = ${PYTHON} -m flake8

export PYTHONWARNINGS=always
