LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY elevator_fsm IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    floor_request : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4-bit binary (0-9)
    request_valid : IN STD_LOGIC;
    seven_segment : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    current_floor : OUT INTEGER RANGE 0 TO 9;
    door_status : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
  );
END ENTITY elevator_fsm;

ARCHITECTURE behavioral OF elevator_fsm IS
  -- Pending requests storage, cleared when reset is high
  SIGNAL pending_requests : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');

  TYPE state_type IS (IDLE, MV_UP, MV_DN, DOOR_OPEN);
  SIGNAL current_state, next_state : state_type;

  TYPE direction_type IS (UP, DOWN, IDLE);
  SIGNAL direction : direction_type := IDLE;

  SIGNAL target_floor : INTEGER RANGE 0 TO 9 := 0;
  SIGNAL current_floor_internal : INTEGER RANGE 0 TO 9 := 0;

  -- Timer signals
  SIGNAL timer_reset : STD_LOGIC := '1';
  SIGNAL timer_enable : STD_LOGIC := '0';
  SIGNAL timer_done : STD_LOGIC;

  -- SSD signals
  SIGNAL ssd_binary_in : STD_LOGIC_VECTOR(3 DOWNTO 0);

  -- Timer component declaration
  COMPONENT timer IS
    GENERIC (
      CLOCK_FREQ : INTEGER := 50_000_000;
      DURATION_SEC : INTEGER := 2
    );
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      enable : IN STD_LOGIC;
      done : OUT STD_LOGIC
    );
  END COMPONENT;

  -- SSD component declaration
  COMPONENT ssd IS
    PORT (
      binary_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      ssd_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
  END COMPONENT;

BEGIN
  -- Timer instance
  door_timer_inst : timer
  GENERIC MAP(
    CLOCK_FREQ => 50_000_000,
    DURATION_SEC => 2
  )
  PORT MAP(
    clk => clk,
    reset => timer_reset,
    enable => timer_enable,
    done => timer_done
  );

  -- SSD instance
  ssd_inst : ssd
  PORT MAP(
    binary_in => ssd_binary_in,
    ssd_out => seven_segment
  );

  -- Convert current floor to binary for SSD
  ssd_binary_in <= STD_LOGIC_VECTOR(to_unsigned(current_floor_internal, 4));

  -- Main state machine process
  PROCESS (clk, reset)
    VARIABLE has_above : BOOLEAN;
    VARIABLE has_below : BOOLEAN;
    VARIABLE next_floor : INTEGER RANGE 0 TO 9;
  BEGIN
    IF reset = '1' THEN
      current_state <= IDLE;
      current_floor_internal <= 0;
      target_floor <= 0;
      pending_requests <= (OTHERS => '0');
      timer_reset <= '1';
      timer_enable <= '0';
      direction <= IDLE;
    ELSIF rising_edge(clk) THEN
      current_state <= next_state;

      -- Update pending requests
      IF request_valid = '1' THEN
        IF to_integer(unsigned(floor_request)) <= 9 THEN
          pending_requests(to_integer(unsigned(floor_request))) <= '1';
        END IF;
      END IF;

      -- Clear the request for current floor when door opens and timer is done
      IF current_state = DOOR_OPEN AND timer_done = '1' THEN
        pending_requests(current_floor_internal) <= '0';
      END IF;

      -- Target floor selection logic using SCAN algorithm
      -- Priority: Continue in current direction, then reverse if needed
      IF pending_requests /= "0000000000" THEN
        CASE direction IS
          WHEN UP =>
            -- Look for requests above current floor (continuing upward)
            has_above := FALSE;
            FOR i IN current_floor_internal + 1 TO 9 LOOP
              IF pending_requests(i) = '1' THEN
                target_floor <= i;
                has_above := TRUE;
                EXIT;
              END IF;
            END LOOP;

            -- If no requests above, look below and change direction
            IF NOT has_above THEN
              has_below := FALSE;
              FOR i IN current_floor_internal - 1 DOWNTO 0 LOOP
                IF pending_requests(i) = '1' THEN
                  target_floor <= i;
                  direction <= DOWN;
                  has_below := TRUE;
                  EXIT;
                END IF;
              END LOOP;
            END IF;

          WHEN DOWN =>
            -- Look for requests below current floor (continuing downward)
            has_below := FALSE;
            FOR i IN current_floor_internal - 1 DOWNTO 0 LOOP
              IF pending_requests(i) = '1' THEN
                target_floor <= i;
                has_below := TRUE;
                EXIT;
              END IF;
            END LOOP;

            -- If no requests below, look above and change direction
            IF NOT has_below THEN
              has_above := FALSE;
              FOR i IN current_floor_internal + 1 TO 9 LOOP
                IF pending_requests(i) = '1' THEN
                  target_floor <= i;
                  direction <= UP;
                  has_above := TRUE;
                  EXIT;
                END IF;
              END LOOP;
            END IF;

          WHEN IDLE =>
            -- No direction set, find any request and set initial direction
            FOR i IN 0 TO 9 LOOP
              IF pending_requests(i) = '1' THEN
                target_floor <= i;
                IF i > current_floor_internal THEN
                  direction <= UP;
                ELSIF i < current_floor_internal THEN
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

      -- Movement logic
      CASE current_state IS
        WHEN MV_UP =>
          IF current_floor_internal < target_floor THEN
            current_floor_internal <= current_floor_internal + 1;
          END IF;
          direction <= UP;
        WHEN MV_DN =>
          IF current_floor_internal > target_floor THEN
            current_floor_internal <= current_floor_internal - 1;
          END IF;
          direction <= DOWN;
        WHEN OTHERS =>
          NULL;
      END CASE;

      -- Timer control based on state
      IF current_state = DOOR_OPEN THEN
        timer_reset <= '0';
        timer_enable <= '1';
      ELSE
        timer_reset <= '1';
        timer_enable <= '0';
      END IF;
    END IF;
  END PROCESS;

  -- Next state logic process
  PROCESS (current_state, current_floor_internal, target_floor, timer_done, pending_requests)
  BEGIN
    CASE current_state IS
      WHEN IDLE =>
        IF pending_requests /= "0000000000" THEN
          IF current_floor_internal < target_floor THEN
            next_state <= MV_UP;
          ELSIF current_floor_internal > target_floor THEN
            next_state <= MV_DN;
          ELSIF current_floor_internal = target_floor AND pending_requests(target_floor) = '1' THEN
            next_state <= DOOR_OPEN;
          ELSE
            next_state <= IDLE;
          END IF;
        ELSE
          next_state <= IDLE;
        END IF;

      WHEN MV_UP =>
        IF current_floor_internal = target_floor THEN
          next_state <= DOOR_OPEN;
        ELSE
          next_state <= MV_UP;
        END IF;

      WHEN MV_DN =>
        IF current_floor_internal = target_floor THEN
          next_state <= DOOR_OPEN;
        ELSE
          next_state <= MV_DN;
        END IF;

      WHEN DOOR_OPEN =>
        IF timer_done = '1' THEN
          next_state <= IDLE;
        ELSE
          next_state <= DOOR_OPEN;
        END IF;

      WHEN OTHERS =>
        next_state <= IDLE;
    END CASE;
  END PROCESS;

  -- Output assignments
  current_floor <= current_floor_internal;

  -- Door status assignment process
  PROCESS (current_state, current_floor_internal)
  BEGIN
    door_status <= (OTHERS => '0');
    IF current_state = DOOR_OPEN THEN
      door_status(current_floor_internal) <= '1';
    END IF;
  END PROCESS;

END ARCHITECTURE behavioral;