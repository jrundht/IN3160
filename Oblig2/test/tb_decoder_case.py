import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def main_test(dut):
    
    """Try accessing the design."""
    dut._log.info("Running test...")
    
    # Starting clock, at 50MHz
    dut._log.info("Starting clock")
    cocotb.start_soon(Clock(dut.clk, 20, units="ns").start())
    
    # Running for 40ns
    await Timer(40, units="ns")

    dut.a.value = 0b00
    
    await Timer(40, units="ns")

    dut.a.value = 0b01
    await Timer(40, units="ns")

    dut.a.value = 0b10
    await Timer(40, units="ns")

    dut.a.value = 0b11

    await Timer(100, units='ns')
    dut._log.info("Running test...done")