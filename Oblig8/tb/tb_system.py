import os
import numpy as np
import random
import cocotb
from cocotb import start_soon
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ReadOnly
from cocotb.utils import get_sim_time 
CLOCK_PERIOD_NS = 10


# Conversion to pico-seconds made easy
ps_conv = {'fs': 0.001, 'ps': 1, 'ns': 1000, 'us': 1e6, 'ms':1e9}

def write_log_info(dut, string):
    # Green color to make text stand out in terminal
    color_start = "\033[32m" 
    color_end = "\033[0m"
    dut._log.info(f"{color_start}{ string }{color_end}")

def write_log_info_error(dut, string):
    # Red color to make text stand out in terminal
    color_start = "\033[31m" 
    color_end = "\033[0m"
    dut._log.info(f"    {color_start}{ string }{color_end}")

async def reset_dut(dut):
    write_log_info(dut, "Resetting...")
    await FallingEdge(dut.mclk)
    dut.reset.value = 1
    await RisingEdge(dut.mclk)
    dut.reset.value = 0
    await RisingEdge(dut.mclk)
    write_log_info(dut, "Resetting complete...")

async def check_synch_en(dut):
    # Check that en_synch is high exactly one clock cycle after en 
    while True:
        await RisingEdge(dut.sys_en)
        await ReadOnly()
        start_en = get_sim_time('ns')

        await RisingEdge(dut.sys_en_synch)
        await ReadOnly()
        start_en_synch = get_sim_time('ns')

        delay = (start_en_synch - start_en)/CLOCK_PERIOD_NS

        assert delay == 1, write_log_info_error(dut, f"The output synch for en should be 1 clock cycle, measured delay: {delay}")

async def check_synch_dir(dut):
    # Check that dir_synch is high exactly one clock cycle after dir 
    while True:
        await RisingEdge(dut.sys_dir)
        await ReadOnly()
        start_dir = get_sim_time('ns')

        await RisingEdge(dut.sys_dir_synch)
        await ReadOnly()
        start_dir_synch = get_sim_time('ns')

        delay = (start_dir_synch - start_dir)/CLOCK_PERIOD_NS

        assert delay == 1, write_log_info_error(dut, f"The output synch for dir should be 1 clock cycle, measured delay: {delay}")

async def generate_stimuli(dut):
    write_log_info(dut, "Generating stimuli...")

    while True:
        await FallingEdge(dut.mclk)
        dut.sa.value = random.randint(0,1)
        dut.sb.value = random.randint(0,1)
        await RisingEdge(dut.mclk)

@cocotb.test()
async def main_test(dut):
    write_log_info(dut, "Starting testing...")
    start_soon(Clock(dut.mclk, 10, units="ns").start())
    await reset_dut(dut)

    start_soon(check_synch_en(dut))
    start_soon(check_synch_dir(dut))
    start_soon(generate_stimuli(dut))

    await Timer(1500, units = 'ns')
    write_log_info(dut,f"Testing done of testbench: {os.path.basename(__file__)}...")