HAS_SUBMODULES = 1

export ADN_COMMON=$(CURDIR)
export REPO_NAME_EXP=ADN_COMMON

export ADN_ENDEC=$(REPO_ROOT)/submodule/adn_endec

.PHONY: compile_all_submodules
compile_all_submodules:
	@make -s compile_submodule SUB=adn_endec
