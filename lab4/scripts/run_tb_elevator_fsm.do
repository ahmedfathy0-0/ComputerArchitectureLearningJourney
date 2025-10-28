vlib work

vcom -93 src/timer.vhd
vcom -93 src/ssd.vhd
vcom -93 src/elevator_ctrl.vhd
vcom -93 test/elevator_ctrl_tb.vhd

vsim work.elevator_ctrl_tb_cfg

add wave -divider "Clock and Reset"
add wave -format logic sim:/elevator_ctrl_tb/clk
add wave -format logic sim:/elevator_ctrl_tb/reset

add wave -divider "Generics/Constants"
add wave -format literal -radix unsigned sim:/elevator_ctrl_tb/uut/N_FLOORS

add wave -divider "Inputs"
add wave -format literal -radix binary sim:/elevator_ctrl_tb/floor_request
add wave -format logic sim:/elevator_ctrl_tb/request_valid

add wave -divider "FSM State"
add wave -format literal sim:/elevator_ctrl_tb/uut/current_state
add wave -format literal sim:/elevator_ctrl_tb/uut/next_state
add wave -format literal sim:/elevator_ctrl_tb/uut/direction

add wave -divider "Floor Information"
add wave -format literal -radix unsigned sim:/elevator_ctrl_tb/current_floor
add wave -format literal -radix unsigned sim:/elevator_ctrl_tb/uut/target_floor
add wave -format literal -radix binary sim:/elevator_ctrl_tb/uut/pending_requests

add wave -divider "Outputs"
add wave -format literal -radix binary sim:/elevator_ctrl_tb/door_status
add wave -format literal -radix binary sim:/elevator_ctrl_tb/seven_segment

add wave -divider "Door Timer Signals"
add wave -format logic sim:/elevator_ctrl_tb/uut/door_timer_reset
add wave -format logic sim:/elevator_ctrl_tb/uut/door_timer_enable
add wave -format logic sim:/elevator_ctrl_tb/uut/door_timer_done

add wave -divider "Movement Timer Signals"
add wave -format logic sim:/elevator_ctrl_tb/uut/move_timer_reset
add wave -format logic sim:/elevator_ctrl_tb/uut/move_timer_enable
add wave -format logic sim:/elevator_ctrl_tb/uut/move_timer_done

configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

echo "  CLOCK_FREQ = 10 Hz (for fast simulation)"
echo "  DURATION_SEC = 2 seconds"
echo "  Timer period = 20 clock cycles"
echo "============================================================"
echo "Test Cases Included:"
echo "  1. Basic single floor requests"
echo "  2. Multiple floor requests"
echo "  3. Reset functionality"
echo "  4. Same floor request while idle"
echo "  5. Movement timer observation"
echo "  6. Intermediate requests (moving up 3->9, add 5 & 1)"
echo "  7. Same floor request handling"
echo "  8. Boundary floor tests (0 and 9)"
echo "  9. Rapid multiple requests in both directions"
echo "  10. Request during door open state"
echo "  11. Idempotent requests (same floor multiple times)"
echo "============================================================"

# Run the complete testbench
run -all

# Zoom to show all activity
wave zoom full
