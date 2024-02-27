# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

# VHDL 2008
EXTRA_ARGS +=--std=08

# TOPLEVEL is the name of the toplevel module in your VHDL file
VHDL_SOURCES += $(PWD)/../src/*.vhd

# TASK c
# TOPLEVEL = bin2ssd_test
# TOPLEVEL = seg7ctrl_ent
# TOPLEVEL = self_test
TOPLEVEL = self_test_system
# VHDL_SOURCES += $(PWD)/../src/ROM.vhd
# VHDL_SOURCES += $(PWD)/../src/seg7_pkg.vhd
# VHDL_SOURCES += $(PWD)/../src/seg7ctrl_ent.vhd
# VHDL_SOURCES += $(PWD)/../src/seg7ctrl_c_arch.vhd
# VHDL_SOURCES += $(PWD)/../src/seg7ctrl_b_arch.vhd
# VHDL_SOURCES += $(PWD)/../src/self_test.vhd
# VHDL_SOURCES += $(PWD)/../src/$(TOPLEVEL).vhd


SIM_ARGS +=--wave=$(TOPLEVEL).ghw 

# MODULE is the basename of the Python test file
MODULE = tb_$(TOPLEVEL)

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

# removing generated binary of top entity and .o-file on make clean
clean::
	-@rm -f $(TOPLEVEL)
	-@rm -f e~$(TOPLEVEL).o