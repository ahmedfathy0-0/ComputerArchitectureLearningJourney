# ModelSim DO file for testing elevator_fsm
# Tests the SCAN algorithm with direction-based floor selection

# Create work library if it doesn't exist
vlib work

# Compile all required VHDL files
vcom -93 ../src/timer.vhd
vcom -93 ../src/ssd.vhd
vcom -93 ../src/fsm.vhd

# Start simulation with small timer for fast testing
# Clock period = 200ms means frequency = 5Hz
# CLOCK_FREQ=5 means timer counts 5 cycles for DURATION_SEC=1
# So door stays open for 10 clock cycles (2 seconds in real time)
vsim work.elevator_fsm -g/door_timer_inst/CLOCK_FREQ=5 -g/door_timer_inst/DURATION_SEC=2

# Add waves to waveform viewer
add wave -divider "Clock and Reset"
add wave -format logic /elevator_fsm/clk
add wave -format logic /elevator_fsm/reset

add wave -divider "Inputs"
add wave -format literal -radix binary /elevator_fsm/floor_request
add wave -format logic /elevator_fsm/request_valid

add wave -divider "State Machine"
add wave -format literal /elevator_fsm/current_state
add wave -format literal /elevator_fsm/next_state
add wave -format literal /elevator_fsm/direction

add wave -divider "Floor Information"
add wave -format literal -radix unsigned /elevator_fsm/current_floor_internal
add wave -format literal -radix unsigned /elevator_fsm/target_floor
add wave -format literal -radix binary /elevator_fsm/pending_requests

add wave -divider "Timer Signals"
add wave -format logic /elevator_fsm/timer_enable
add wave -format logic /elevator_fsm/timer_reset
add wave -format logic /elevator_fsm/timer_done

add wave -divider "Outputs"
add wave -format literal -radix unsigned /elevator_fsm/current_floor
add wave -format literal -radix binary /elevator_fsm/seven_segment
add wave -format literal -radix binary /elevator_fsm/door_status

# Helper procedure to generate clock pulses
proc clk_pulse {num} {
    for {set i 0} {$i < $num} {incr i} {
        force -freeze clk 0 0, 1 {10 ns} -r 20ns
        run 20ns
    }
}

# Helper procedure to convert decimal to 4-bit binary string
proc dec_to_bin4 {num} {
    set bin ""
    for {set i 3} {$i >= 0} {incr i -1} {
        if {$num >= [expr {1 << $i}]} {
            append bin "1"
            set num [expr {$num - (1 << $i)}]
        } else {
            append bin "0"
        }
    }
    return $bin
}

# Helper procedure to request a floor
proc request_floor {floor_num} {
    set bin_value [dec_to_bin4 $floor_num]
    force floor_request 2#$bin_value
    force request_valid 1
    run 200ms
    force request_valid 0
    run 200ms
}

# Initialize signals and start clock
force reset 1
force floor_request 0000
force request_valid 0

# Start clock with 200ms period (100ms high, 100ms low) = 5Hz
force -freeze clk 0 0ms, 1 100ms -r 200ms

# Run for a bit with reset active
run 200ms

# Release reset
force reset 0
run 400ms

echo "=========================================="
echo "Test 1: Basic request to floor 5"
echo "=========================================="
request_floor 5
run 400ms

echo "=========================================="
echo "Test 2: SCAN Algorithm Test"
echo "Expected: Go to floor 9, then 5, then 3"
echo "=========================================="
# Reset system
force reset 1
run 40ns
force reset 0
run 40ns

# Request floor 9 first (elevator will start going UP)
echo "Requesting floor 9..."
request_floor 9
run 100ns

# While at floor 2, request floor 5 (should service on the way up)
echo "At floor 2, requesting floor 5..."
request_floor 5
run 100ns

# Request floor 3 (should service after 9, on the way down)
echo "Requesting floor 3..."
request_floor 3
run 100ns

# Let elevator complete its journey
# Should go: 0->5->9->3
run 2000ns

echo "=========================================="
echo "Test 3: Multiple requests in same direction"
echo "=========================================="
# Reset system
force reset 1
run 40ns
force reset 0
run 40ns

# Request multiple floors: 2, 5, 7, 9
echo "Requesting floors 2, 5, 7, 9..."
request_floor 2
run 40ns
request_floor 5
run 40ns
request_floor 7
run 40ns
request_floor 9
run 40ns

# Let elevator service all floors
run 2500ns

echo "=========================================="
echo "Test 4: Direction reversal test"
echo "=========================================="
# Reset system
force reset 1
run 40ns
force reset 0
run 40ns

# Start at floor 0, go up to floor 8
echo "Requesting floor 8..."
request_floor 8
run 400ns

# While going up (around floor 4), request floor 2
echo "At floor 4, requesting floor 2..."
request_floor 2
run 100ns

# Elevator should finish going to 8, then come back to 2
run 2000ns

echo "=========================================="
echo "Test 5: Door timer test"
echo "=========================================="
# Reset system
force reset 1
run 40ns
force reset 0
run 40ns

# Request a floor and verify door stays open for correct duration
echo "Requesting floor 3 to test door timer..."
request_floor 3
run 500ns

# Wait for door to open and close
# Timer is set for 2 seconds with 5Hz clock = 10 cycles
# In simulation with 200ms clock period, this takes 2 seconds
# For faster simulation, observe timer_enable and timer_done signals
run 3s

echo "=========================================="
echo "Test 6: Invalid floor request (floor 15)"
echo "=========================================="
# Reset system
force reset 1
run 40ns
force reset 0
run 40ns

echo "Requesting invalid floor 15 (should be ignored)..."
request_floor 15
run 100ns

echo "Requesting valid floor 4..."
request_floor 4
run 500ns

echo "=========================================="
echo "Test 7: Seven segment display verification"
echo "Expected: Display should show current floor"
echo "=========================================="
# Reset system
force reset 1
run 40ns
force reset 0
run 40ns

# Request floors and verify display changes
for {set floor 0} {$floor <= 9} {incr floor} {
    echo "Requesting floor $floor..."
    request_floor $floor
    run 400ns
}

echo "=========================================="
echo "All tests completed!"
echo "=========================================="

# Configure wave window
wave zoom full
