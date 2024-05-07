import cocotb
from cocotb import start_soon
from cocotb.clock import Clock
from cocotb.handle import Force, Freeze, Release
from cocotb.triggers import ClockCycles, Edge, First, FallingEdge, RisingEdge
from cocotb.triggers import ReadOnly, ReadWrite, Timer, with_timeout  
from cocotb.utils import get_sim_time


sdata_values = [0xAA, 0x0F, 0xF2, 0xFF, 0x02, 0x03]

tdata  = 0x00

async def reset_dut(dut):
    dut.rstn.value = 0
    dut.sdata.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rstn.value = 1

    
async def generate_simuli(dut):
    global tdata
    for byte in sdata_values:
        for i in range(8):
            bit = (byte >> (7 - i)) & 1
            dut.sdata.value = bit
            await ClockCycles(dut.clk, 1)
            tdata = (tdata << 1) | bit # should be same as the dut.data
            tdata &= 0xFF # Make sure only 8 LSB is present

async def check_output(dut):
    while True:
        await First(Edge(dut.tvalid), Edge(dut.tdata))
        await ReadOnly()
        if dut.tvalid == 1:
            assert tdata == int(dut.tdata.value), \
                dut._log.info(f"Sent byte: {tdata}, not corresponding to: {int(dut.tdata.value)} when tvalid")
            dut._log.info(f"Sent byte: {tdata}, corresponding to: {int(dut.tdata.value)} when tvalid")
        else:
            assert dut.tdata.value == 0, dut._log.info(f"tdata: {dut.tdata.value} should have been 0")
        



@cocotb.test()
async def main(dut):

    start_soon(Clock(dut.clk, 10, units='ns').start())
    await(reset_dut(dut))
    start_soon(check_output(dut))
    await start_soon(generate_simuli(dut))

