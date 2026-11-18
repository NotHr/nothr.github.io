.DEFAULT_GOAL := build
SHELL := bash

DEPLOY_TARGET ?= root@nothr.in:/var/www/site

.PHONY: all build init test check deploy clean help

all: build

build:
	bash ./build.sh

init:
	git submodule update --init --recursive

test check:
	bash ./tests/check.sh

deploy: build
	@command -v rsync >/dev/null 2>&1 || { printf 'Error: install rsync to deploy.\n' >&2; exit 1; }
	rsync -rtvzlP -e ssh site/ "$(DEPLOY_TARGET)"

clean:
	rm -rf -- site .bssg_cache

help:
	@printf '%s\n' \
	  'make          Build the site into site/ (same as make build)' \
	  'make init     Initialize the pinned BSSG submodule' \
	  'make test     Build and run site checks (alias: make check)' \
	  'make deploy   Build, then upload via rsync over SSH' \
	  '              Override with DEPLOY_TARGET=user@host:/path' \
	  'make clean    Remove generated output and cache'
