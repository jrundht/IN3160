# tb_pwm.py V4 : Testbench for PWM module with fault injection. 
# By Yngve Hafting 04-11 2022 

import cocotb
from cocotb import start_soon
from cocotb.clock import Clock
from cocotb.handle import Force, Freeze, Release
from cocotb.triggers import ClockCycles, Edge, First, FallingEdge, RisingEdge
from cocotb.triggers import ReadOnly, ReadWrite, Timer, with_timeout  
from cocotb.utils import get_sim_time

import random
import numpy as np

# Conversion to pico-seconds made easy
ps_conv = {'fs': 0.001, 'ps': 1, 'ns': 1000, 'us': 1e6, 'ms':1e9}

#design constants
PERIOD_NS = 10
PWM_TIMEOUT_MS = 12
TOO_FAST_PWM_US= 160


class SignalEventMonitor():
    """ Tracks a signals last event.  """
    def __init__(self, signal):
        self.signal = signal
        self.last_event = get_sim_time('ps')
        self.last_rise = self.last_event
        self.last_fall = self.last_event
        start_soon(self.update())
      
    async def update(self):
        while 1:
            await Edge(self.signal)
            await ReadOnly()          # ReadOnly allows edge-edge measurment
            self.last_event = get_sim_time('ps')
            if self.signal == 1: self.last_rise = self.last_event
            else: self.last_fall = self.last_event
            
    def stable_interval(self, units='ps'):
        last_event_c = self.last_event/ps_conv[units]  # convert last_event to the prefix in use
        stable = get_sim_time(units) - last_event_c    # calculate stable interval
        return stable
  
 
class Monitor:
    """ Contains all tests checking signals in and from DUT """
    def __init__(self, dut):
        self.dut = dut
        self.dut._log.info("Starting monitoring events")
        self.en_mon  = SignalEventMonitor(self.dut.en)
        self.duty_mon = SignalEventMonitor(self.dut.duty_cycle)
        self.reset_mon = SignalEventMonitor(self.dut.reset)
        start_soon(self.reset())
        start_soon(self.dir_stability())
        start_soon(self.timeout())
        start_soon(self.duty_dir_cohesion())
        start_soon(self.duty_checks())
        
    async def reset(self):
        ''' Checks that PWM pulse (en) is deasserted when reset is applied '''
        while 1:
            await FallingEdge(self.dut.reset) 
            assert self.dut.en.value == 0, "PWM enable has not been deasserted during reset"
            self.dut._log.info("Passed: Reset test")

    async def dir_stability(self):
        ''' Checks that we are not short-circuiting the half-bridge by switching direction while pulsing '''
        while 1:
            await Edge(self.dut.dir)
            if self.dut.reset.value == 0:
                assert self.dut.en.value == 0, (
                  "HALF-BRIDGE SHORT CIRCUITED: en active when changing direction")
                assert self.en_mon.stable_interval('ns') > PERIOD_NS-1, (
                  "SHORT CIRCUIT DANGER: en deactivated less than one cycle before dir change") 
                wait_task = Timer(PERIOD_NS-1, 'ns')
                event_task = Edge(self.dut.en)
                result = await First(wait_task, event_task)
                assert result == wait_task, ( 
                  "SHORT CICUIT DANGER: En was not stable for {per} {uni}"
                  .format(per=PERIOD_NS, uni='ns'))

    async def timeout(self):
        ''' Checks that the PWM signal is actually driven within a reasonable timeframe'''
        while 1:
            if self.dut.duty_cycle.value == 0 : await Edge(self.dut.duty_cycle)
            await with_timeout(Edge(self.dut.en), PWM_TIMEOUT_MS, 'ms')       
            
    async def duty_dir_cohesion(self):
        ''' Checks that the pwm drives the motor in the correct direction'''
        while 1:    
            await Edge(self.dut.duty_cycle) 
            await ClockCycles(self.dut.mclk, 2)   # Trigger two clock edges after duty cycle was changed
            await ReadOnly()                      # Wait for all signals to settle (all delta delays)
            
            #Linjen under gir feil/ deprecation warning med nyere numpy 
            #duty = int(self.dut.duty_cycle.value) # Check if sign and dir matches
            duty = int(self.dut.duty_cycle.value.signed_integer) # Numpy compatibility 
            if np.int8(duty) > 0: 
                assert self.dut.dir.value == 1, (
                  "DIR is not '1' within 2 clock cycles of positive duty cycle: {DU} = {D}"
                  .format(DU=np.int8(duty), D=self.dut.duty_cycle.value))
            if np.int8(duty) < 0:  
                assert self.dut.dir.value == 0, (
                  "DIR is not '0' within 2 clock cycles of negative duty cycle: {DU} = {D}"
                  .format(DU=np.int8(duty), D=self.dut.duty_cycle.value))
                
    async def duty_checks(self):
        ''' Checks that pwm pulses are not happening too fast for the PMOD module '''
        await RisingEdge(self.dut.en)
        while 1:
            # Wait until we have a full period after reset
            if self.dut.reset.value == 1: 
                 await FallingEdge(self.dut.reset)
                 await RisingEdge(self.dut.en)
            await RisingEdge(self.dut.en)
            
            # Find the interval/period
            start = self.en_mon.last_rise/ps_conv['us']
            interval =  get_sim_time('us') - start
            
            # Trigger only when duty cycle has been stable for the last period
            if self.duty_mon.stable_interval('us') > interval:  
                assert interval > TOO_FAST_PWM_US, (
                  "PWM period too short!: {iv:.2f}us, f={f:.3f}kHz   Minimum period: {per} us, f<{maxf:.2f}kHz "
                  .format(iv=interval, f=(1000/interval), per=TOO_FAST_PWM_US, maxf=(1000/TOO_FAST_PWM_US))) 
                  
                # Calculate duty cycle   
                mid = self.en_mon.last_fall/ps_conv['us']
                high = mid-start
                measured_duty = np.int8((high*100)/interval)
                
                # Linjen under gir feil i nyere numpy 
                #set_duty = np.int8(self.dut.duty_cycle.value.integer)*100/128
                set_duty = np.int8(self.dut.duty_cycle.value.signed_integer)*100/128
                
                # Report duty cycle and check correspondens betweem input and output
                sign = "-" if self.dut.dir.value == 0 else " "
                self.dut._log.info(
                  "Duty cycles: Set dc: {S:.1f}%, Measured dc: {Sig}{M:.1f}%, period = {P:.1f}us, f = {F:.2f}kHz"
                  .format(S=set_duty, Sig = sign, M = measured_duty, P = interval, F = 1000/interval)) 
                abs_duty = abs(set_duty)
                deviation = np.int8(abs(abs_duty - measured_duty))
                assert deviation < 5, (                         
                  "Set and measured duty cycle deviates by more than 5% ({D}%) "
                  .format(D=deviation))
                          

class StimuliGenerator():
    ''' Generates all stimuli used in the normal tests '''
    def __init__(self, dut):
        self.dut = dut
        self.dut._log.info("Starting clock")
        start_soon(Clock(self.dut.mclk, PERIOD_NS, 'ns').start())
        self.dut.duty_cycle.value = 0
        start_soon(self.reset_module())

    async def reset_module(self):
        self.dut._log.info("Resetting module... ")
        self.dut.reset.value = 1
        await Timer(15, 'ns')
        self.dut.reset.value = 0
        
    async def run(self):
        self.dut._log.info("Starting duty cycle tests ")
        await Timer(20, 'ns')
        await self.seqential_duty_tests()
        self.dut._log.info("Sequential duty tests complete ")
        await self.random_duties(7)
        self.dut._log.info("Random duty tests 1/2 complete ")
        await self.reset_module()
        self.dut._log.info("Reset between duties complete ")
        await self.random_duties(3)
        self.dut._log.info("Random duty tests 2/2 complete ")
    
    def set_duty(self, duty_cycle):
        self.dut.duty_cycle.value= int((duty_cycle*128)/100) 
    
    async def seqential_duty_tests(self):
        self.set_duty(50)
        for i in range(3): 
            await RisingEdge(self.dut.en)
        self.set_duty(-50)
        for i in range(2): 
            await RisingEdge(self.dut.en)
        
    async def random_duties(self, tests):    
        duties = list(range(-90+1,-10)) + list(range(10+1,90))
        for x in range(tests):
            random_duty = random.choice(duties)
            duties.remove(random_duty)
            self.set_duty(random_duty)
            for i in range(2): 
                await RisingEdge(self.dut.en)
        interval = random.randint(1,300)
        await Timer(interval, units='us')


@cocotb.test()
async def main_test(dut):
    ''' Starts monitoring tasks and stimuli generators '''
    stimuli = StimuliGenerator(dut)
    await Timer(1, 'ns')   # Wait for Uninitialized (U) inputs to get a resolvable value 
    monitor = Monitor(dut)
    await stimuli.run()

    # Inject Faults to check that the testbench responds to faults
    #trip = FaultInjector(dut)  
    #await trip.run()
    #dut._log.info("*** Done testing ***")


class FaultInjector():
    """ Contain tests to verify that each assertion will trigger """
    def __init__(self, dut):
        self.dut = dut
        self.dut._log.info("*** TRIP-BENCH INITIALIZED ***")
        
    async def run(self):
        # TESTS run, comment out when working 
        #await self.reset()
        #await self.dir_stability_1()
        #await self.dir_stability_2()
        #await self.dir_stability_3()
        #await self.timeout()
        #await self.duty_dir_cohesion()
        #await self.too_fast_pwm()
        #await self.duty()
        assert False, "Trip run came to an end without tripping anything else!"
        
    def release(self):  
        ''' Releases all Forced values. '''
        self.dut.reset.value = Release()
        self.dut.en.value = Release()
        self.dut.dir.value = Release()
        self.dut.duty_cycle.value = Release()
    
    async def disable_reset(self):
        self.dut.reset.value = Force(0)
        await Timer(20, 'ns')
   
    async def reset(self):
        ''' Enable asserted while reset is deasserted'''
        self.dut.reset.value = Force(1)
        self.dut.en.value = Force(1)
        await RisingEdge(self.dut.mclk)
        self.dut.reset.value = Force(0)
        await RisingEdge(self.dut.mclk)
        self.release()
    
    async def dir_stability_1(self):
        ''' Enable is not deasserted when dir changes'''
        await self.disable_reset()
        self.dut.dir.value = Force(0)
        self.dut.en.value = Force(1)
        await Timer(1, 'ns')
        self.dut.dir.value = Force(1)
        await Timer(30, 'ns')
        self.release()
        
    async def dir_stability_2(self):
        ''' Enable is deasserted within one clock cycle of dir changing''' 
        await self.disable_reset()
        self.dut.en.value = Force(1)
        await Timer(1, 'ns')
        self.dut.en.value = Force(0)
        await Timer(8, 'ns')
        self.dut.dir.value = Force(not self.dut.dir.value)
        await Timer(10, 'ns')
        self.release()
        
    async def dir_stability_3(self):
        ''' Enable asserted within one clock cycle after dir changing '''
        await self.disable_reset()
        self.dut.en.value = Force(0)
        await Timer(20, 'ns')
        self.dut.dir.value = Force(not self.dut.dir.value)
        await Timer(8, 'ns')
        self.dut.en.value = Force(1)
        await Timer(1, 'ns')
        self.release()
        
    async def timeout(self):
        ''' Prevents pulsing although a nonzero duty cycle'''
        await self.disable_reset()
        self.dut._log.info("*** timeout test started: this may take minutes ***")
        self.dut.duty_cycle.value = Force(0x50)
        # Stopping clock might be useful to reduce time spent here.
        # Requires a pointer/handle to the process. 
        self.dut.en.value = Force(0)
        await Timer(PWM_TIMEOUT_MS+1, 'ms')
        self.release()
        
    async def duty_dir_cohesion(self):
        ''' To not have dir correspond to duty cycle within two clock cycles'''
        await self.disable_reset()
        self.dut.dir.value = Freeze()
        self.dut.duty_cycle.value = Force(0xEE)
        await ClockCycles(self.dut.mclk, 3)
        self.dut.duty_cycle.value = Force(0x11)
        await ClockCycles(self.dut.mclk, 3)
        self.release()
        
    async def too_fast_pwm(self):
        ''' Runs PWM signal (en) faster than allowed by TB'''
        await self.disable_reset()
        for i in range(4):    
            self.dut.en.value = Force(1)    
            await RisingEdge(self.dut.mclk)
            self.dut.en.value = Force(0);
            await RisingEdge(self.dut.mclk)
        self.release()
      
    async def duty(self):
        ''' Asserts one duty cycle, and pulses another'''
        await self.disable_reset()
        self.dut.en.value = Force(0)
        await ClockCycles(self.dut.mclk, 10)
        self.dut.duty_cycle.value = Force(-32) # 25% as hex (128 = 100%)
        await ClockCycles(self.dut.mclk, 10)
        for i in range(4):    
            self.dut.en.value = Force(1)    
            await ClockCycles(self.dut.mclk, 8001)
            self.dut.en.value = Force(0);
            await ClockCycles(self.dut.mclk, 8001)
        self.release()
        