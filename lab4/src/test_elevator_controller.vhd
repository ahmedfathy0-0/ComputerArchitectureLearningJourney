LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.elevator_types.ALL;

-- Test entity for Elevator Controller
-- Tests the elevator controller with manual next_floor input
-- SW[3:0] = next floor target
-- KEY[0] = enable (active low, press to enable movement)
-- KEY[1] = reset (active low)
-- LEDR[3:0] = current floor
-- LEDR[8] = door state (1=open, 0=closed)
-- LEDR[9] = clear request pulse
-- HEX0 = displays current floor

ENTITY test_elevator_controller IS
  GENERIC (
    MAX_FLOOR : INTEGER := 9;
    CLOCK_FREQ : INTEGER := 50_000_000;
    DURATION_SEC : INTEGER := 2
  );
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC; -- KEY[1] active low
    enable : IN STD_LOGIC; -- KEY[0] active low
    next_floor_sw : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- SW[3:0]

    -- Outputs
    current_floor_leds : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- LEDR[3:0]
    door_state_led : OUT STD_LOGIC; -- LEDR[8]
    clear_request_led : OUT STD_LOGIC; -- LEDR[9]
    ssd_current : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) -- HEX0
  );
END ENTITY test_elevator_controller;

ARCHITECTURE test OF test_elevator_controller IS

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

  COMPONENT ssd
    PORT (
      binary_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      ssd_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
  END COMPONENT;

  -- Internal signals
  SIGNAL reset_internal : STD_LOGIC;
  SIGNAL enable_internal : STD_LOGIC;
  SIGNAL next_floor_internal : INTEGER RANGE 0 TO MAX_FLOOR;
  SIGNAL current_floor_internal : INTEGER RANGE 0 TO MAX_FLOOR;
  SIGNAL door_state_internal : door_state_type;
  SIGNAL clear_request_internal : STD_LOGIC;
  SIGNAL current_floor_vec : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

  -- Convert active-low inputs to active-high
  reset_internal <= NOT reset;
  enable_internal <= NOT enable;

  -- Convert switch input to integer
  next_floor_internal <= to_integer(unsigned(next_floor_sw));

  -- Elevator Controller Instance
  controller_inst : Elevator_controller
  GENERIC MAP(
    MAX_FLOOR => MAX_FLOOR,
    CLOCK_FREQ => CLOCK_FREQ,
    DURATION_SEC => DURATION_SEC
  )
  PORT MAP(
    clk => clk,
    reset => reset_internal,
    enable => enable_internal,
    next_floor => next_floor_internal,
    current_floor => current_floor_internal,
    door_state => door_state_internal,
    clear_request => clear_request_internal
  );

  -- Convert current floor to vector
  current_floor_vec <= STD_LOGIC_VECTOR(to_unsigned(current_floor_internal, 4));

  -- Seven Segment Display for current floor
  ssd_inst : ssd
  PORT MAP(
    binary_in => current_floor_vec,
    ssd_out => ssd_current
  );

  -- Output assignments
  current_floor_leds <= current_floor_vec;
  door_state_led <= '1' WHEN door_state_internal = DOOR_OPEN ELSE
    '0';
  clear_request_led <= clear_request_internal;

END ARCHITECTURE test;