import os
import random
import cocotb
from cocotb import start_soon
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ReadOnly
from cocotb.utils import get_sim_time 
CLOCK_PERIOD_NS = 10

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

async def max_on_check(dut): 
    write_log_info(dut, "Starting max_on_check...")
    while True: 
        await RisingEdge(dut.pdm_pulse) 
        start = get_sim_time('ns') 
        await FallingEdge(dut.pdm_pulse) 
        end = get_sim_time('ns') 
        duration = end-start 
        cycles = duration/CLOCK_PERIOD_NS 
        assert cycles <= int(dut.max_on.value)+1, ( 
            write_log_info_error(dut,f"Pulse of {cycles} cycles greater than max_on: {int(dut.max_on.value)}"))
        
async def min_off_check(dut):
    write_log_info(dut, "Starting min_on_check...")
    while True:
        await FallingEdge(dut.pdm_pulse) 
        start = get_sim_time('ns')
        await RisingEdge(dut.pdm_pulse)
        end = get_sim_time('ns')
        duration = end-start
        cycles = duration/CLOCK_PERIOD_NS
        assert cycles > int(dut.min_off.value), ( 
                write_log_info_error(dut,f"Pulse off for {cycles} cycles, which is greater than min_off: {int(dut.min_off.value)}"))
    
async def mea_ack_not_asserted(dut):
    write_log_info(dut, "Starting mea_ack_not_asserted...")

    # mea_ack is never asserted while pulse is high
    while True:
        await RisingEdge(dut.pdm_pulse)
        
        assert int(dut.mea_ack.value) == 0, (
            write_log_info_error(dut, f"mea_ack is asserted while  pdm_pulse = {dut.pdm_pulse.value} is"))
        
        await FallingEdge(dut.pdm_pulse)
        
async def mea_ack_asserted(dut): 
    write_log_info(dut, "Starting mea_ack_asserted...")

    # mea_ack asserted wihtin 2 cycles of mea_req
    while True:
        await RisingEdge(dut.mea_req)
        start = get_sim_time('ns') 
        await RisingEdge(dut.mea_ack) 
        end = get_sim_time('ns') 
        duration = end-start
        cycles = duration/CLOCK_PERIOD_NS
        assert cycles <= 2, (
            write_log_info_error(dut, f"mea_ack was asserted {cycles} cycles after mea_req"))

async def mea_ack_deasserted(dut):
    write_log_info(dut, "Starting mea_ack_deasserted...")

    # mea_ack deasserted wihtin 2 cycles of mea_req deasserted
    while True:
        await FallingEdge(dut.mea_req)
        start = get_sim_time('ns') 
        await FallingEdge(dut.mea_ack) 
        end = get_sim_time('ns') 
        duration = end-start
        cycles = duration/CLOCK_PERIOD_NS
        assert cycles <= 2, (
            write_log_info_error(dut, f"mea_ack was deasserted {cycles} cycles after mea_req"))

async def duty_cycle_check(dut):
    write_log_info(dut, "Starting duty_cycle_check...")

    #duty cycle within 10% of max_on
    while True:
        await FallingEdge(dut.pdm_pulse) 
        await ReadOnly()
        start = get_sim_time('ns') 
        await RisingEdge(dut.pdm_pulse)
        await ReadOnly()
        on_pulse = get_sim_time('ns') 
        await FallingEdge(dut.pdm_pulse) 
        await ReadOnly()
        end = get_sim_time('ns') 
        total_time = end-start/CLOCK_PERIOD_NS
        on_time = (end-on_pulse)/CLOCK_PERIOD_NS

        duty_cycle_measured = on_time/total_time

        lower_bound = dut.setpoint.value * 0.9  # 90% of setpoint
        upper_bound = dut.setpoint.value * 1.1  # 110% of setpoint

        assert (lower_bound <= duty_cycle_measured <= upper_bound), (
            write_log_info_error(dut, f"duty cycle: {duty_cycle_measured} is not within 10% of setpoint: {int(dut.setpoint.value)}"))

def set_initial_values(dut):
    dut.setpoint.value = 4
    # dut.mea_req.value = 0
    dut.min_on.value = 5
    dut.min_off.value = 10
    dut.max_on = 200

async def reset_dut(dut):
    write_log_info(dut, "Resetting...")
    await FallingEdge(dut.clk)
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    dut.reset.value = 0
    await RisingEdge(dut.clk)
    write_log_info(dut, "Resetting complete...")

async def stimulate_mea_req(dut):
    write_log_info(dut, "Starting stimulate_mea_req...")
    for _ in range(5):
        await Timer(random.randint(10, 50), units = 'ns') # Pick a random time
        await FallingEdge(dut.clk)
        dut.mea_req.value = 1
        await RisingEdge(dut.clk)

        await RisingEdge(dut.mea_ack) 

        await Timer(5*CLOCK_PERIOD_NS, units='ns')
        dut.mea_req.value = 0

        await Timer(400*CLOCK_PERIOD_NS, units = 'ns')

async def stimulate_setpoint(dut):
    write_log_info(dut, "Starting stimulate_setpoint...")
    """
    The testbench 
    should check at least 50 random setpoints, and at least 10 of these should be tested for 3 
    periods or more. 
    """
    width = len(dut.setpoint.value)
    max_setpoint_value = 2**width-1
    for i in range(50):
        dut.setpoint.value = random.randint(0, max_setpoint_value)

        if i < 10:
            await Timer(3*CLOCK_PERIOD_NS, units='ns')
        else:
            await Timer(CLOCK_PERIOD_NS, units='ns')        

@cocotb.test()
async def main_test(dut):
    write_log_info(dut, "Starting testing...")
    set_initial_values(dut)
    start_soon(Clock(dut.clk, 10, units="ns").start())
    await reset_dut(dut)

    cocotb.start_soon(max_on_check(dut))
    cocotb.start_soon(min_off_check(dut))
    cocotb.start_soon(mea_ack_not_asserted(dut))
    cocotb.start_soon(mea_ack_asserted(dut))
    cocotb.start_soon(mea_ack_deasserted(dut))
    cocotb.start_soon(duty_cycle_check(dut))

    await cocotb.start_soon(stimulate_mea_req(dut))
    await cocotb.start_soon(stimulate_setpoint(dut))

    write_log_info(dut,f"Testing done of testbench: {os.path.basename(__file__)}...")