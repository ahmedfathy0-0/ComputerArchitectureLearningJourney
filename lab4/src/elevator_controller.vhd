LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Shared types used across elevator controller modules
PACKAGE elevator_types IS
  TYPE door_state_type IS (DOOR_OPEN, DOOR_CLOSED);
END PACKAGE elevator_types;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.elevator_types.ALL;

-- Entity description:
-- Controls elevator movement between floors and door operations
-- Door opens for 2 seconds at destination then closes automatically
-- Generates clear_request signal to acknowledge served floors
ENTITY Elevator_controller IS
  GENERIC (
    MAX_FLOOR : INTEGER := 9; -- Maximum floor number (0 to MAX_FLOOR)
    CLOCK_FREQ : INTEGER := 50_000_000; -- Clock frequency (passed to internal timer)
    DURATION_SEC : INTEGER := 2 -- Duration in seconds for movement/door
  );
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    enable : IN STD_LOGIC; -- Signal to indicate if elevator should move
    next_floor : IN INTEGER RANGE 0 TO MAX_FLOOR; -- Next floor for the elevator
    current_floor : OUT INTEGER RANGE 0 TO MAX_FLOOR; -- Current floor of the elevator
    door_state : OUT door_state_type; -- Current state of the door
    clear_request : OUT STD_LOGIC -- Pulse to clear served floor request
  );
END ENTITY Elevator_controller;

ARCHITECTURE behavior OF Elevator_controller IS

  COMPONENT timer
    GENERIC (
      CLOCK_FREQ : INTEGER := 50_000_000; -- Clock frequency in Hz
      DURATION_SEC : INTEGER := 2 -- Duration in seconds
    );
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      enable : IN STD_LOGIC; -- Start/stop timer
      done : OUT STD_LOGIC
    );
  END COMPONENT;

  -- Internal signals
  SIGNAL current_floor_internal : INTEGER RANGE 0 TO MAX_FLOOR := 0;
  SIGNAL door_state_internal : door_state_type := DOOR_CLOSED;
  SIGNAL move_timer_reset : STD_LOGIC := '1';
  SIGNAL timer_enable : STD_LOGIC := '0';
  SIGNAL timer_done : STD_LOGIC;

  -- State machine for elevator control
  TYPE state_type IS (IDLE, MOVING, DOOR_OPEN);
  SIGNAL state : state_type := IDLE;

BEGIN

  -- Timer instance for movement and door operations
  movement_timer : timer
  GENERIC MAP(
    CLOCK_FREQ => CLOCK_FREQ,
    DURATION_SEC => DURATION_SEC
  )
  PORT MAP(
    clk => clk,
    reset => move_timer_reset,
    enable => timer_enable,
    done => timer_done
  );

  -- Output assignments
  current_floor <= current_floor_internal;
  door_state <= door_state_internal;

  -- Main control process
  -- Note: Reset signal is not used here as per requirements
  -- Reset only clears floor requests in the request_handler
  PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      -- Default: no clear request
      clear_request <= '0';

      -- State machine operation
      CASE state IS

        WHEN IDLE =>
          move_timer_reset <= '1';
          timer_enable <= '0';
          door_state_internal <= DOOR_CLOSED;

          -- Check if movement is needed (when enabled and different floor)
          IF enable = '1' AND current_floor_internal /= next_floor THEN
            state <= MOVING;
            REPORT "Elevator_controller: transition IDLE -> MOVING; curr=" & INTEGER'IMAGE(current_floor_internal) & " next=" & INTEGER'IMAGE(next_floor) & " enable=" & STD_LOGIC'IMAGE(enable);
          END IF;

        WHEN MOVING =>
          door_state_internal <= DOOR_CLOSED; -- Ensure door stays closed during movement

          -- Check if we've reached destination
          IF current_floor_internal = next_floor THEN
            -- Arrived at destination: open door immediately
            door_state_internal <= DOOR_OPEN;
            state <= DOOR_OPEN;
            REPORT "Elevator_controller: Arrived at floor " & INTEGER'IMAGE(current_floor_internal) & "; opening door.";
            move_timer_reset <= '1';
            timer_enable <= '0';
          ELSE
            -- Continue moving
            IF timer_done = '1' THEN
              -- Move one floor
              IF current_floor_internal < next_floor THEN
                current_floor_internal <= current_floor_internal + 1;
                REPORT "Elevator_controller: Moving up to " & INTEGER'IMAGE(current_floor_internal + 1);
              ELSIF current_floor_internal > next_floor THEN
                current_floor_internal <= current_floor_internal - 1;
                REPORT "Elevator_controller: Moving down to " & INTEGER'IMAGE(current_floor_internal - 1);
              END IF;

              -- Reset timer for next movement
              move_timer_reset <= '1';
              timer_enable <= '0';
            ELSE
              -- Keep timer running
              move_timer_reset <= '0';
              timer_enable <= '1';
            END IF;
          END IF;

        WHEN DOOR_OPEN =>
          -- Keep door open for 2 seconds, then close and clear request
          IF timer_done = '1' THEN
            door_state_internal <= DOOR_CLOSED;
            clear_request <= '1'; -- Signal that floor has been served
            REPORT "Elevator_controller: Door timer done, clearing request for floor " & INTEGER'IMAGE(current_floor_internal);
            state <= IDLE;
            move_timer_reset <= '1';
            timer_enable <= '0';
          ELSE
            move_timer_reset <= '0';
            timer_enable <= '1';
          END IF;

      END CASE;
    END IF;
  END PROCESS;

END ARCHITECTURE behavior;