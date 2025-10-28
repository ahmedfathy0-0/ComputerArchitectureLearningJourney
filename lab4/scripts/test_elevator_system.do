# ModelSim DO file for testing the Elevator System
# This script compiles all required VHDL files and runs comprehensive tests

# Create work library if it doesn't exist
if {[file exists work]} {
    vdel -lib work -all
}
vlib work

# Compile all source files in order of dependencies
echo "Compiling Elevator System components..."

# Compile the types package first
vcom -2008 -work work ../src/elevator_controller.vhd

# Compile supporting components
vcom -2008 -work work ../src/timer.vhd
vcom -2008 -work work ../src/ssd.vhd

# Compile main components
vcom -2008 -work work ../src/request_handler.vhd

# Compile top-level entity
vcom -2008 -work work ../src/elevator_system.vhd

# Start simulation with reduced clock frequency for faster testing
# Using CLOCK_FREQ=100 instead of 50MHz (50_000_000) for practical simulation time
vsim -voptargs=+acc work.elevator_system -GCLOCK_FREQ=100

# Configure wave window
echo "Configuring wave window..."

# Add clock and reset signals
add wave -divider "Clock and Control"
add wave -label "Clock" /elevator_system/clk
add wave -label "Reset" /elevator_system/reset

# Add input signals
add wave -divider "User Inputs"
add wave -label "Floor Select" -radix unsigned /elevator_system/floor_select
add wave -label "Request Button" /elevator_system/request_button

# Add output signals
add wave -divider "Elevator Outputs"
add wave -label "Current Floor" -radix unsigned /elevator_system/current_floor
add wave -label "Door State" /elevator_system/door_state
add wave -label "SSD Display" -radix binary /elevator_system/ssd_floor

# Add internal signals for debugging
add wave -divider "Internal Signals"
add wave -label "Next Floor" -radix unsigned /elevator_system/next_floor_internal
add wave -label "Enable" /elevator_system/enable_internal
add wave -label "Clear Request" /elevator_system/clear_request_internal
add wave -label "Button Sync" /elevator_system/button_sync
add wave -label "Button Pressed" /elevator_system/button_pressed

# Add Request Handler signals
add wave -divider "Request Handler"
add wave -label "Pending Requests" -radix binary /elevator_system/request_handler_inst/pending_requests
add wave -label "Direction" /elevator_system/request_handler_inst/direction

# Add Elevator Controller signals
add wave -divider "Elevator Controller"
add wave -label "Controller State" /elevator_system/elevator_controller_inst/state
add wave -label "Timer Done" /elevator_system/elevator_controller_inst/timer_done
add wave -label "Timer Enable" /elevator_system/elevator_controller_inst/timer_enable

# Configure wave window properties
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

# Initialize signals
echo "Initializing signals..."
force clk 0 0ns, 1 10ns -repeat 20ns
force reset 1
force floor_select 0000
force request_button 0

# Run initial reset
echo "Running initial reset..."
run 100ns
force reset 0
run 100ns

# Test Scenario 1: Single floor request (floor 5)
echo "=========================================="
echo "Test 1: Request floor 5 from ground floor"
echo "=========================================="
force floor_select 0101
run 40ns
force request_button 1
run 40ns
force request_button 0
run 20us

# Test Scenario 2: Multiple upward requests
echo "=========================================="
echo "Test 2: Multiple upward requests (3, 7, 9)"
echo "=========================================="
force floor_select 0011
run 40ns
force request_button 1
run 40ns
force request_button 0
run 200ns

force floor_select 0111
run 40ns
force request_button 1
run 40ns
force request_button 0
run 200ns

force floor_select 1001
run 40ns
force request_button 1
run 40ns
force request_button 0
run 50us

# Test Scenario 3: SCAN algorithm test (mixed directions)
echo "=========================================="
echo "Test 3: SCAN algorithm with mixed requests"
echo "=========================================="
force floor_select 0100
run 40ns
force request_button 1
run 40ns
force request_button 0
run 200ns

force floor_select 0010
run 40ns
force request_button 1
run 40ns
force request_button 0
run 200ns

force floor_select 0111
run 40ns
force request_button 1
run 40ns
force request_button 0
run 60us

# Test Scenario 4: Downward movement test
echo "=========================================="
echo "Test 4: Downward movement from high floor"
echo "=========================================="
force floor_select 0001
run 40ns
force request_button 1
run 40ns
force request_button 0
run 200ns

force floor_select 0000
run 40ns
force request_button 1
run 40ns
force request_button 0
run 40us

# Test Scenario 5: Reset during operation
echo "=========================================="
echo "Test 5: Reset clears pending requests"
echo "=========================================="
force floor_select 1000
run 40ns
force request_button 1
run 40ns
force request_button 0
run 200ns

force floor_select 0101
run 40ns
force request_button 1
run 40ns
force request_button 0
run 1us

# Apply reset
force reset 1
run 200ns
force reset 0
run 5us

# Test Scenario 6: Rapid consecutive requests
echo "=========================================="
echo "Test 6: Rapid consecutive requests"
echo "=========================================="
force floor_select 0010
run 40ns
force request_button 1
run 40ns
force request_button 0
run 100ns

force floor_select 0011
run 40ns
force request_button 1
run 40ns
force request_button 0
run 100ns

force floor_select 0100
run 40ns
force request_button 1
run 40ns
force request_button 0
run 30us

# Test Scenario 7: Same floor request (should be served immediately)
echo "=========================================="
echo "Test 7: Request current floor"
echo "=========================================="
# Wait for elevator to be at a stable floor
run 5us
force floor_select 0100
run 40ns
force request_button 1
run 40ns
force request_button 0
run 10us

echo "=========================================="
echo "All tests completed!"
echo "=========================================="
echo "Check the wave window to verify:"
echo "1. Elevator moves to requested floors"
echo "2. Door opens for 2 seconds at each floor"
echo "3. SCAN algorithm follows correct sequence"
echo "4. Reset clears pending requests"
echo "5. Seven segment display shows correct floor"
echo "=========================================="

# Zoom to show all activity
wave zoom full
