import cocotb
from cocotb import start_soon
from cocotb.clock import Clock
from cocotb.triggers import Edge, FallingEdge, RisingEdge, Timer, ReadOnly

rom_values = [
        0b00010010, # 1 2
        0b00110100, # 3 4
        0b01000000, # 4 0
        0b00000000, # 0 0
        0b01010110, # 5 6
        0b01110011, # 7 3
        0b00000000, # 0 0
        0b10000110, # 8 6
        0b10010000, # 9 0
        0b00000000, # 0 0
        0b10101011, # A B
        0b00110000, # 3 0
        0b00000000, # 0 0
        0b11000110, # C 6
        0b01100101, # 6 5
        0b00000000  # 0 0
]
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

async def compare(dut):
    write_log_info(dut, "Starting compare...")
    address = dut.adr.value
    while True:
        await ReadOnly()
        if dut.adr.value != address:
            address = dut.adr.value
            value = rom_values[address]
            exp_d1 = (value & 0b11110000) >> 4 
            exp_d0 = value & 0b00001111
            assert int(dut.d0_seg7.value) == int(exp_d0),write_log_info(dut,f"d0 failed: expected {exp_d0}, got {dut.d0_seg7.value}")
            
            assert int(dut.d1_seg7.value) == int(exp_d1),write_log_info(dut,f"d1 failed:  expected {exp_d1}, got {dut.d1_seg7.value}")

@cocotb.test()
async def main_test(dut):
    write_log_info(dut, "Starting testing...")
    start_soon(Clock(dut.mclk, 10, units="ns").start())
    await reset_dut(dut)
    cocotb.start_soon(compare(dut))
    await Timer(1000, units='ns')
    write_log_info(dut,"Testing done. All tests passed...")