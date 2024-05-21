import cocotb
from cocotb import start_soon
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Edge, First, RisingEdge
from cocotb.triggers import ReadOnly

values = [0xAAAA, 0xBBBB, 0xCCCC, 0xDDDD]

async def stimulate(dut):
    dut._log.info(f"STIMULATE...")

    for i in range(4*20):
        await ClockCycles(dut.clk, 1)
        dut.a.value = values[(i)%4]
        dut.b.value = values[(i+1)%4]
        dut.c.value = values[(i+2)%4]
        dut.d.value = values[(i+3)%4]
        dut._log.info(f"Result: {dut.result.value}")

async def reset(dut):
    dut._log.info(f"RESET...")

    await ClockCycles(dut.clk, 2)
    dut.a.value = 0
    dut.b.value = 0
    dut.c.value = 0
    dut.d.value = 0
    dut.reset.value = 1
    await ClockCycles(dut.clk, 1)
    dut.reset.value = 0

@cocotb.test()
async def main(dut):
    dut._log.info(f"START...")
    
    start_soon(Clock(dut.clk, 10, units='ns').start())
    await reset(dut)
    await stimulate(dut)
    dut._log.info(f"END...")
