export SHELL=/bin/bash

include ext.mk

####################################################################################################
# Variables
####################################################################################################

export REPO_FILE_EXT=$(shell echo $(REPO_NAME_EXP) | tr '[:upper:]' '[:lower:]')

REPO_ROOT := $(CURDIR)

BUILD_DIR := $(REPO_ROOT)/build
LOG_DIR := $(REPO_ROOT)/log
COVERAGE_DIR := $(REPO_ROOT)/coverage
DOCUMENTER := $(REPO_ROOT)/submodule/documenter
SOURCE_DOC_DIR := $(REPO_ROOT)/document/source

TOP   := hello
TN    := default
TC    := 1
GUI   := 0
VCD   := 0
DEBUG := 0

####################################################################################################
# Tools
####################################################################################################

XVLOG  ?= xvlog
XELAB  ?= xelab
XSIM   ?= xsim
PYTHON ?= python

####################################################################################################
# Macros
####################################################################################################

O_EW :=  | (grep -iE "Error|Warning" --color=auto || true)
H_EW :=  | (grep -iE "Error|Warning|" --color=auto)

LINE_1 := This file is part of https://github.com/ADN-VLSI/$(REPO_FILE_EXT)
LINE_2 := Copyright (c) $(shell date +%Y) ADN Semiconductors
LINE_3 := Licensed under the MIT License
LINE_4 := See LICENSE file in the project root for full license information

####################################################################################################
# Rules
####################################################################################################

$(BUILD_DIR) $(LOG_DIR) $(COVERAGE_DIR):
	@echo -e "\033[1;33m#\033[0m Creating directory $@"
	@mkdir -p $@
	@echo "*" > $@/.gitignore

.PHONY: clean
clean:
	@echo -e "\033[1;33m#\033[0m Cleaning build directory"
	@rm -rf $(BUILD_DIR)

.PHONY: clean_full
clean_full:
	@make -s clean
	@echo -e "\033[1;33m#\033[0m Cleaning log directories"
	@rm -rf $(LOG_DIR)
	@echo -e "\033[1;33m#\033[0m Cleaning coverage directories"
	@rm -rf $(COVERAGE_DIR)

.PHONY: $(REPO_ROOT)/reuse.f
$(REPO_ROOT)/reuse.f:
	@echo -e "\033[1;33m#\033[0m Generating Source Filelist"
	@echo "-i $(REPO_ROOT)/include" > $(REPO_ROOT)/reuse.f
	@echo "ADD INTERFACE FILES"
	@find $(REPO_ROOT)/source -maxdepth 1 -name "*.sv" >> $(REPO_ROOT)/reuse.f
	@sed -i 's|$(REPO_ROOT)|$$\{$(REPO_NAME_EXP)\}|g' $(REPO_ROOT)/reuse.f

.PHONY: $(REPO_ROOT)/local.f
$(REPO_ROOT)/local.f:
	@echo -e "\033[1;33m#\033[0m Generating Testbench Filelist"
	@find $(REPO_ROOT)/testbench -maxdepth 1 -name "*.sv" > $(REPO_ROOT)/local.f
	@sed -i 's|$(REPO_ROOT)|$$\{$(REPO_NAME_EXP)\}|g' $(REPO_ROOT)/local.f

.PHONY: $(BUILD_DIR)/XSIM_ARGS
$(BUILD_DIR)/XSIM_ARGS:
ifeq ($(GUI), 0)
	@echo "-runall" > $@
else
	@echo "-gui --autoloadwcfg --view $(REPO_ROOT)/wcfg/$(TOP).wcfg" > $@
endif
	@echo "--testplusarg TN=$(TN)" >> $@
	@echo "--testplusarg TC=$(TC)" >> $@
	@echo "--testplusarg VCD=$(VCD)" >> $@
	@echo "--testplusarg DEBUG=$(DEBUG)" >> $@

.PHONY: all
all:
	@make -s $(BUILD_DIR)
	@make -s $(LOG_DIR)
	@make -s $(REPO_ROOT)/reuse.f
	@make -s $(REPO_ROOT)/local.f
	@make -s $(BUILD_DIR)/XSIM_ARGS GUI=$(GUI) TN=$(TN) TC=$(TC) VCD=$(VCD) DEBUG=$(DEBUG)
	@echo -e "\033[1;33m#\033[0m Compiling $(REPO_ROOT)"
	@cd $(BUILD_DIR) && $(XVLOG) -sv -f $(REPO_ROOT)/reuse.f -f $(REPO_ROOT)/local.f -log $(LOG_DIR)/xvlog_$(shell date +%Y%m%d_%H%M%S).log $(O_EW)
# TODO: Add Submodule compilation
	@echo -e "\033[1;33m#\033[0m Elaborating $(TOP)"
	@cd $(BUILD_DIR) && $(XELAB) $(TOP) -s snap_$(TOP) -debug all -log $(LOG_DIR)/xelab_$(TOP)_$(shell date +%Y%m%d_%H%M%S).log $(O_EW)
	@echo -e "\033[1;33m#\033[0m Simulating TOP:$(TOP) Test:$(TN) Count:$(TC)"
	@cd $(BUILD_DIR) && $(XSIM) snap_$(TOP) -f $(BUILD_DIR)/XSIM_ARGS -log $(LOG_DIR)/xsim_$(TOP)_$(shell date +%Y%m%d_%H%M%S).log $(H_EW)
ifneq ($(VCD), 0)
	@echo -e "\033[1;33m#\033[0m Loading VCD waveform file"
	@gtkwave $(REPO_ROOT)/wcfg/$(TOP).gtkw || gtkwave $(BUILD_DIR)/$(TOP).vcd
endif

####################################################################################################
# Update Doc List
####################################################################################################

.PHONY: update_doc_list
update_doc_list:
	@make -s create_all_docs
	@cat readme_base.md > readme.md
	@echo "" >> readme.md
	@echo "## RTL" >> readme.md
	@$(foreach file, $(shell find $(SOURCE_DOC_DIR) -name "*.md"), make -s get_source_doc_header FILE=$(file);)
	@echo "" >> readme.md

.PHONY: create_all_docs
create_all_docs:
	@make -s clean_all_docs
	@$(foreach file, $(shell find $(REPO_ROOT)/source/ -type f -name "*.sv"), make -s gen_doc FILE=$(file);)

.PHONY: clean_all_docs
clean_all_docs:
	@mkdir -p $(SOURCE_DOC_DIR)
	@rm -f $(SOURCE_DOC_DIR)/*.md
	@rm -f $(SOURCE_DOC_DIR)/*_top.svg
	@git submodule update --init --depth 1 -- $(DOCUMENTER)

.PHONY: get_source_doc_header
get_source_doc_header:
	@$(eval HEADER := $(shell cat $(FILE) | grep -E "# " | sed "s/^# //g" | sed "s/ .*//g"))
	@echo -n "[\`$(HEADER)" | sed "s/ .*/\`\]\(/g" >> readme.md
	@echo -n "$(FILE)" | sed "s|$(REPO_ROOT)/||g" >> readme.md
	@echo ")" >> readme.md

.PHONY: gen_doc
gen_doc:
	@echo "Creating document for $(FILE)"
	@$(PYTHON) $(DOCUMENTER)/sv_documenter.py $(FILE) $(SOURCE_DOC_DIR)
	@sed -i "s|.*${LINE_1}.*|<br>**${LINE_1}**|g" $(SOURCE_DOC_DIR)/$(shell basename $(FILE) | sed "s/\.sv/\.md/g")
	@sed -i "s|.*${LINE_2}.*|<br>**${LINE_2}**|g" $(SOURCE_DOC_DIR)/$(shell basename $(FILE) | sed "s/\.sv/\.md/g")
	@sed -i "s|.*${LINE_3}.*|<br>**${LINE_3}**|g" $(SOURCE_DOC_DIR)/$(shell basename $(FILE) | sed "s/\.sv/\.md/g")
	@sed -i "s|.*${LINE_4}.*|<br>**${LINE_4}**|g" $(SOURCE_DOC_DIR)/$(shell basename $(FILE) | sed "s/\.sv/\.md/g")
