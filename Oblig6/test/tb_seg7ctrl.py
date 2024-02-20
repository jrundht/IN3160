import cocotb
from cocotb import start_soon
from cocotb.clock import Clock
from cocotb.triggers import Edge, FallingEdge, RisingEdge, Timer, ReadOnly

bin2ssd = {
    0b0000: 0b1111110,
    0b0001: 0b0110000,
    0b0010: 0b1101101,
    0b0011: 0b1111001,
    0b0100: 0b0110011,
    0b0101: 0b1011011,
    0b0110: 0b1011111,
    0b0111: 0b1110000,
    0b1000: 0b1111111,
    0b1001: 0b1111011,
    0b1010: 0b1110111,
    0b1011: 0b0011111,
    0b1100: 0b1001110,
    0b1101: 0b0111101,
    0b1110: 0b1001111,
    0b1111: 0b1000111
}
bin2ssd_v2 = {
    0b0000: 0b0000000,
    0b0001: 0b0011110,
    0b0010: 0b0111100,
    0b0011: 0b1001111,
    0b0100: 0b0001110,
    0b0101: 0b0111101,
    0b0110: 0b0011101,
    0b0111: 0b0010101,
    0b1000: 0b0111011,
    0b1001: 0b0111110,
    0b1010: 0b1110111,
    0b1011: 0b0000101,
    0b1100: 0b1111011,
    0b1101: 0b0011100,
    0b1110: 0b0001101,
    0b1111: 0b1111111
}

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


async def stimuli_generator(dut):
    # Cycling through all possible values.
    for val in range(2**4):
        await Timer(20, units = "ns")
        dut.d0.value = val              # COUNT UP
        dut.d1.value = (2**4 - 1) - val # COUNT DOWN

async def compare(dut):
    write_log_info(dut, "Starting compare...")
    while True:
        # await Edge(dut.C)
        await Timer(20, units = "ns")
        await ReadOnly()
        expected = bin2ssd_v2[int(dut.d0.value)] if dut.c.value == 0 else bin2ssd_v2[int(dut.d1.value)]
        val = dut.d0.value if dut.c.value == 0 else dut.d1.value
        assert int(dut.abcdefg.value) == expected, \
            write_log_info(dut, f"Fail: Actual value of 'abcdefg = {bin(dut.abcdefg.value)}' is not matching the expected value of: '{bin(expected)}'")

        write_log_info(dut, f"Pass with input = {val}. Output Actual: {bin(dut.abcdefg.value)}, expected: {bin(expected)}")


@cocotb.test()
async def main_test(dut):
    write_log_info(dut, "Starting testing...")
    start_soon(Clock(dut.mclk, 10, units="ns").start())
    await reset_dut(dut)
    cocotb.start_soon(compare(dut))
    await cocotb.start_soon(stimuli_generator(dut))
    write_log_info(dut,"Testing done. All tests passed...")