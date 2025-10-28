# ModelSim DO file for testing specific elevator request sequence
# Tests sequence: 9 -> 5 -> 4 -> 8 -> 2
# Expected behavior with SCAN algorithm:
# Start at floor 0
# Request 9: Move up, heading to 9
# Requests come in WHILE moving up:
#   - If we haven't passed the floor yet, serve it on the way up
#   - If we've already passed it, serve on the way down
# SCAN serves requests in the direction of travel
# Expected order: 2 (if before we pass it), 4, 5, 8, 9 on way up
# Then any remaining floors on way down

# Create work library if it doesn't exist
if {[file exists work]} {
    vdel -lib work -all
}
vlib work

# Compile all source files in order of dependencies
echo "Compiling Elevator System components..."

# Compile the types package first (inside elevator_controller.vhd)
vcom -2008 -work work ../src/elevator_controller.vhd

# Compile supporting components
vcom -2008 -work work ../src/timer.vhd
vcom -2008 -work work ../src/ssd.vhd

# Compile main components
vcom -2008 -work work ../src/request_handler.vhd

# Compile top-level entity
vcom -2008 -work work ../src/elevator_system.vhd

# Start simulation with reduced clock frequency for faster testing
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
add wave -label "Button Pressed" /elevator_system/button_pressed

# Add Request Handler signals
add wave -divider "Request Handler"
add wave -label "Pending Requests" -radix binary /elevator_system/request_handler_inst/pending_requests
add wave -label "Direction" /elevator_system/request_handler_inst/direction

# Add Elevator Controller signals
add wave -divider "Elevator Controller"
add wave -label "Controller State" /elevator_system/elevator_controller_inst/state
add wave -label "Timer Done" /elevator_system/elevator_controller_inst/timer_done

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
echo "=========================================="
echo "Initial Reset"
echo "=========================================="
run 100ns
force reset 0
run 100ns

echo "Current floor should be 0"
echo "=========================================="

# Request 1: Floor 9
echo "=========================================="
echo "Request 1: Floor 9"
echo "Expected: Elevator moves up 0->9"
echo "=========================================="
force floor_select 1001
run 40ns
force request_button 1
run 40ns
force request_button 0
run 500ns

# Request 2: Floor 5 (while moving to 9)
echo "=========================================="
echo "Request 2: Floor 5 (while at floor 0-1)"
echo "Expected: If not passed yet, serve on way up"
echo "=========================================="
force floor_select 0101
run 40ns
force request_button 1
run 40ns
force request_button 0
run 1us

# Request 3: Floor 4 (while moving to 9)
echo "=========================================="
echo "Request 3: Floor 4 (while at floor 0-2)"
echo "Expected: If not passed yet, serve on way up"
echo "=========================================="
force floor_select 0100
run 40ns
force request_button 1
run 40ns
force request_button 0
run 1us

# Request 4: Floor 8 (while moving to 9)
echo "=========================================="
echo "Request 4: Floor 8 (while at floor 0-3)"
echo "Expected: If not passed yet, serve on way up"
echo "=========================================="
force floor_select 1000
run 40ns
force request_button 1
run 40ns
force request_button 0
run 1us

# Request 5: Floor 2 (while moving to 9)
echo "=========================================="
echo "Request 5: Floor 2 (while at floor 0-4)"
echo "Expected: If not passed yet, serve on way up"
echo "=========================================="
force floor_select 0010
run 40ns
force request_button 1
run 40ns
force request_button 0
run 2us

# Wait for elevator to complete the sequence
echo "=========================================="
echo "Waiting for elevator to serve all floors..."
echo "Expected: Serve in ascending order on way up"
echo "=========================================="
run 80us

echo "=========================================="
echo "SCAN should serve floors in order they appear in direction:"
echo "If moving UP: serve all floors in ascending order (2,4,5,8,9)"
echo "=========================================="

# Assertions and verification
echo "=========================================="
echo "Test Verification"
echo "=========================================="
echo ""
echo "Correct SCAN Expected Sequence:"
echo "1. Floor 0 (start)"
echo "2. Request 9 -> Start moving UP"
echo "3. Requests come in while moving:"
echo "   - Floor 2 requested (ahead in UP direction) -> serve on way"
echo "   - Floor 4 requested (ahead in UP direction) -> serve on way"
echo "   - Floor 5 requested (ahead in UP direction) -> serve on way"
echo "   - Floor 8 requested (ahead in UP direction) -> serve on way"
echo "4. SCAN serves all in ascending order: 0->2->4->5->8->9"
echo "5. Each floor: door opens for 2us"
echo "6. After floor 9, no more requests, IDLE at floor 9"
echo ""
echo "=========================================="
echo "Verification Points:"
echo "=========================================="
echo "Check in wave window:"
echo "1. Pending Requests shows bits [9,8,5,4,2] all set at some point"
echo "2. Direction stays UP throughout (no reversal needed)"
echo "3. Floors served in ascending order: 2, 4, 5, 8, 9"
echo "4. Door opens for 2us at each floor (200 cycles @ 100Hz)"
echo "5. Clear Request pulses at each floor as served"
echo "6. Final position: floor 9 with no pending requests"
echo "=========================================="

# Additional manual assertions (check visually in wave)
echo ""
echo "Manual Checks in Wave Window:"
echo "- Elevator should stop at floor 2 first"
echo "- Then floor 4"
echo "- Then floor 5"
echo "- Then floor 8"
echo "- Finally floor 9"
echo "- Direction should remain UP throughout"
echo "- Pending Requests should be 0000000000 at end"
echo "- Final floor should be 9"
echo "=========================================="

# Zoom to show all activity
wave zoom full

echo ""
echo "Test sequence complete!"
echo "Review the wave window to verify correct behavior."
