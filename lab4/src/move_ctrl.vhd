-- ============================================================
-- Entity: move_ctrl
-- Description: Controls elevator movement between floors
-- ============================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.elevator_pkg.ALL;

ENTITY move_ctrl IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    current_state : IN state_type;
    move_timer_done : IN STD_LOGIC;
    move_timer_reset : OUT STD_LOGIC;
    move_timer_enable : OUT STD_LOGIC;
    current_floor : INOUT INTEGER RANGE 0 TO 9
  );
END ENTITY move_ctrl;

ARCHITECTURE rtl OF move_ctrl IS
  SIGNAL timer_reset_internal : STD_LOGIC := '1';
  SIGNAL timer_enable_internal : STD_LOGIC := '0';
BEGIN
  
  move_timer_reset <= timer_reset_internal;
  move_timer_enable <= timer_enable_internal;
  
  PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      timer_reset_internal <= '1';
      timer_enable_internal <= '0';
    ELSIF rising_edge(clk) THEN
      
      CASE current_state IS
        WHEN MV_UP =>
          -- Start timer when entering movement state
          IF timer_enable_internal = '0' THEN
            timer_reset_internal <= '0';
            timer_enable_internal <= '1';
          ELSIF move_timer_done = '1' THEN
            current_floor <= current_floor + 1;
            timer_reset_internal <= '1';
            timer_enable_internal <= '0';
          END IF;

        WHEN MV_DN =>
          -- Start timer when entering movement state
          IF timer_enable_internal = '0' THEN
            timer_reset_internal <= '0';
            timer_enable_internal <= '1';
          ELSIF move_timer_done = '1' THEN
            current_floor <= current_floor - 1;
            timer_reset_internal <= '1';
            timer_enable_internal <= '0';
          END IF;

        WHEN OTHERS =>
          timer_reset_internal <= '1';
          timer_enable_internal <= '0';
      END CASE;
      
    END IF;
  END PROCESS;
  
END ARCHITECTURE rtl;
