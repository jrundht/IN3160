import cocotb
import random
from cocotb import start_soon
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly, Timer

# Skeleton for task d starting here:
async def reset_dut(dut):
    await FallingEdge(dut.mclk)
    dut.rst_n.value = 0
    dut.indata1.value = 0
    dut.indata2.value = 0
    await RisingEdge(dut.mclk)
    dut.rst_n.value = 1

def write_log_info(dut, string):
    # Green color to make text stand out in terminal
    color_start = "\033[32m" 
    color_end = "\033[0m"
    dut._log.info(f"{color_start}{ string }{color_end}\n")

def parity(value):
    """ Function to calculate what the parity of value is.
    arguments:
      value(cocotb.binary.BinaryValue): Value to calculate parity from (dut.indata*.value).
    return:
      result(int): Parity of value (1 or 0).
    """
    result = 0
    for i in range(value.n_bits):
        result = result ^ (value & 1)
        value = value >> 1
    return result

def predict(dut):
    pred_parity_indata1 = parity(dut.indata1.value)
    pred_parity_indata2 = parity(dut.indata2.value)

    # ^ is bitwise XOR in python
    pred_par =  pred_parity_indata1 ^ pred_parity_indata2 
    return pred_par
   

def generate_random(n, a, b):
    return [random.randint(a, b) for _ in range(n)]

async def stimuli_generator(dut):
    a = 0
    b = 100
    indata1_pattern = generate_random(20, 0, 100)

    for i in range(len(indata1_pattern)):
        await FallingEdge(dut.mclk)
        dut.indata1.value = indata1_pattern[i]
        dut.indata2.value = i
        await RisingEdge(dut.mclk)
    # Awaiting one last rising_edge(mclk) without changes
    await RisingEdge(dut.mclk)


async def compare(dut):
    write_log_info(dut, "\nCompare...........................")
    # write_log_info(dut, f"toggle = {dut.toggle_parity.value}")
    # write_log_info(dut, f"xor = {dut.xor_parity.value}")
    # write_log_info(dut, f"parity of indata1 = {parity(dut.indata1.value)}")
    
    while True:
        await RisingEdge(dut.mclk)
        await ReadOnly()
        assert dut.xor_parity.value == parity(dut.indata2.value), "xor_parity.value"
        assert dut.toggle_parity.value == parity(dut.indata1.value), "toggle_parity.value"

        assert dut.par.value == predict(dut), f"par = {dut.par.value}"

@cocotb.test()
async def main_test(dut):
    write_log_info(dut, "Running test...")
    start_soon(Clock(dut.mclk, 100, units="ns").start())
    await reset_dut(dut)
    cocotb.start_soon(compare(dut))
    await start_soon(stimuli_generator(dut))
    write_log_info(dut, "Running test... done")
