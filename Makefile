.PHONY: create destroy deploy all help

SCRIPT=./scripts/infra.sh

create:
	@$(SCRIPT) create

destroy:
	@$(SCRIPT) destroy

deploy:
	@$(SCRIPT) deploy

all:
	@$(SCRIPT) all

help:
	@$(SCRIPT) help
