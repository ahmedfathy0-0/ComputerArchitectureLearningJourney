-- ============================================================
-- Entity: scan_sched
-- Description: SCAN algorithm scheduler for elevator requests
-- ============================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.elevator_pkg.ALL;

ENTITY scan_sched IS
  GENERIC (
    N_FLOORS : INTEGER := 10
  );
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    current_floor : IN INTEGER RANGE 0 TO 9;
    pending_requests : IN STD_LOGIC_VECTOR(N_FLOORS - 1 DOWNTO 0);
    direction : INOUT direction_type;
    target_floor : OUT INTEGER RANGE 0 TO 9
  );
END ENTITY scan_sched;

ARCHITECTURE rtl OF scan_sched IS
  CONSTANT MAX_FLOOR : INTEGER := N_FLOORS - 1;
BEGIN
  
  PROCESS (clk, reset)
    VARIABLE has_above : BOOLEAN;
    VARIABLE has_below : BOOLEAN;
  BEGIN
    IF reset = '1' THEN
      target_floor <= 0;
    ELSIF rising_edge(clk) THEN
      
      -- Target floor selection logic using SCAN algorithm
      IF pending_requests /= (pending_requests'RANGE => '0') THEN
        CASE direction IS
          WHEN UP =>
            -- Look for requests above current floor
            has_above := FALSE;
            FOR i IN 0 TO MAX_FLOOR LOOP
              IF i > current_floor AND pending_requests(i) = '1' AND NOT has_above THEN
                target_floor <= i;
                has_above := TRUE;
              END IF;
            END LOOP;

            -- If no requests above, look below and change direction
            IF NOT has_above THEN
              has_below := FALSE;
              FOR i IN 0 TO MAX_FLOOR LOOP
                IF i < current_floor AND pending_requests(MAX_FLOOR - i) = '1' AND NOT has_below THEN
                  target_floor <= MAX_FLOOR - i;
                  direction <= DOWN;
                  has_below := TRUE;
                END IF;
              END LOOP;
            END IF;

          WHEN DOWN =>
            -- Look for requests below current floor
            has_below := FALSE;
            FOR i IN 0 TO MAX_FLOOR LOOP
              IF i < current_floor AND pending_requests(current_floor - 1 - i) = '1' AND NOT has_below THEN
                target_floor <= current_floor - 1 - i;
                has_below := TRUE;
              END IF;
            END LOOP;

            -- If no requests below, look above and change direction
            IF NOT has_below THEN
              has_above := FALSE;
              FOR i IN 0 TO MAX_FLOOR LOOP
                IF i > current_floor AND pending_requests(i) = '1' AND NOT has_above THEN
                  target_floor <= i;
                  direction <= UP;
                  has_above := TRUE;
                END IF;
              END LOOP;
            END IF;

          WHEN IDLE =>
            -- No direction set, find any request and set initial direction
            FOR i IN 0 TO MAX_FLOOR LOOP
              IF pending_requests(i) = '1' THEN
                target_floor <= i;
                IF i > current_floor THEN
                  direction <= UP;
                ELSIF i < current_floor THEN
                  direction <= DOWN;
                END IF;
                EXIT;
              END IF;
            END LOOP;
        END CASE;
      ELSE
        -- No pending requests, set direction to IDLE
        direction <= IDLE;
      END IF;
      
    END IF;
  END PROCESS;
  
END ARCHITECTURE rtl;
