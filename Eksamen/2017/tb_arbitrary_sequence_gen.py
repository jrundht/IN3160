import cocotb
from cocotb import start_soon
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Edge, First, RisingEdge
from cocotb.triggers import ReadOnly
import random
CLOCK_PERIOD = 10

async def reset(dut):
    dut.rst.value = 1
    dut.run.value = 0
    await ClockCycles(dut.clk, 2)

    dut.rst.value = 0
    dut.run.value = 1

async def stimulate(dut):
    for _ in range(20):
        dut.run.value = random.randint(0,1)
        await ClockCycles(dut.clk, 2)
  
@cocotb.test()
async def main(dut):
    dut._log.info(=====================)
    dut._log.info(    STARTING TEST  )

    start_soon(Clock(dut.clk, CLOCK_PERIOD, units = 'ns').start())
    await reset(dut)
    await stimulate(dut)


    dut._log.info(     ENDING TEST  )
    dut._log.info(=====================)
