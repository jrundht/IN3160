# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

# VHDL 2008
EXTRA_ARGS +=--std=08

# TOPLEVEL is the name of the toplevel module in your VHDL file
# TOPLEVEL = bin2ssd_test
TOPLEVEL = seg7ctrl_ent
NEXTLEVEL = seg7ctrl

VHDL_SOURCES += $(PWD)/../src/$(TOPLEVEL).vhd
VHDL_SOURCES += $(PWD)/../src/$(NEXTLEVEL)_c_arch.vhd
# VHDL_SOURCES += $(PWD)/../src/bin2ssd_test.vhd

SIM_ARGS +=--wave=$(TOPLEVEL).ghw 

# MODULE is the basename of the Python test file
MODULE = tb_$(NEXTLEVEL)

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

# removing generated binary of top entity and .o-file on make clean
clean::
	-@rm -f $(TOPLEVEL)
	-@rm -f e~$(TOPLEVEL).o
