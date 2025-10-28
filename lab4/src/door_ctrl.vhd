-- ============================================================
-- Entity: door_ctrl
-- Description: Controls elevator door operations
-- ============================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.elevator_pkg.ALL;

ENTITY door_ctrl IS
  GENERIC (
    N_FLOORS : INTEGER := 10
  );
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    current_state : IN state_type;
    current_floor : IN INTEGER RANGE 0 TO 9;
    door_timer_done : IN STD_LOGIC;
    door_timer_reset : OUT STD_LOGIC;
    door_timer_enable : OUT STD_LOGIC;
    door_status : OUT STD_LOGIC_VECTOR(N_FLOORS - 1 DOWNTO 0);
    request_cleared : OUT STD_LOGIC
  );
END ENTITY door_ctrl;

ARCHITECTURE rtl OF door_ctrl IS
  SIGNAL timer_reset_internal : STD_LOGIC := '1';
  SIGNAL timer_enable_internal : STD_LOGIC := '0';
BEGIN
  
  door_timer_reset <= timer_reset_internal;
  door_timer_enable <= timer_enable_internal;
  
  PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      timer_reset_internal <= '1';
      timer_enable_internal <= '0';
      request_cleared <= '0';
    ELSIF rising_edge(clk) THEN
      
      -- Signal when door cycle completes to clear request
      IF current_state = DOOR_OPEN AND door_timer_done = '1' THEN
        request_cleared <= '1';
      ELSE
        request_cleared <= '0';
      END IF;
      
      -- Door timer control
      IF current_state = DOOR_OPEN THEN
        timer_reset_internal <= '0';
        timer_enable_internal <= '1';
      ELSE
        timer_reset_internal <= '1';
        timer_enable_internal <= '0';
      END IF;
      
    END IF;
  END PROCESS;
  
  -- Door status output (combinational)
  PROCESS (current_state, current_floor)
  BEGIN
    door_status <= (OTHERS => '0');
    IF current_state = DOOR_OPEN THEN
      door_status(current_floor) <= '1';
    END IF;
  END PROCESS;
  
END ARCHITECTURE rtl;
