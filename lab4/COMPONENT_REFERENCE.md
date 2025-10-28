# Modular Elevator Controller - File Reference

## Quick Component Overview

| Component           | File                    | Lines    | Purpose                    |
| ------------------- | ----------------------- | -------- | -------------------------- |
| Package             | `elevator_pkg.vhd`      | ~20      | Common types & constants   |
| Request Manager     | `request_mgr.vhd`       | ~60      | Queue management           |
| SCAN Scheduler      | `scan_sched.vhd`        | ~110     | SCAN algorithm             |
| FSM Controller      | `fsm_ctrl.vhd`          | ~95      | State machine              |
| Movement Controller | `move_ctrl.vhd`         | ~70      | Floor transitions          |
| Door Controller     | `door_ctrl.vhd`         | ~75      | Door operations            |
| **Top Level**       | **`elevator_ctrl.vhd`** | **~165** | **Structural integration** |
| Timer               | `timer.vhd`             | ~50      | Timing control             |
| Display             | `ssd.vhd`               | ~40      | Seven segment              |

**Total modular code**: ~685 lines vs ~318 monolithic lines
**But**: Much cleaner, testable, and maintainable!

## Signal Flow

```
User Input (floor_request, request_valid)
    ↓
[request_mgr] → pending_requests
    ↓
[scan_sched] → target_floor, direction
    ↓
[fsm_ctrl] → current_state, next_state
    ↓        ↓
[move_ctrl]  [door_ctrl]
    ↓            ↓
current_floor   door_status
    ↓            ↓
  [ssd]      User Output
    ↓
seven_segment
```

## Component Interfaces

### request_mgr

```vhdl
IN:  floor_request, request_valid, clear_floor, clear_request
OUT: pending_requests
```

### scan_sched

```vhdl
IN:    current_floor, pending_requests
INOUT: direction
OUT:   target_floor
```

### fsm_ctrl

```vhdl
IN:  current_floor, target_floor, direction, pending_requests,
     door_timer_done, move_timer_done
OUT: current_state, next_state
```

### move_ctrl

```vhdl
IN:    current_state, move_timer_done
OUT:   move_timer_reset, move_timer_enable
INOUT: current_floor
```

### door_ctrl

```vhdl
IN:  current_state, current_floor, door_timer_done
OUT: door_timer_reset, door_timer_enable, door_status, request_cleared
```

## Running Tests

```bash
# From lab4 directory
cd /path/to/lab4

# Compile and run
vsim -do scripts/run_elevator.do

# Or just compile
vcom -93 src/elevator_pkg.vhd
vcom -93 src/timer.vhd
vcom -93 src/ssd.vhd
vcom -93 src/request_mgr.vhd
vcom -93 src/scan_sched.vhd
vcom -93 src/fsm_ctrl.vhd
vcom -93 src/move_ctrl.vhd
vcom -93 src/door_ctrl.vhd
vcom -93 src/elevator_ctrl.vhd
vcom -93 test/elevator_ctrl_tb.vhd
```

## Modification Guide

### To add a new feature:

1. **Identify affected component(s)**

   - Need new scheduling? → `scan_sched.vhd`
   - New state? → `fsm_ctrl.vhd`
   - New timer? → Add component, wire in `elevator_ctrl.vhd`

2. **Update package if needed**

   - New state type? → `elevator_pkg.vhd`
   - New constants? → `elevator_pkg.vhd`

3. **Update top-level if new signals**

   - Add signal declaration
   - Route between components
   - Update port maps

4. **Update testbench**
   - Add test case
   - Verify new behavior

### Example: Adding Emergency Stop

1. Add to `elevator_pkg.vhd`:

   ```vhdl
   TYPE state_type IS (IDLE, MV_UP, MV_DN, DOOR_OPEN, EMERGENCY);
   ```

2. Add port to `elevator_ctrl.vhd`:

   ```vhdl
   emergency_stop : IN STD_LOGIC;
   ```

3. Update `fsm_ctrl.vhd`:

   ```vhdl
   IF emergency_stop = '1' THEN
     next_state_internal <= EMERGENCY;
   ```

4. Test with new test case!

## Design Philosophy

✅ **One File, One Purpose**

- Each file has single responsibility
- Clear, focused functionality

✅ **Interface-Driven Design**

- Well-defined component interfaces
- Minimal coupling between modules

✅ **Structural Top-Level**

- No behavioral logic at top
- Only wiring and instantiation
- Clear system overview

✅ **Testability First**

- Each component can be tested alone
- Integration testing at top level
- PASS/FAIL for every assertion

✅ **Professional Practices**

- Consistent naming conventions
- Comprehensive comments
- Clean code structure
