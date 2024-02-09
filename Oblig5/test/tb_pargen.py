import cocotb
from cocotb import start_soon
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly

# Skeleton for task d starting here:
async def reset_dut(dut):
    await FallingEdge(dut.mclk)
    dut.rst_n.value = 0
    dut.indata1.value = 0
    dut.indata2.value = 0
    await RisingEdge(dut.mclk)
    dut.rst_n.value = 1

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
   

async def stimuli_generator(dut):
    indata1_pattern = [0x0001, 0x0003, 0x000F, 0x0005, 0x0004]
    indata2_pattern = [0x0005, 0x0001, 0x0003, 0x0007, 0x000F]

    for i in range(len(indata1_pattern)):
        await FallingEdge(dut.mclk)
        dut.indata1.value = indata1_pattern[i]
        dut.indata2.value = indata2_pattern[i]
        await RisingEdge(dut.mclk)
    # Awaiting one last rising_edge(mclk) without changes
    await RisingEdge(dut.mclk)


async def compare(dut):
    # Your code here.
    pass


@cocotb.test()
async def main_test(dut):
    dut._log.info("Running test...")
    start_soon(Clock(dut.mclk, 100, units="ns").start())
    await reset_dut(dut)
    cocotb.start_soon(compare(dut))
    await start_soon(stimuli_generator(dut))
    dut._log.info("Running test... done")
