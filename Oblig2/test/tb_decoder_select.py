import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def main_test(dut):
    
    """Try accessing the design."""
    dut._log.info("Running test decoder...")

    # Running for 40ns
    await Timer(40, units="ns")
    
    dut._log.info("Setting a = 0b00")
    dut.a.value = 0b00
    await Timer(40, units="ns")
    assert dut.b.value == 0b1110, "a = ̈́'00' does not set b = '1110'"

    dut._log.info("Setting a = 0b01")
    dut.a.value = 0b01
    await Timer(40, units="ns")
    assert dut.b.value == 0b1101, "a = ̈́'01' does not set b = '1101'"

    dut._log.info("Setting a = 0b10")
    dut.a.value = 0b10
    await Timer(40, units="ns")
    assert dut.b.value == 0b1011, "a = ̈́'10' does not set b = '1011'"
    
    dut._log.info("Setting a = 0b11")
    dut.a.value = 0b11
    await Timer(100, units='ns')
    assert dut.b.value == 0b0001, "a = ̈́'11' does not set b = '0001'"
    

    dut._log.info("Running test...done")