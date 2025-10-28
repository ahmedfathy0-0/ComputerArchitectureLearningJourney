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

  -- Door timer signals
  SIGNAL door_timer_reset : STD_LOGIC := '1';
  SIGNAL door_timer_enable : STD_LOGIC := '0';
  SIGNAL door_timer_done : STD_LOGIC;

  -- Movement timer signals
  SIGNAL move_timer_reset : STD_LOGIC := '1';
  SIGNAL move_timer_enable : STD_LOGIC := '0';
  SIGNAL move_timer_done : STD_LOGIC;

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
  -- Door timer instance (2 seconds for door open)
  door_timer_inst : timer
  GENERIC MAP(
    CLOCK_FREQ => 50_000_000,
    DURATION_SEC => 2
  )
  PORT MAP(
    clk => clk,
    reset => door_timer_reset,
    enable => door_timer_enable,
    done => door_timer_done
  );

  -- Movement timer instance (2 seconds between floors)
  move_timer_inst : timer
  GENERIC MAP(
    CLOCK_FREQ => 50_000_000,
    DURATION_SEC => 2
  )
  PORT MAP(
    clk => clk,
    reset => move_timer_reset,
    enable => move_timer_enable,
    done => move_timer_done
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
  PROCESS (clk, reset, request_valid, floor_request, door_timer_done, move_timer_done)
    VARIABLE has_above : BOOLEAN;
    VARIABLE has_below : BOOLEAN;
  BEGIN

    -- Update pending requests
    IF request_valid = '1' THEN
      IF to_integer(unsigned(floor_request)) <= 9 THEN
        pending_requests(to_integer(unsigned(floor_request))) <= '1';
      END IF;
    END IF;
    IF reset = '1' THEN
      current_state <= IDLE;
      current_floor_internal <= 0;
      target_floor <= 0;
      pending_requests <= (OTHERS => '0');
      door_timer_reset <= '1';
      door_timer_enable <= '0';
      move_timer_reset <= '1';
      move_timer_enable <= '0';
      direction <= IDLE;
    ELSIF rising_edge(clk) THEN
      -- Clear the request for current floor when door opens and timer is done
      IF current_state = DOOR_OPEN AND door_timer_done = '1' THEN
        pending_requests(current_floor_internal) <= '0';
      END IF;

      -- Target floor selection logic using SCAN algorithm
      IF pending_requests /= "0000000000" THEN
        CASE direction IS
          WHEN UP =>
            -- Look for requests above current floor
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
            -- Look for requests below current floor
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

      -- Movement logic with timer
      CASE current_state IS
        WHEN MV_UP =>
          -- Start timer when entering movement state
          IF move_timer_enable = '0' THEN
            move_timer_reset <= '0';
            move_timer_enable <= '1';
            -- Wait for movement timer to complete before moving to next floor
          ELSIF move_timer_done = '1' THEN
            current_floor_internal <= current_floor_internal + 1;
            -- Reset timer for next floor transition
            move_timer_reset <= '1';
            move_timer_enable <= '0';
          END IF;
          direction <= UP;

        WHEN MV_DN =>
          -- Start timer when entering movement state
          IF move_timer_enable = '0' THEN
            move_timer_reset <= '0';
            move_timer_enable <= '1';
            -- Wait for movement timer to complete before moving to next floor
          ELSIF move_timer_done = '1' THEN
            current_floor_internal <= current_floor_internal - 1;
            -- Reset timer for next floor transition
            move_timer_reset <= '1';
            move_timer_enable <= '0';
          END IF;
          direction <= DOWN;

        WHEN DOOR_OPEN =>
          -- Door timer control
          door_timer_reset <= '0';
          door_timer_enable <= '1';
          -- Disable movement timer
          move_timer_reset <= '1';
          move_timer_enable <= '0';

        WHEN IDLE =>
          -- Reset both timers when idle
          door_timer_reset <= '1';
          door_timer_enable <= '0';
          move_timer_reset <= '1';
          move_timer_enable <= '0';

        WHEN OTHERS =>
          NULL;
      END CASE;

      -- State transition
      current_state <= next_state;
    END IF;
  END PROCESS;

  -- Next state logic process
  PROCESS (current_state, current_floor_internal, target_floor, door_timer_done, move_timer_done, pending_requests)
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
        -- Check if we've reached target after movement
        -- We need to wait for timer to complete the current floor transition
        IF move_timer_done = '1' AND (current_floor_internal + 1) = target_floor THEN
          next_state <= DOOR_OPEN;
        ELSE
          next_state <= MV_UP;
        END IF;

      WHEN MV_DN =>
        -- Check if we've reached target after movement
        -- We need to wait for timer to complete the current floor transition
        IF move_timer_done = '1' AND (current_floor_internal - 1) = target_floor THEN
          next_state <= DOOR_OPEN;
        ELSE
          next_state <= MV_DN;
        END IF;

      WHEN DOOR_OPEN =>
        IF door_timer_done = '1' THEN
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