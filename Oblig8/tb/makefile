# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

# VHDL 2008
EXTRA_ARGS +=--std=08

# TOPLEVEL is the name of the toplevel module in your VHDL file
# TOPLEVEL = pulse_width_modulator
# TOPLEVEL = self_test_module
TOPLEVEL = system
# TOPLEVEL = quad_test
# TOPLEVEL = velocity_reader

# VHDL_SOURCES += $(PWD)/../src/$(TOPLEVEL).vhd
VHDL_SOURCES += $(PWD)/../src/*.vhd*
# VHDL_SOURCES += $(PWD)/../src/pulse_width_modulator_arch.vhd

SIM_ARGS +=--wave=$(TOPLEVEL).ghw

# MODULE is the basename of the Python test file
MODULE = tb_$(TOPLEVEL)
# MODULE = tb_pwm


# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

# removing generated binary of top entity and .o-file on make clean
clean::
	-@rm -f $(TOPLEVEL)
	-@rm -f e~$(TOPLEVEL).o