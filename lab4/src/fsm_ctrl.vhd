-- ============================================================
-- Entity: fsm_ctrl
-- Description: Main finite state machine for elevator control
-- ============================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.elevator_pkg.ALL;

ENTITY fsm_ctrl IS
  GENERIC (
    N_FLOORS : INTEGER := 10
  );
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    current_floor : IN INTEGER RANGE 0 TO 9;
    target_floor : IN INTEGER RANGE 0 TO 9;
    direction : IN direction_type;
    pending_requests : IN STD_LOGIC_VECTOR(N_FLOORS - 1 DOWNTO 0);
    door_timer_done : IN STD_LOGIC;
    move_timer_done : IN STD_LOGIC;
    current_state : OUT state_type;
    next_state : OUT state_type
  );
END ENTITY fsm_ctrl;

ARCHITECTURE rtl OF fsm_ctrl IS
  SIGNAL current_state_internal : state_type;
  SIGNAL next_state_internal : state_type;
BEGIN
  
  current_state <= current_state_internal;
  next_state <= next_state_internal;
  
  -- State register
  PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      current_state_internal <= IDLE;
    ELSIF rising_edge(clk) THEN
      current_state_internal <= next_state_internal;
    END IF;
  END PROCESS;
  
  -- Next state logic
  PROCESS (current_state_internal, current_floor, target_floor, door_timer_done, 
           move_timer_done, pending_requests)
  BEGIN
    CASE current_state_internal IS
      WHEN IDLE =>
        IF pending_requests /= (pending_requests'RANGE => '0') THEN
          IF current_floor < target_floor THEN
            next_state_internal <= MV_UP;
          ELSIF current_floor > target_floor THEN
            next_state_internal <= MV_DN;
          ELSIF current_floor = target_floor AND pending_requests(target_floor) = '1' THEN
            next_state_internal <= DOOR_OPEN;
          ELSE
            next_state_internal <= IDLE;
          END IF;
        ELSE
          next_state_internal <= IDLE;
        END IF;

      WHEN MV_UP =>
        IF move_timer_done = '1' AND (current_floor + 1) = target_floor THEN
          next_state_internal <= DOOR_OPEN;
        ELSE
          next_state_internal <= MV_UP;
        END IF;

      WHEN MV_DN =>
        IF move_timer_done = '1' AND (current_floor - 1) = target_floor THEN
          next_state_internal <= DOOR_OPEN;
        ELSE
          next_state_internal <= MV_DN;
        END IF;

      WHEN DOOR_OPEN =>
        IF door_timer_done = '1' THEN
          next_state_internal <= IDLE;
        ELSE
          next_state_internal <= DOOR_OPEN;
        END IF;

      WHEN OTHERS =>
        next_state_internal <= IDLE;
    END CASE;
  END PROCESS;
  
END ARCHITECTURE rtl;
