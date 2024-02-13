# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

# VHDL 2008
EXTRA_ARGS +=--std=08

# TOPLEVEL ?= shift8
# TOPLEVEL ?= shift32
TOPLEVEL ?= shiftn
SIM_ARGS +=-gWIDTH=64

VHDL_SOURCES += $(PWD)/../src/dff.vhd
VHDL_SOURCES += $(PWD)/../src/shift8.vhd
# VHDL_SOURCES += $(PWD)/../src/$(TOPLEVEL).vhd

# Generic shifter
# VHDL_SOURCES += $(PWD)/../src/shiftn.vhd

SIM_ARGS +=--wave=$(TOPLEVEL).ghw

# MODULE is the basename of the Python test file
MODULE = tb_$(TOPLEVEL)

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

# removing generated binary of top entity and .o-file on make clean
clean::
	-@rm -f $(TOPLEVEL)
	-@rm -f e~$(TOPLEVEL).o
