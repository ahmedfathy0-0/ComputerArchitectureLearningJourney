LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.elevator_types.ALL;

-- Top-level Elevator System
-- Integrates Request Handler and Elevator Controller
--
-- Input Interface:
--   floor_select: 4-bit binary input from switches (0000-1001 for floors 0-9)
--   request_button: Push button to register floor request (asynchronous input)
--   reset: Clears all pending floor requests only
--
-- Output Interface:
--   current_floor: Current elevator position (0-9)
--   door_state: Current door state (DOOR_OPEN or DOOR_CLOSED)
--
-- Behavior:
--   - User sets floor using 4 switches (binary 0-9)
--   - User presses button to register the request
--   - Elevator moves using SCAN algorithm (continues in direction until no requests)
--   - Door opens for 2 seconds at destination, then closes automatically
--   - Reset clears all pending requests but doesn't affect current position/state

ENTITY Elevator_system IS
  GENERIC (
    MAX_FLOOR : INTEGER := 9; -- Maximum floor number (0 to MAX_FLOOR)
    CLOCK_FREQ : INTEGER := 50_000_000 -- Clock frequency in Hz
  );
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC; -- Clears pending requests only
    floor_select : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Binary floor selection (0-9)
    request_button : IN STD_LOGIC; -- Push button to register request

    current_floor : OUT INTEGER RANGE 0 TO MAX_FLOOR; -- Current floor
    door_state : OUT door_state_type -- Door status (DOOR_OPEN/DOOR_CLOSED)
  );
END ENTITY Elevator_system;

ARCHITECTURE structural OF Elevator_system IS

  -- Component declarations
  COMPONENT Request_handler
    GENERIC (N : INTEGER := 9);
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      floor_select : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      request_button : IN STD_LOGIC;
      current_floor : IN INTEGER RANGE 0 TO N;
      clear_request : IN STD_LOGIC;
      next_floor : OUT INTEGER RANGE 0 TO N
    );
  END COMPONENT;

  COMPONENT Elevator_controller
    GENERIC (
      MAX_FLOOR : INTEGER := 9;
      CLOCK_FREQ : INTEGER := 50_000_000;
      DURATION_SEC : INTEGER := 2
    );
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      enable : IN STD_LOGIC;
      next_floor : IN INTEGER RANGE 0 TO MAX_FLOOR;
      current_floor : OUT INTEGER RANGE 0 TO MAX_FLOOR;
      door_state : OUT door_state_type;
      clear_request : OUT STD_LOGIC
    );
  END COMPONENT;

  -- Internal signals
  SIGNAL current_floor_internal : INTEGER RANGE 0 TO MAX_FLOOR;
  SIGNAL next_floor_internal : INTEGER RANGE 0 TO MAX_FLOOR;
  SIGNAL clear_request_internal : STD_LOGIC;
  SIGNAL enable_internal : STD_LOGIC;

BEGIN

  -- Request Handler Instance
  -- Manages floor requests and determines next target
  request_handler_inst : Request_handler
  GENERIC MAP(
    N => MAX_FLOOR
  )
  PORT MAP(
    clk => clk,
    reset => reset,
    floor_select => floor_select,
    request_button => request_button,
    current_floor => current_floor_internal,
    clear_request => clear_request_internal,
    next_floor => next_floor_internal
  );

  -- Elevator Controller Instance
  -- Controls physical elevator movement and door operations
  elevator_controller_inst : Elevator_controller
  GENERIC MAP(
    MAX_FLOOR => MAX_FLOOR,
    CLOCK_FREQ => CLOCK_FREQ
  )
  PORT MAP(
    clk => clk,
    reset => reset,
    enable => enable_internal,
    next_floor => next_floor_internal,
    current_floor => current_floor_internal,
    door_state => door_state,
    clear_request => clear_request_internal
  );

  -- Output assignments
  current_floor <= current_floor_internal;

  -- Enable logic: Elevator should move when there are pending requests
  -- (i.e., when next_floor differs from current_floor)
  enable_internal <= '1' WHEN next_floor_internal /= current_floor_internal ELSE
    '0';

END ARCHITECTURE structural;