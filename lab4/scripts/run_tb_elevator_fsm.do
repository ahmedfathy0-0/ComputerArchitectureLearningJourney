# ============================================================
# Testbench DO File for Elevator FSM
# ============================================================
# This script runs the VHDL testbench tb_elevator_fsm.vhd
# with proper timer frequency configuration for fast simulation
# Run this script from lab4 directory: vsim -do scripts/run_tb_elevator_fsm.do
# ============================================================

# Create work library
vlib work

# Compile all required files (from src and test directories)
vcom -93 src/timer.vhd
vcom -93 src/ssd.vhd
vcom -93 src/elevator_fsm.vhd
vcom -93 test/tb_elevator_fsm.vhd

# Start simulation with configuration (this applies timer frequency overrides)
vsim work.tb_elevator_fsm_cfg

# Add waves for visualization
add wave -divider "Clock and Reset"
add wave -format logic sim:/tb_elevator_fsm/clk
add wave -format logic sim:/tb_elevator_fsm/reset

add wave -divider "Generics/Constants"
add wave -format literal -radix unsigned sim:/tb_elevator_fsm/uut/N_FLOORS

add wave -divider "Inputs"
add wave -format literal -radix binary sim:/tb_elevator_fsm/floor_request
add wave -format logic sim:/tb_elevator_fsm/request_valid

add wave -divider "FSM State"
add wave -format literal sim:/tb_elevator_fsm/uut/current_state
add wave -format literal sim:/tb_elevator_fsm/uut/next_state
add wave -format literal sim:/tb_elevator_fsm/uut/direction

add wave -divider "Floor Information"
add wave -format literal -radix unsigned sim:/tb_elevator_fsm/current_floor
add wave -format literal -radix unsigned sim:/tb_elevator_fsm/uut/target_floor
add wave -format literal -radix binary sim:/tb_elevator_fsm/uut/pending_requests

add wave -divider "Outputs"
add wave -format literal -radix binary sim:/tb_elevator_fsm/door_status
add wave -format literal -radix binary sim:/tb_elevator_fsm/seven_segment

add wave -divider "Door Timer Signals"
add wave -format logic sim:/tb_elevator_fsm/uut/door_timer_reset
add wave -format logic sim:/tb_elevator_fsm/uut/door_timer_enable
add wave -format logic sim:/tb_elevator_fsm/uut/door_timer_done

add wave -divider "Movement Timer Signals"
add wave -format logic sim:/tb_elevator_fsm/uut/move_timer_reset
add wave -format logic sim:/tb_elevator_fsm/uut/move_timer_enable
add wave -format logic sim:/tb_elevator_fsm/uut/move_timer_done

# Configure wave window
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

echo "============================================================"
echo "Starting Elevator FSM Testbench"
echo "============================================================"
echo "Timer Configuration:"
echo "  CLOCK_FREQ = 10 Hz (for fast simulation)"
echo "  DURATION_SEC = 2 seconds"
echo "  Timer period = 20 clock cycles"
echo "============================================================"
echo "Test Cases Included:"
echo "  1. Basic single floor requests"
echo "  2. Multiple floor requests (SCAN algorithm)"
echo "  3. Reset functionality"
echo "  4. Same floor request while idle"
echo "  5. Movement timer observation"
echo "  6. SCAN with intermediate requests (moving up 3->9, add 5 & 1)"
echo "  7. Same floor request handling"
echo "  8. Boundary floor tests (0 and 9)"
echo "  9. Rapid multiple requests in both directions"
echo "  10. Request during door open state"
echo "  11. Idempotent requests (same floor multiple times)"
echo "============================================================"

# Run the complete testbench
run -all

echo "============================================================"
echo "Testbench execution completed!"
echo "============================================================"
echo "Check the wave window to verify:"
echo "  1. Elevator moves to requested floors"
echo "  2. Door opens for correct duration at each floor"
echo "  3. SCAN algorithm follows correct sequence"
echo "  4. Intermediate requests handled correctly while moving"
echo "  5. Same floor requests open door immediately"
echo "  6. Boundary floors (0 & 9) work correctly"
echo "  7. Reset clears pending requests"
echo "  8. Seven segment display shows correct floor"
echo "  9. Multiple rapid requests handled properly"
echo "  10. Requests during door open are queued correctly"
echo "============================================================"

# Zoom to show all activity
wave zoom full
