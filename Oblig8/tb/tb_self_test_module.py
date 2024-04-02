import os
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Edge, FallingEdge, RisingEdge, Timer, ReadOnly


def write_log_info(dut, string):
    # Green color to make text stand out in terminal
    color_start = "\033[32m" 
    color_end = "\033[0m"
    dut._log.info(f"{color_start}{ string }{color_end}")

async def reset_dut(dut):
    write_log_info(dut, "Resetting...")
    await FallingEdge(dut.mclk)
    dut.reset.value = 1
    await RisingEdge(dut.mclk)
    dut.reset.value = 0
    write_log_info(dut, "Resetting complete...")

@cocotb.test()
async def main_test(dut):
    write_log_info(dut, "Starting testing...")
    cocotb.start_soon(Clock(dut.mclk, 10, units="ns").start())
    await reset_dut(dut)
    await Timer(1500, units='ns')
    write_log_info(dut,f"Testing done of {os.path.basename(__file__)}...")