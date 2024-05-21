import cocotb
from cocotb import start_soon
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Edge, First, FallingEdge, RisingEdge
from cocotb.utils import get_sim_time 
from cocotb.triggers import ReadOnly, ReadWrite
import random

x_data = [0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0]
CLOCK_PERIOD = 10
@cocotb.test()
async def main(dut):
    dut._log.info("STARTING TEST...")

    start_soon(Clock(dut.clk, CLOCK_PERIOD, units='ns').start())
    await reset(dut)
    start_soon(check_deassert(dut))
    start_soon(check_assert(dut))
    await(generate_stimuli(dut))
    dut._log.info("TEST ENDED...")



async def reset(dut):
    dut._log.info("RESETTING...")

    dut.reset.value = 1
    dut.x.value = 0
    await ClockCycles(dut.clk, 2)
    dut.reset.value = 0

async def generate_stimuli(dut):
    dut._log.info("GENERATING STIMULI...")

    for val in x_data:
        dut.x.value = val
        await ClockCycles(dut.clk, 1)

async def check_assert(dut):
    dut._log.info("CHECKING ASSERTION...")
    while True:
        await RisingEdge(dut.x)
        await ReadOnly()
        start_x = get_sim_time('ns')

        await RisingEdge(dut.z)
        await ReadOnly()
        start_z = get_sim_time('ns')

        assertion = (start_z-start_x)/CLOCK_PERIOD
        assert assertion == 1, dut._log.info("z should be asserted 1 cycle after x is asserted")

async def check_deassert(dut):
    dut._log.info("CHECKING DEASSERTION...")

    # X kan settes høy før det har gått 2 sykler, må da ta høyde for det
    #z skal settes lav 2 sykler etter x settes lav, med mindre x blir høy igjen
    while True:
        await FallingEdge(dut.x)
        await ReadOnly()
        end_x = get_sim_time('ns')
        
        await FallingEdge(dut.z)
        end_z = get_sim_time('ns')
        stretch = (end_z-end_x)/CLOCK_PERIOD
        dut._log.info(f"end_x = {end_x/CLOCK_PERIOD}")
        dut._log.info(f"end_z = {end_z/CLOCK_PERIOD}")

        assert stretch == int(dut.N.value), dut._log.info("z should only be high for 2 cycles after x is low")

