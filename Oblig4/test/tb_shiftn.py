import cocotb
from cocotb.triggers import *
from cocotb.clock import Clock

@cocotb.test()
async def main_test(dut):
    # Green color to make text stand out in terminal
    color_start = "\033[32m" 
    color_end = "\033[0m"

    dut._log.info(f"{color_start}Test for {int(dut.width.value)}-bit shift register...{color_end}\n")

    # Reset is active low

    dut.reset.value = 1

    # Initial serial_in

    dut.serial_in.value = 1
    dut._log.info(f"{color_start}Starting clock...{color_end}\n")
    # cocotb.start_soon(Clock(dut.clk, 100, units="ns").start())
    cocotb.start_soon(Clock(dut.clk, 100, units="ns").start())

    await Timer(100, units="ns")
    dut._log.info(f"{color_start}Resetting signals...{color_end}\n")
    dut.reset.value = 0
    dut.serial_in.value = 0

    await Timer(100, units="ns")
    dut.reset.value = 1
    dut.serial_in.value = 1

    await Timer(100, units="ns")
    dut.serial_in.value = 0

    await Timer(800, units="ns")

    dut._log.info(f"{color_start}{int(dut.width.value)}-bit shift register test done...{color_end}")

