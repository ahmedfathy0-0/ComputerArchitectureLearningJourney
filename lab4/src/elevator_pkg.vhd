-- ============================================================
-- Package: elevator_pkg
-- Description: Common types and constants for elevator system
-- ============================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE elevator_pkg IS
  -- State machine types
  TYPE state_type IS (IDLE, MV_UP, MV_DN, DOOR_OPEN);
  TYPE direction_type IS (UP, DOWN, IDLE);
  
  -- Constants
  CONSTANT N_FLOORS_DEFAULT : INTEGER := 10;
  CONSTANT CLOCK_FREQ_DEFAULT : INTEGER := 50_000_000;
  CONSTANT DOOR_DURATION_SEC : INTEGER := 2;
  CONSTANT MOVE_DURATION_SEC : INTEGER := 2;
  
END PACKAGE elevator_pkg;
