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

# Convert bits to state
state_conv = {0b0: 's_reset', 0b1: 's_init', 
              0b10: 's_0', 0b11: 's_1', 
              0b100: 's_2', 0b101: 's_3'}

init_next_state = {0b0 : 's_0', 0b1 : 's_1', 0b11 : 's_2', 0b10 : 's_3'}
s0_next_state = {0b0 : 's_0', 0b1 : 's_1', 0b11 : 's_reset', 0b10 : 's_3'}
s1_next_state = {0b0 : 's_0', 0b1 : 's_1', 0b11 : 's_2', 0b10 : 's_reset'}
s2_next_state = {0b0 : 's_reset', 0b1 : 's_1', 0b11 : 's_2', 0b10 : 's_3'}
s3_next_state = {0b0 : 's_0', 0b1 : 's_reset', 0b11 : 's_2', 0b10 : 's_3'}

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
    dut.sa.value = 0
    dut.sb.value = 0
    await RisingEdge(dut.mclk)
    dut.reset.value = 0
    await RisingEdge(dut.mclk)
    write_log_info(dut, "Resetting complete...")

async def generate_stimuli(dut):
    write_log_info(dut, "Generating stimuli...")

    while True:
        await FallingEdge(dut.mclk)
        dut.sa.value = random.randint(0,1)
        dut.sb.value = random.randint(0,1)
        await RisingEdge(dut.mclk)

# Print present_state
async def states(dut):
    present = None
    while True:
        await RisingEdge(dut.mclk)
        await ReadOnly()
        current = int(dut.present_state.value)
        if current != present:
            present = int(dut.present_state.value)
            write_log_info_error(dut, f"{state_conv[present]}")

async def next_state_check(dut):
    write_log_info(dut, "Checking next_state...")

    while True:
        await RisingEdge(dut.mclk)
        present_state = state_conv[int(dut.present_state.value)]
        ab = (dut.sa.value << 1) + dut.sb.value
        actual_next_state = state_conv[int(dut.next_state.value)]
        
        if present_state == 's_reset':
            expected_next_state = 's_init' if ab == 0 else 's_reset'
            assert expected_next_state == actual_next_state
        
        elif present_state == 's_init':
            expected_next_state = init_next_state[ab]
            assert expected_next_state == actual_next_state, write_log_info_error(dut, 
                    f"{present_state}: ab = {dut.sa.value}{dut.sb.value} expected next_state: {expected_next_state}, actual: {actual_next_state}")
        
        elif present_state == 's_0':
            expected_next_state = s0_next_state[ab]
            assert expected_next_state == actual_next_state, write_log_info_error(dut, 
                    f"{present_state}: ab = {dut.sa.value}{dut.sb.value} expected next_state: {expected_next_state}, actual: {actual_next_state}")
        
        elif present_state == 's_1':
            expected_next_state = s1_next_state[ab]
            assert expected_next_state == actual_next_state, write_log_info_error(dut, 
                    f"{present_state}: ab = {dut.sa.value}{dut.sb.value} expected next_state: {expected_next_state}, actual: {actual_next_state}")
         
        elif present_state == 's_2':
            expected_next_state = s2_next_state[ab]
            assert expected_next_state == actual_next_state, write_log_info_error(dut, 
                    f"{present_state}: ab = {dut.sa.value}{dut.sb.value} expected next_state: {expected_next_state}, actual: {actual_next_state}")
         
        elif present_state == 's_3':
            expected_next_state = s3_next_state[ab]
            assert expected_next_state == actual_next_state, write_log_info_error(dut, 
                    f"{present_state}: ab = {dut.sa.value}{dut.sb.value} expected next_state: {expected_next_state}, actual: {actual_next_state}")
        await FallingEdge(dut.mclk)
        
async def inc_check(dut):
    write_log_info(dut, "pos_inc only asserted for one cycle...?")

    while True:
        await RisingEdge(dut.pos_inc)
        await ReadOnly()
        start = get_sim_time('ns')

        await FallingEdge(dut.pos_inc)
        await ReadOnly()
        end = get_sim_time('ns')

        length = (end - start)/CLOCK_PERIOD_NS
        assert length == 1, write_log_info_error(dut, f'pos_inc signal should be one clock-cycle long, but was: {length}')

async def dec_check(dut):
    write_log_info(dut, "pos_dec only asserted for one cycle...?")

    while True:
        await RisingEdge(dut.pos_dec)
        await ReadOnly()
        start = get_sim_time('ns')

        await FallingEdge(dut.pos_dec)
        await ReadOnly()
        end = get_sim_time('ns')

        length = (end - start)/CLOCK_PERIOD_NS
        assert length == 1, write_log_info_error(dut, f'pos_dec signal should be one clock-cycle long, but was: {length}')

@cocotb.test()
async def main_test(dut):
    write_log_info(dut, "Starting testing...")
    start_soon(Clock(dut.mclk, 10, units="ns").start())
    
    await reset_dut(dut)
    
    start_soon(generate_stimuli(dut))
    start_soon(next_state_check(dut))
    start_soon(inc_check(dut))
    start_soon(dec_check(dut))

    await Timer(1500, units='ns')
    write_log_info(dut,f"Testing done of {os.path.basename(__file__)}...")