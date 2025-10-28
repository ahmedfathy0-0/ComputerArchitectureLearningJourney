LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- Request Handler for Elevator Controller
-- Manages floor requests and determines next target floor using SCAN algorithm
-- Continues in current direction until no more requests
-- When next_floor = current_floor, it means no pending requests (IDLE)
-- 
-- Input handling:
-- - floor_request: Single pulse indicating a valid floor request
-- - floor_number: Integer representing the requested floor (0-9)
-- - Reset only clears pending requests, doesn't affect current operation

ENTITY Request_handler IS
  GENERIC (N : INTEGER := 9); -- Maximum floor number (0 to N)
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    floor_request : IN STD_LOGIC; -- Single pulse for valid floor request
    floor_number : IN INTEGER RANGE 0 TO N; -- Requested floor number
    current_floor : IN INTEGER RANGE 0 TO N; -- Current elevator position
    clear_request : IN STD_LOGIC; -- Pulse to clear current floor request

    next_floor : OUT INTEGER RANGE 0 TO N -- Next target floor
  );
END ENTITY Request_handler;

ARCHITECTURE behavior OF Request_handler IS
  -- Store pending requests for each floor
  SIGNAL pending_requests : STD_LOGIC_VECTOR(N DOWNTO 0) := (OTHERS => '0');

  -- Direction state
  TYPE direction_type IS (UP, DOWN, IDLE);
  SIGNAL direction : direction_type := IDLE;

  -- Helper function: Check if there are any requests above current floor
  FUNCTION has_requests_above(
    requests : STD_LOGIC_VECTOR;
    curr_floor : INTEGER;
    max_floor : INTEGER
  ) RETURN BOOLEAN IS
  BEGIN
    FOR i IN curr_floor + 1 TO max_floor LOOP
      IF requests(i) = '1' THEN
        RETURN TRUE;
      END IF;
    END LOOP;
    RETURN FALSE;
  END FUNCTION;

  -- Helper function: Check if there are any requests below current floor
  FUNCTION has_requests_below(
    requests : STD_LOGIC_VECTOR;
    curr_floor : INTEGER
  ) RETURN BOOLEAN IS
  BEGIN
    FOR i IN 0 TO curr_floor - 1 LOOP
      IF requests(i) = '1' THEN
        RETURN TRUE;
      END IF;
    END LOOP;
    RETURN FALSE;
  END FUNCTION;

BEGIN

  -- Sequential Process: Store requests and maintain direction state
  request_storage : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      -- Reset clears pending requests and returns direction to IDLE
      pending_requests <= (OTHERS => '0');
      direction <= IDLE;

    ELSIF rising_edge(clk) THEN
      -- Step 1: Register new floor request
      IF floor_request = '1' THEN
        -- Register the requested floor
        IF floor_number <= N THEN
          pending_requests(floor_number) <= '1';
        END IF;
      END IF;

      -- Step 2: Clear request when floor is served
      IF clear_request = '1' THEN
        pending_requests(current_floor) <= '0';
      END IF;

      -- Step 3: Update direction based on SCAN algorithm
      IF pending_requests = (N DOWNTO 0 => '0') THEN
        -- No requests at all
        direction <= IDLE;

      ELSIF direction = IDLE THEN
        -- Starting from idle: prefer going up first
        IF has_requests_above(pending_requests, current_floor, N) THEN
          direction <= UP;
        ELSIF has_requests_below(pending_requests, current_floor) THEN
          direction <= DOWN;
        END IF;

      ELSIF direction = UP THEN
        -- Continue up if possible, otherwise reverse to down
        IF NOT has_requests_above(pending_requests, current_floor, N) THEN
          IF has_requests_below(pending_requests, current_floor) THEN
            direction <= DOWN;
          ELSE
            direction <= IDLE;
          END IF;
        END IF;

      ELSIF direction = DOWN THEN
        -- Continue down if possible, otherwise reverse to up
        IF NOT has_requests_below(pending_requests, current_floor) THEN
          IF has_requests_above(pending_requests, current_floor, N) THEN
            direction <= UP;
          ELSE
            direction <= IDLE;
          END IF;
        END IF;
      END IF;
    END IF;
  END PROCESS;

  -- Combinational Process: Calculate next floor
  next_floor_calc : PROCESS (pending_requests, current_floor, direction)
    VARIABLE next_floor_temp : INTEGER RANGE 0 TO N;
    VARIABLE found : BOOLEAN;
  BEGIN
    -- Default: stay at current floor (indicates no requests)
    next_floor_temp := current_floor;
    found := FALSE;

    CASE direction IS
      WHEN UP =>
        -- Find closest request above current floor
        FOR i IN current_floor + 1 TO N LOOP
          IF pending_requests(i) = '1' AND NOT found THEN
            next_floor_temp := i;
            found := TRUE;
          END IF;
        END LOOP;

      WHEN DOWN =>
        -- Find closest request below current floor
        FOR i IN current_floor - 1 DOWNTO 0 LOOP
          IF pending_requests(i) = '1' AND NOT found THEN
            next_floor_temp := i;
            found := TRUE;
          END IF;
        END LOOP;

      WHEN IDLE =>
        -- Check upwards first
        FOR i IN current_floor + 1 TO N LOOP
          IF pending_requests(i) = '1' AND NOT found THEN
            next_floor_temp := i;
            found := TRUE;
          END IF;
        END LOOP;

        -- If nothing above, check downwards
        IF NOT found THEN
          FOR i IN current_floor - 1 DOWNTO 0 LOOP
            IF pending_requests(i) = '1' AND NOT found THEN
              next_floor_temp := i;
              found := TRUE;
            END IF;
          END LOOP;
        END IF;
    END CASE;

    next_floor <= next_floor_temp;
  END PROCESS;

END ARCHITECTURE behavior;