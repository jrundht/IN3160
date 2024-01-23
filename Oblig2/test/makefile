# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

# VHDL 2008
EXTRA_ARGS +=--std=08

# TOPLEVEL is the name of the toplevel module in your VHDL file
TOPLEVEL ?= decoder

ARCH ?= case

VHDL_SOURCES += $(PWD)/../src/$(TOPLEVEL)_ent.vhd
VHDL_SOURCES += $(PWD)/../src/$(TOPLEVEL)_$(ARCH).vhd

#VHDL_SOURCES += /uio/hume/student-u26/jorundht/IN3160/Oblig2/src/decoder_ent.vhd
#VHDL_SOURCES += /uio/hume/student-u26/jorundht/IN3160/Oblig2/src/decoder_case.vhd

SIM_ARGS +=--wave=$(TOPLEVEL).ghw

# MODULE is the basename of the Python test file
MODULE = tb_$(TOPLEVEL)_$(ARCH)

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

# removing generated binary of top entity and .o-file on make clean
clean::
	-@rm -f $(TOPLEVEL)
	-@rm -f e~$(TOPLEVEL).o
