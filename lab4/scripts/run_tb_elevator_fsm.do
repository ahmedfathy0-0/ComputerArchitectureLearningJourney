# ============================================================
# Modular Elevator Controller - Simulation Script
# ============================================================
# Run from lab4 directory: vsim -do scripts/run_tb_elevator_fsm.do
# ============================================================

vlib work

echo "============================================================"
echo "Compiling Modular Elevator Controller"
echo "============================================================"

echo "Compiling package and basic components..."
vcom -93 src/elevator_pkg.vhd
vcom -93 src/timer.vhd
vcom -93 src/ssd.vhd

echo "Compiling modular subsystem components..."
vcom -93 src/request_mgr.vhd
vcom -93 src/scan_sched.vhd
vcom -93 src/fsm_ctrl.vhd
vcom -93 src/move_ctrl.vhd
vcom -93 src/door_ctrl.vhd

echo "Compiling top-level controller..."
vcom -93 src/elevator_ctrl.vhd

echo "Compiling testbench..."
vcom -93 test/elevator_ctrl_tb.vhd

echo "============================================================"
echo "Starting Simulation"
echo "============================================================"

vsim work.elevator_ctrl_tb_cfg

# Wait for design to be fully elaborated
quietly set NumericStdNoWarnings 1
quietly set StdArithNoWarnings 1

# Add waves (suppress warnings about missing signals during batch add)
quietly add wave -divider "Clock and Reset"
quietly add wave -format logic /elevator_ctrl_tb/clk
quietly add wave -format logic /elevator_ctrl_tb/reset

quietly add wave -divider "Generics/Constants"
quietly add wave -format literal -radix unsigned /elevator_ctrl_tb/uut/N_FLOORS

quietly add wave -divider "Inputs"
quietly add wave -format literal -radix binary /elevator_ctrl_tb/floor_request
quietly add wave -format logic /elevator_ctrl_tb/request_valid

quietly add wave -divider "FSM State"
quietly add wave -format literal /elevator_ctrl_tb/uut/current_state
# Note: next_state is an internal signal, may not be visible in all configurations
quietly add wave -format literal /elevator_ctrl_tb/uut/direction

quietly add wave -divider "Floor Information"
quietly add wave -format literal -radix unsigned /elevator_ctrl_tb/current_floor
quietly add wave -format literal -radix unsigned /elevator_ctrl_tb/uut/target_floor
quietly add wave -format literal -radix binary /elevator_ctrl_tb/uut/pending_requests

quietly add wave -divider "Outputs"
quietly add wave -format literal -radix binary /elevator_ctrl_tb/door_status
quietly add wave -format literal -radix binary /elevator_ctrl_tb/seven_segment

quietly add wave -divider "Timer Signals"
quietly add wave -format logic /elevator_ctrl_tb/uut/door_timer_reset
quietly add wave -format logic /elevator_ctrl_tb/uut/door_timer_enable
quietly add wave -format logic /elevator_ctrl_tb/uut/door_timer_done
quietly add wave -format logic /elevator_ctrl_tb/uut/move_timer_reset
quietly add wave -format logic /elevator_ctrl_tb/uut/move_timer_enable
quietly add wave -format logic /elevator_ctrl_tb/uut/move_timer_done

quietly add wave -divider "Modular Components"
quietly add wave -format logic /elevator_ctrl_tb/uut/clear_request
quietly add wave -format literal -radix unsigned /elevator_ctrl_tb/uut/current_floor_internal

configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

echo "============================================================"
echo "Modular Elevator Controller Architecture:"
echo "  - elevator_pkg    : Common types and constants"
echo "  - request_mgr     : Request queue manager"
echo "  - scan_sched      : SCAN algorithm scheduler"
echo "  - fsm_ctrl        : Main state machine"
echo "  - move_ctrl       : Movement controller"
echo "  - door_ctrl       : Door controller"
echo "  - timer (x2)      : Door and movement timers"
echo "  - ssd             : Seven segment display"
echo "============================================================"
echo "Timer Configuration:"
echo "  CLOCK_FREQ = 10 Hz (for fast simulation)"
echo "  DURATION_SEC = 2 seconds"
echo "  Timer period = 20 clock cycles"
echo "============================================================"
echo "Test Cases Included (13 comprehensive tests):"
echo "  1. Basic single floor requests"
echo "  2. Multiple floor requests (SCAN algorithm)"
echo "  3. Reset functionality"
echo "  4. Same floor request while idle"
echo "  5. Movement timer observation"
echo "  6. SCAN intermediate requests (moving up 3->9, add 5 & 1)"
echo "  7. Same floor request handling"
echo "  8. Boundary floor tests (0 and 9)"
echo "  9. Rapid multiple requests in both directions"
echo "  10. Request during door open state"
echo "  11. Idempotent requests (same floor multiple times)"
echo "============================================================"
echo "Each test includes PASS/FAIL assertions!"
echo "============================================================"

# Run the complete testbench
run -all

echo "============================================================"
echo "Simulation Complete!"
echo "============================================================"
echo "Review PASSED/FAILED messages in transcript"
echo "Verify modular component behavior in waveform"
echo "Check signal flow between components"
echo "============================================================"

# Zoom to show all activity
wave zoom full
