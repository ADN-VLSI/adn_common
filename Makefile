ROOT = $(CURDIR)

BUILD_DIR = $(ROOT)/build

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)
	@echo "*" > $(BUILD_DIR)/.gitignore

.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)

.PHONY: all
all:
	@make -s $(BUILD_DIR)
	@cd $(BUILD_DIR) && xvlog -sv -i $(ROOT)/include $(ROOT)/testbench/hello.sv
	@cd $(BUILD_DIR) && xelab -debug all hello
	@cd $(BUILD_DIR) && xsim hello -R
