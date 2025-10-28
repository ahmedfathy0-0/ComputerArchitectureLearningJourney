# ============================================================
# Elevator FSM DO File - Two Timer Configuration
# ============================================================
# Updated for movement timer and door timer
# 
# IMPORTANT: Make sure your timer.vhd has this code:
# VARIABLE counter : INTEGER RANGE 0 TO CLOCK_FREQ * DURATION_SEC - 1 := 0;
# And uses: counter < CLOCK_FREQ * DURATION_SEC - 1
#           counter = CLOCK_FREQ * DURATION_SEC - 1
# (NOT MAX_COUNT)
# ============================================================

# Compile all required files
vlib work
vcom -93 timer.vhd
vcom -93 ssd.vhd
vcom -93 elevator_fsm.vhd

# Start simulation with generic parameter N_FLOORS=10 (default)
vsim -g N_FLOORS=10 work.elevator_fsm

# Add waves for better visualization
add wave -divider "Clock and Reset"
add wave sim:/elevator_fsm/clk
add wave sim:/elevator_fsm/reset

add wave -divider "Generics/Constants"
add wave -radix unsigned sim:/elevator_fsm/N_FLOORS
add wave -radix unsigned sim:/elevator_fsm/MAX_FLOOR

add wave -divider "Inputs"
add wave -radix binary sim:/elevator_fsm/floor_request
add wave sim:/elevator_fsm/request_valid

add wave -divider "FSM State"
add wave sim:/elevator_fsm/current_state
add wave sim:/elevator_fsm/next_state
add wave sim:/elevator_fsm/direction

add wave -divider "Floor Information"
add wave -radix unsigned sim:/elevator_fsm/current_floor
add wave -radix unsigned sim:/elevator_fsm/target_floor
add wave -radix binary sim:/elevator_fsm/pending_requests

add wave -divider "Outputs"
add wave -radix binary sim:/elevator_fsm/door_status
add wave -radix binary sim:/elevator_fsm/seven_segment

add wave -divider "Door Timer Signals"
add wave sim:/elevator_fsm/door_timer_reset
add wave sim:/elevator_fsm/door_timer_enable
add wave sim:/elevator_fsm/door_timer_done
add wave -radix unsigned sim:/elevator_fsm/door_timer_inst/counter

add wave -divider "Movement Timer Signals"
add wave sim:/elevator_fsm/move_timer_reset
add wave sim:/elevator_fsm/move_timer_enable
add wave sim:/elevator_fsm/move_timer_done
add wave -radix unsigned sim:/elevator_fsm/move_timer_inst/counter

# Restart simulation with force
restart -f

# Change generic parameters for faster simulation
# (Warning about constant is normal and can be ignored)
change sim:/elevator_fsm/door_timer_inst/CLOCK_FREQ 5
change sim:/elevator_fsm/door_timer_inst/DURATION_SEC 2
change sim:/elevator_fsm/move_timer_inst/CLOCK_FREQ 5
change sim:/elevator_fsm/move_timer_inst/DURATION_SEC 2

# Generate clock signal (5ns period to match CLOCK_FREQ=10)
# Pattern: high at 0ns, low at 2ns, repeat every 5ns
force -freeze sim:/elevator_fsm/clk 1 0ns, 0 {2 ns} -r 5ns

# Initialize reset (active high system)
force -freeze sim:/elevator_fsm/reset 1 0
run 10 ns
force -freeze sim:/elevator_fsm/reset 0 0

# Initialize inputs
force -freeze sim:/elevator_fsm/floor_request 0000 0
force -freeze sim:/elevator_fsm/request_valid 0 0

echo "============================================================"
echo "Elevator FSM Simulation Started (Two Timer Configuration)"
echo "N_FLOORS: 10 (floors 0-9)"
echo "Clock period: 5ns (CLOCK_FREQ adjusted to 10 for fast sim)"
echo "Door timer: 2 seconds = 20 clock cycles"
echo "Movement timer: 2 seconds = 20 clock cycles per floor"
echo "============================================================"
echo ""
echo "To simulate with different number of floors, restart with:"
echo "  vsim -g N_FLOORS=<number> work.elevator_fsm"
echo "  (e.g., vsim -g N_FLOORS=5 work.elevator_fsm for 5 floors)"
echo "============================================================"
echo ""

# Run initial setup
run 50 ns

# Test 1: Request floor 3
echo "TEST 1: Request floor 3 (should take 3 floors x 20 cycles = 60 cycles)"
force -freeze sim:/elevator_fsm/floor_request 0011 0
force -freeze sim:/elevator_fsm/request_valid 1 0
run 10 ns
force -freeze sim:/elevator_fsm/request_valid 0 0
run 400 ns

echo "Current floor:"
examine sim:/elevator_fsm/current_floor
echo "Current state:"
examine sim:/elevator_fsm/current_state
echo "Door status:"
examine sim:/elevator_fsm/door_status
echo ""

# Test 2: Request floor 5 while at floor 3
echo "TEST 2: Request floor 5 (should take 2 floors x 20 cycles = 40 cycles)"
force -freeze sim:/elevator_fsm/floor_request 0101 0
force -freeze sim:/elevator_fsm/request_valid 1 0
run 10 ns
force -freeze sim:/elevator_fsm/request_valid 0 0
run 500 ns

echo "Current floor:"
examine sim:/elevator_fsm/current_floor
echo "Current state:"
examine sim:/elevator_fsm/current_state
echo "Pending requests:"
examine sim:/elevator_fsm/pending_requests
echo ""

# Test 3: Request floor 1 (below current position)
echo "TEST 3: Request floor 1 (should go down 4 floors x 20 cycles = 80 cycles)"
force -freeze sim:/elevator_fsm/floor_request 0001 0
force -freeze sim:/elevator_fsm/request_valid 1 0
run 10 ns
force -freeze sim:/elevator_fsm/request_valid 0 0
run 600 ns

echo "Current floor:"
examine sim:/elevator_fsm/current_floor
echo "Current state:"
examine sim:/elevator_fsm/current_state
echo "Direction:"
examine sim:/elevator_fsm/direction
echo ""

# Test 4: Multiple floor requests
echo "TEST 4: Multiple requests - floors 2, 7, 4"
force -freeze sim:/elevator_fsm/floor_request 0010 0
force -freeze sim:/elevator_fsm/request_valid 1 0
run 10 ns
force -freeze sim:/elevator_fsm/request_valid 0 0
run 20 ns

force -freeze sim:/elevator_fsm/floor_request 0111 0
force -freeze sim:/elevator_fsm/request_valid 1 0
run 10 ns
force -freeze sim:/elevator_fsm/request_valid 0 0
run 20 ns

force -freeze sim:/elevator_fsm/floor_request 0100 0
force -freeze sim:/elevator_fsm/request_valid 1 0
run 10 ns
force -freeze sim:/elevator_fsm/request_valid 0 0
run 1000 ns

echo "Pending requests:"
examine sim:/elevator_fsm/pending_requests
echo "Current floor:"
examine sim:/elevator_fsm/current_floor
echo "Target floor:"
examine sim:/elevator_fsm/target_floor
echo ""

# Test 5: Test reset functionality
echo "TEST 5: Testing reset"
force -freeze sim:/elevator_fsm/reset 1 0
run 20 ns
force -freeze sim:/elevator_fsm/reset 0 0
run 50 ns

echo "After reset:"
echo "Current floor:"
examine sim:/elevator_fsm/current_floor
echo "Pending requests:"
examine sim:/elevator_fsm/pending_requests
echo "Current state:"
examine sim:/elevator_fsm/current_state
echo ""

# Test 6: Request same floor elevator is on
echo "TEST 6: Request floor 0 (current floor - door should open immediately)"
force -freeze sim:/elevator_fsm/floor_request 0000 0
force -freeze sim:/elevator_fsm/request_valid 1 0
run 10 ns
force -freeze sim:/elevator_fsm/request_valid 0 0
run 150 ns

echo "Door should open on floor 0:"
examine sim:/elevator_fsm/door_status
echo "Door timer done:"
examine sim:/elevator_fsm/door_timer_done
echo ""

# Test 7: Watch movement timer in action
echo "TEST 7: Request floor 2 to observe movement timer"
force -freeze sim:/elevator_fsm/floor_request 0010 0
force -freeze sim:/elevator_fsm/request_valid 1 0
run 10 ns
force -freeze sim:/elevator_fsm/request_valid 0 0
run 300 ns

echo "Movement timer counter (should cycle for each floor):"
examine sim:/elevator_fsm/move_timer_inst/counter
echo "Current floor:"
examine sim:/elevator_fsm/current_floor
echo ""

echo "============================================================"
echo "Simulation Complete"
echo "============================================================"
echo "Key signals to examine:"
echo "  - N_FLOORS: Number of floors (generic parameter)"
echo "  - MAX_FLOOR: Maximum floor number (N_FLOORS - 1)"
echo "  - current_floor: Current elevator position"
echo "  - current_state: FSM state (IDLE/MV_UP/MV_DN/DOOR_OPEN)"
echo "  - door_status: N_FLOORS-bit vector showing which floor door is open"
echo "  - pending_requests: N_FLOORS-bit vector of requested floors"
echo "  - direction: Current travel direction (UP/DOWN/IDLE)"
echo "  - door_timer_done: Door timer completion signal"
echo "  - move_timer_done: Movement timer completion signal"
echo "  - door_timer_inst/counter: Door timer counter value"
echo "  - move_timer_inst/counter: Movement timer counter value"
echo ""
echo "Expected timing:"
echo "  - Each floor transition: 20 clock cycles (2 seconds)"
echo "  - Door open duration: 20 clock cycles (2 seconds)"
echo "  - Floor 0 to Floor 3: 60 cycles + 20 door = 80 cycles total"
echo ""
echo "To continue simulation: run <time>"
echo "To add more floor requests:"
echo "  force -freeze sim:/elevator_fsm/floor_request <4-bit binary> 0"
echo "  force -freeze sim:/elevator_fsm/request_valid 1 0"
echo "  run 10 ns"
echo "  force -freeze sim:/elevator_fsm/request_valid 0 0"
echo ""
echo "To change number of floors, restart simulation with:"
echo "  vsim -g N_FLOORS=<number> work.elevator_fsm"
echo "============================================================"