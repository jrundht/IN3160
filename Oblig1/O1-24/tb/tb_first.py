# test_first.py
#
# Simple test of first.vhdl
#
#

import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def main_test(dut):
    
    """Try accessing the design."""

    dut._log.info("Running test...")
    
    # Resetting unit
    dut.reset.value = 1
    
    # Starting clock, at 50MHz
    dut._log.info("Starting clock")
    cocotb.start_soon(Clock(dut.clk, 20, units="ns").start())
    
    # Running for 40ns
    await Timer(40, units="ns")

    # Setting inputs to zero, then wait for 10ns
    dut.inp.value = 0
    dut.load.value = 0
    await Timer(10, units="ns")

    # Clear reset, ...
    dut._log.info("Clearing reset")
    dut.reset.value = 0
    await Timer(20, units="ns")
    
    #Set input value
    dut.inp.value = 0b1010
    dut.load.value = 1
    
    #Wait for clock edge to rise
    await RisingEdge(dut.clk)   

    #Turn off load to let counting resume
    dut.load.value = 0

    await Timer(150, units='ns')
    dut._log.info("Running test...done")

