import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def main_test(dut):
    
    """Try accessing the design."""
    dut._log.info("Running test decoder...")

    # Running for 40ns
    await Timer(40, units="ns")
    
    dut._log.info("Setting a = 0b00")
    dut.a.value = 0b00
    await Timer(40, units="ns")

    dut._log.info("Setting a = 0b01")
    dut.a.value = 0b01
    await Timer(40, units="ns")

    dut._log.info("Setting a = 0b10")
    dut.a.value = 0b10
    await Timer(40, units="ns")

    dut._log.info("Setting a = 0b11")
    dut.a.value = 0b11
    await Timer(100, units='ns')

    dut._log.info("Running test...done")

#Oblig2
	#src
                #decoder_ent.vhd
                #decoder_case.vhd
                #decoder_select.vhd
	#test
                #makefile
                #tb_decoder_case.py
                #tb_decoder_select.py
