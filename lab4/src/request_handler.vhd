LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- Request Handler for Elevator Controller
-- Manages floor requests and determines next target floor
-- Continues in current direction until no more requests
-- When next_floor = current_floor, it means no pending requests (IDLE)
-- 
-- Input handling:
-- - floor_select: 4-bit binary input from switches (0000-1001 for floors 0-9)
-- - request_button: Push button to register the floor request (asynchronous)
-- - Reset only clears pending requests, doesn't affect current operation

ENTITY Request_handler IS
  GENERIC (N : INTEGER := 9); -- Maximum floor number (0 to N)
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    floor_select : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Binary floor selection (0-9)
    request_button : IN STD_LOGIC; -- Push button to register request
    current_floor : IN INTEGER RANGE 0 TO N; -- Current elevator position
    clear_request : IN STD_LOGIC; -- Pulse to clear current floor request

    next_floor : OUT INTEGER RANGE 0 TO N -- Next target floor
  );
END ENTITY Request_handler;

ARCHITECTURE behavior OF Request_handler IS
  -- Store pending requests for each floor
  SIGNAL pending_requests : STD_LOGIC_VECTOR(N DOWNTO 0) := (OTHERS => '0');

  -- Button synchronization and edge detection
  SIGNAL button_sync : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
  SIGNAL button_pressed : STD_LOGIC := '0'; -- Rising edge detected

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

  -- Button synchronizer and edge detector
  button_sync_proc : PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      button_sync <= button_sync(1 DOWNTO 0) & request_button;
    END IF;
  END PROCESS;

  -- Detect rising edge of synchronized button
  button_pressed <= '1' WHEN button_sync(2 DOWNTO 1) = "01" ELSE
    '0';

  -- Sequential Process: Store requests and maintain direction state
  request_storage : PROCESS (clk, reset)
    VARIABLE requested_floor : INTEGER RANGE 0 TO N;
  BEGIN
    IF reset = '1' THEN
      -- Reset clears pending requests and returns direction to IDLE
      pending_requests <= (OTHERS => '0');
      direction <= IDLE;

    ELSIF rising_edge(clk) THEN
      -- Step 1: Register new floor request when button is pressed
      IF button_pressed = '1' THEN
        -- Convert 4-bit binary input to integer
        requested_floor := to_integer(unsigned(floor_select));
        -- Only register if valid floor number
        IF requested_floor <= N THEN
          pending_requests(requested_floor) <= '1';
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