# Lab 4: Elevator Controller System

## 📁 Project Structure

```
lab4/
├── src/                          # Source files
│   ├── elevator_types.vhd        # Common types and constants package
│   ├── request_manager.vhd       # Floor request queue manager
│   ├── scan_scheduler.vhd        # SCAN algorithm scheduler
│   ├── elevator_fsm_refactored.vhd  # Main FSM controller (NEW modular version)
│   ├── elevator_fsm.vhd          # Original FSM (kept for reference)
│   ├── timer.vhd                 # Configurable timer
│   └── ssd.vhd                   # Seven segment display decoder
│
├── test/                         # Testbenches
│   └── tb_elevator_fsm.vhd       # Comprehensive testbench (13 test cases)
│
├── scripts/                      # Simulation scripts
│   └── run_tb_elevator_fsm.do    # ModelSim/QuestaSim script
│
└── work/                         # Compiled library (git ignored)
```

## 🏗️ Architecture Overview

### Modular Design

The elevator system has been refactored into clean, modular components:

```
┌─────────────────────────────────────────────────────┐
│              elevator_fsm_refactored                │
│                 (Main Controller)                    │
│                                                      │
│  ┌────────────────┐  ┌──────────────────┐          │
│  │ request_manager│  │ scan_scheduler   │          │
│  │  - Queue mgmt  │  │  - SCAN algorithm│          │
│  │  - Add/Clear   │  │  - Target select │          │
│  └────────────────┘  └──────────────────┘          │
│                                                      │
│  ┌───────────┐  ┌───────────┐  ┌──────────┐       │
│  │door_timer │  │move_timer │  │   ssd    │       │
│  │ - 2 sec   │  │ - 2 sec   │  │ - Display│       │
│  └───────────┘  └───────────┘  └──────────┘       │
└─────────────────────────────────────────────────────┘
```

### Component Descriptions

#### 1. **elevator_types.vhd** (Package)
- Common type definitions (state_type, direction_type)
- System constants
- Shared across all components

#### 2. **request_manager.vhd**
- **Purpose**: Manages pending floor requests
- **Inputs**: 
  - `floor_request`: New request to add
  - `request_valid`: Signal to add request
  - `clear_floor`: Floor to clear
  - `clear_request`: Signal to clear request
- **Outputs**: 
  - `pending_requests`: Bit vector of pending floors

#### 3. **scan_scheduler.vhd**
- **Purpose**: Implements SCAN disk scheduling algorithm
- **Inputs**: 
  - `current_floor`: Current elevator position
  - `pending_requests`: Queue of requests
  - `direction`: Current movement direction (INOUT)
- **Outputs**: 
  - `target_floor`: Next floor to visit
  - `direction`: Updated direction

#### 4. **elevator_fsm_refactored.vhd**
- **Purpose**: Main state machine controller
- **States**: IDLE, MV_UP, MV_DN, DOOR_OPEN
- **Coordinates**: All subsystems
- **Cleaner than original**: 
  - Separated concerns
  - Better organized processes
  - Clear signal naming
  - Modular instantiations

## 🚀 Running the Simulation

### From lab4 directory:

```bash
# Change to lab4 directory
cd lab4

# Run simulation with GUI
vsim -do scripts/run_tb_elevator_fsm.do

# Or run in batch mode (no GUI)
vsim -c -do "source scripts/run_tb_elevator_fsm.do; quit -f"
```

## 🧪 Test Cases

The testbench includes **13 comprehensive test cases**:

1. ✅ Basic floor request (floor 3)
2. ✅ Upward movement (floor 5)
3. ✅ Downward movement (floor 1)
4. ✅ Multiple requests (SCAN algorithm)
5. ✅ Reset functionality
6. ✅ Same floor request (immediate door open)
7. ✅ Movement timer observation
8. ✅ **SCAN with intermediate requests** (3→5→9→1)
9. ✅ Same floor while idle
10. ✅ Boundary floors (0 and 9)
11. ✅ Rapid multiple requests
12. ✅ Request during door open
13. ✅ Idempotent requests (duplicate handling)

## 📊 Improvements Over Original

### Original elevator_fsm.vhd:
- ❌ ~318 lines in one file
- ❌ SCAN logic mixed with FSM logic
- ❌ Request management in main process
- ❌ Hard to maintain and test individual parts

### New elevator_fsm_refactored.vhd:
- ✅ ~230 lines, but uses modular components
- ✅ SCAN logic isolated in scan_scheduler
- ✅ Request management in separate component
- ✅ Easy to test, modify, and understand
- ✅ Clear separation of concerns
- ✅ Better code organization
- ✅ Reusable components

## 🔧 Configuration

### Timer Settings:
- **Production**: 50 MHz clock, 2 second duration
- **Simulation**: Override with 10 Hz for fast testing

### Generic Parameters:
- `N_FLOORS`: Number of floors (default: 10)
- Easily scalable to different building sizes

## 📝 Notes

- The original `elevator_fsm.vhd` is kept for reference
- Use `elevator_fsm_refactored.vhd` for the modular version
- All `work/` directories are git ignored
- Run scripts from `lab4/` directory for correct paths

## 🎯 Key Benefits

1. **Modularity**: Each component has single responsibility
2. **Testability**: Can test SCAN scheduler independently
3. **Maintainability**: Changes localized to specific files
4. **Readability**: Clear structure, well-documented
5. **Scalability**: Easy to add features (e.g., express floors)
6. **Reusability**: Components can be used in other projects
