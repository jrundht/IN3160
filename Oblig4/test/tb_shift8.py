import cocotb
from cocotb.triggers import *
from cocotb.clock import Clock

@cocotb.test()
async def main_test(dut):
    # Green color to make text stand out in terminal
    color_start = "\033[32m" 
    color_end = "\033[0m"

    dut._log.info(f"{color_start}Test for 8-bit shift register...{color_end}\n")

    # Reset is active low
    dut.reset.value = 1

    # Initial serial_in
    dut.serial_in.value = 1

    dut._log.info(f"{color_start}Starting clock...{color_end}\n")
    cocotb.start_soon(Clock(dut.clk, 100, units="ns").start())

    #dut._log.info(f"{color_start}Resetting signal...{color_end}\n")
    await Timer(100, units="ns")
    dut.serial_in.value = 0
    
    # Reset
    await Timer(800, units="ns")
    dut.reset.value = 0
    
    await Timer(100, units="ns")
    dut.reset.value = 1
    dut.serial_in.value = 1

    await Timer(100, units="ns")
    dut.serial_in.value = 0
    
    await Timer(800, units="ns")

    dut._log.info(f"{color_start}Test done...{color_end}")

