-- ============================================================
-- Entity: request_mgr
-- Description: Manages pending floor requests
-- ============================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY request_mgr IS
  GENERIC (
    N_FLOORS : INTEGER := 10
  );
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    floor_request : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    request_valid : IN STD_LOGIC;
    clear_floor : IN INTEGER RANGE 0 TO 9;
    clear_request : IN STD_LOGIC;
    pending_requests : OUT STD_LOGIC_VECTOR(N_FLOORS - 1 DOWNTO 0)
  );
END ENTITY request_mgr;

ARCHITECTURE rtl OF request_mgr IS
  CONSTANT MAX_FLOOR : INTEGER := N_FLOORS - 1;
  SIGNAL pending_requests_internal : STD_LOGIC_VECTOR(N_FLOORS - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN
  
  pending_requests <= pending_requests_internal;
  
  PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      pending_requests_internal <= (OTHERS => '0');
    ELSIF rising_edge(clk) THEN
      
      -- Add new request
      IF request_valid = '1' THEN
        IF to_integer(unsigned(floor_request)) <= MAX_FLOOR THEN
          pending_requests_internal(to_integer(unsigned(floor_request))) <= '1';
        END IF;
      END IF;

      -- Clear serviced request
      IF clear_request = '1' THEN
        pending_requests_internal(clear_floor) <= '0';
      END IF;
      
    END IF;
  END PROCESS;
  
END ARCHITECTURE rtl;
