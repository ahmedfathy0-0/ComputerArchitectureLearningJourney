# Lab 4: Modular Elevator Controller System

## 📁 Project Structure

```
lab4/
├── src/                          # Source files (modular design)
│   ├── elevator_pkg.vhd          # ✨ Common types and constants package
│   ├── request_mgr.vhd           # ✨ Floor request queue manager
│   ├── scan_sched.vhd            # ✨ SCAN algorithm scheduler
│   ├── fsm_ctrl.vhd              # ✨ Main FSM state machine
│   ├── move_ctrl.vhd             # ✨ Movement controller
│   ├── door_ctrl.vhd             # ✨ Door controller
│   ├── elevator_ctrl.vhd         # 🏗️  Top-level structural controller
│   ├── timer.vhd                 # Configurable timer
│   └── ssd.vhd                   # Seven segment display decoder
│
├── test/                         # Testbenches
│   └── elevator_ctrl_tb.vhd      # Comprehensive testbench (13 test cases)
│
├── scripts/                      # Simulation scripts
│   └── run_elevator.do           # ModelSim/QuestaSim script
│
└── work/                         # Compiled library (git ignored)
```

## 🏗️ Modular Architecture

The elevator system is designed with **clean separation of concerns**:

```
┌──────────────────────────────────────────────────────────────┐
│                     elevator_ctrl (Top)                      │
│                   [Structural Architecture]                   │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ request_mgr  │  │ scan_sched   │  │  fsm_ctrl    │      │
│  │              │  │              │  │              │      │
│  │ Add requests │  │ SCAN algo    │  │ State        │      │
│  │ Clear queue  │  │ Target floor │  │ transitions  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐                         │
│  │  move_ctrl   │  │  door_ctrl   │                         │
│  │              │  │              │                         │
│  │ Floor change │  │ Door open/   │                         │
│  │ timing       │  │ close        │                         │
│  └──────────────┘  └──────────────┘                         │
│                                                               │
│  ┌────────┐  ┌────────┐  ┌────────┐                        │
│  │ timer  │  │ timer  │  │  ssd   │                        │
│  │ (door) │  │ (move) │  │(display)│                        │
│  └────────┘  └────────┘  └────────┘                        │
└──────────────────────────────────────────────────────────────┘
```

## 📦 Component Descriptions

### 1. **elevator_pkg.vhd** (Package)

```vhdl
TYPE state_type IS (IDLE, MV_UP, MV_DN, DOOR_OPEN);
TYPE direction_type IS (UP, DOWN, IDLE);
```

- Shared types and constants
- Used by all components
- Single source of truth

### 2. **request_mgr.vhd** (Request Manager)

**Purpose**: Manages the queue of pending floor requests

**Inputs**:

- `floor_request`: 4-bit floor number
- `request_valid`: Pulse to add request
- `clear_floor`: Floor to clear
- `clear_request`: Pulse to clear

**Outputs**:

- `pending_requests`: 10-bit vector of pending floors

**Features**:

- Adds new requests to queue
- Clears serviced requests
- Reset clears all requests

### 3. **scan_sched.vhd** (SCAN Scheduler)

**Purpose**: Implements SCAN disk scheduling algorithm

**Inputs**:

- `current_floor`: Current position
- `pending_requests`: Queue from request_mgr
- `direction`: Current/updated direction (INOUT)

**Outputs**:

- `target_floor`: Next floor to visit

**Algorithm**:

- **Going UP**: Service all requests above, then reverse
- **Going DOWN**: Service all requests below, then reverse
- **IDLE**: Find first request, set direction

### 4. **fsm_ctrl.vhd** (FSM Controller)

**Purpose**: Main state machine logic

**States**:

- **IDLE**: Waiting for requests
- **MV_UP**: Moving upward
- **MV_DN**: Moving downward
- **DOOR_OPEN**: Door open for passengers

**Inputs**: Current floor, target, pending requests, timer status

**Outputs**: Current state, next state

### 5. **move_ctrl.vhd** (Movement Controller)

**Purpose**: Controls floor transitions

**Features**:

- Starts movement timer
- Increments/decrements floor on timer done
- Resets timer for next floor
- Only active in MV_UP/MV_DN states

### 6. **door_ctrl.vhd** (Door Controller)

**Purpose**: Manages door operations

**Features**:

- Starts door timer in DOOR_OPEN state
- Signals when request is cleared
- Sets door_status bit vector
- Resets timer when leaving DOOR_OPEN

### 7. **elevator_ctrl.vhd** (Top Level)

**Architecture**: **Structural** (not behavioral!)

**Purpose**: Integrates all subsystems

**Features**:

- Component instantiations only
- Signal routing between modules
- No behavioral logic
- Clean, maintainable design

## 🚀 Running the Simulation

### From lab4 directory:

```bash
cd lab4

# Run with GUI
vsim -do scripts/run_elevator.do

# Or batch mode
vsim -c -do "source scripts/run_elevator.do; quit -f"
```

## 🧪 Test Cases

The testbench (`elevator_ctrl_tb.vhd`) includes **13 comprehensive test cases**:

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

Each test includes **PASS/FAIL** reporting!

## 📊 Advantages of Modular Design

### Before (Monolithic):

```
❌ Single 300+ line file
❌ All logic mixed together
❌ Hard to test individual parts
❌ Difficult to modify
❌ Poor reusability
```

### After (Modular):

```
✅ 9 focused files (50-100 lines each)
✅ Clear separation of concerns
✅ Easy to test each component
✅ Simple to modify/extend
✅ Components are reusable
✅ Structural top-level design
```

## 🔍 Key Benefits

1. **Maintainability**

   - Each file has single responsibility
   - Changes localized to one component
   - Easy to understand and debug

2. **Testability**

   - Can test SCAN scheduler independently
   - Can verify request manager separately
   - Integration testing at top level

3. **Scalability**

   - Easy to add express floors
   - Simple to add priority requests
   - Can extend to multiple elevators

4. **Reusability**

   - request_mgr can be used in other queue systems
   - scan_sched useful for disk scheduling
   - timer component general purpose

5. **Readability**
   - Clear component names
   - Well-documented interfaces
   - Structural architecture shows connections

## 🎯 Design Patterns Used

### 1. **Separation of Concerns**

Each component handles one aspect:

- Request management
- Scheduling
- State machine
- Movement
- Door control

### 2. **Structural Architecture**

Top-level uses **structural** not behavioral:

- Component instantiations
- Signal routing
- No processes at top level
- Clean hierarchy

### 3. **Package for Common Types**

- Single definition of types
- Shared across all components
- Easy to maintain

## 📝 Compilation Order

**Important**: Dependencies must be compiled first!

```
1. elevator_pkg.vhd       (types - no dependencies)
2. timer.vhd              (basic component)
3. ssd.vhd                (basic component)
4. request_mgr.vhd        (uses elevator_pkg)
5. scan_sched.vhd         (uses elevator_pkg)
6. fsm_ctrl.vhd           (uses elevator_pkg)
7. move_ctrl.vhd          (uses elevator_pkg)
8. door_ctrl.vhd          (uses elevator_pkg)
9. elevator_ctrl.vhd      (uses all above)
10. elevator_ctrl_tb.vhd  (testbench)
```

The `run_elevator.do` script handles this automatically!

## 🔧 Configuration

### Timer Settings:

- **Production**: 50 MHz clock, 2 second duration
- **Simulation**: Override with 10 Hz for fast testing (via configuration)

### Generic Parameters:

- `N_FLOORS`: Number of floors (default: 10, floors 0-9)
- Easily scalable

## 💡 Tips for Extension

Want to add new features? Here's where to look:

- **Add priority requests**: Modify `scan_sched.vhd`
- **Add express mode**: Add new state in `fsm_ctrl.vhd`
- **Add floor sensors**: Extend `move_ctrl.vhd`
- **Add emergency stop**: Add signal to top level
- **Add multiple elevators**: Instantiate multiple `elevator_ctrl`

## 📚 Learning Outcomes

This modular design demonstrates:

- ✅ VHDL structural architecture
- ✅ Component-based design
- ✅ Package usage for shared types
- ✅ Separation of concerns
- ✅ Hierarchical design
- ✅ Clean interfaces
- ✅ Professional VHDL practices

---

**Note**: This is a complete refactoring of the original monolithic design into a clean, professional, modular architecture suitable for real-world FPGA projects!
