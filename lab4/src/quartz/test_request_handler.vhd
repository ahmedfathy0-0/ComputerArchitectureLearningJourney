LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- Test entity for Request Handler
-- Tests the request handler logic with visual LED outputs
-- SW[3:0] = floor selection
-- KEY[0] = request button (active low, so press = 0)
-- KEY[1] = reset (active low)
-- LEDR[3:0] = current floor (simulated)
-- LEDR[7:4] = next floor target
-- LEDR[9] = pending requests indicator
-- HEX0 = displays next floor
-- HEX1 = displays current floor

ENTITY test_request_handler IS
  GENERIC (
    MAX_FLOOR : INTEGER := 9
  );
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC; -- KEY[1] active low
    request_button : IN STD_LOGIC; -- KEY[0] active low
    floor_select : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- SW[3:0]
    current_floor_sw : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- SW[7:4] to simulate current floor

    -- Outputs
    next_floor_leds : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- LEDR[3:0]
    current_floor_leds : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- LEDR[7:4]
    has_requests : OUT STD_LOGIC; -- LEDR[9]
    ssd_next : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- HEX0
    ssd_current : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) -- HEX1
  );
END ENTITY test_request_handler;

ARCHITECTURE test OF test_request_handler IS

  COMPONENT Request_handler
    GENERIC (N : INTEGER := 9);
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      floor_request : IN STD_LOGIC;
      floor_number : IN INTEGER RANGE 0 TO N;
      current_floor : IN INTEGER RANGE 0 TO N;
      clear_request : IN STD_LOGIC;
      next_floor : OUT INTEGER RANGE 0 TO N
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
  SIGNAL request_internal : STD_LOGIC;
  SIGNAL button_sync : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";
  SIGNAL button_pressed : STD_LOGIC := '0';
  SIGNAL floor_number_internal : INTEGER RANGE 0 TO MAX_FLOOR;
  SIGNAL current_floor_internal : INTEGER RANGE 0 TO MAX_FLOOR;
  SIGNAL next_floor_internal : INTEGER RANGE 0 TO MAX_FLOOR;
  SIGNAL clear_request_sim : STD_LOGIC := '0'; -- Simulated clear signal
  SIGNAL next_floor_vec : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL current_floor_vec : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

  -- Convert active-low inputs to active-high
  reset_internal <= NOT reset;
  request_internal <= NOT request_button;

  -- Button synchronizer and edge detector
  button_sync_proc : PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      button_sync <= button_sync(0) & request_internal;
    END IF;
  END PROCESS;

  -- Detect rising edge of synchronized button
  button_pressed <= '1' WHEN button_sync = "01" ELSE
    '0';

  -- Convert inputs
  floor_number_internal <= to_integer(unsigned(floor_select));
  current_floor_internal <= to_integer(unsigned(current_floor_sw));

  -- Request Handler Instance
  request_handler_inst : Request_handler
  GENERIC MAP(N => MAX_FLOOR)
  PORT MAP(
    clk => clk,
    reset => reset_internal,
    floor_request => button_pressed,
    floor_number => floor_number_internal,
    current_floor => current_floor_internal,
    clear_request => clear_request_sim,
    next_floor => next_floor_internal
  );

  -- Convert outputs to vectors
  next_floor_vec <= STD_LOGIC_VECTOR(to_unsigned(next_floor_internal, 4));
  current_floor_vec <= STD_LOGIC_VECTOR(to_unsigned(current_floor_internal, 4));

  -- Seven Segment Displays
  ssd_next_inst : ssd
  PORT MAP(
    binary_in => next_floor_vec,
    ssd_out => ssd_next
  );

  ssd_current_inst : ssd
  PORT MAP(
    binary_in => current_floor_vec,
    ssd_out => ssd_current
  );

  -- Output assignments
  next_floor_leds <= next_floor_vec;
  current_floor_leds <= current_floor_vec;

  -- Indicate if there are pending requests (next_floor != current_floor)
  has_requests <= '1' WHEN next_floor_internal /= current_floor_internal ELSE
    '0';

  -- Simulate clear request when manually changing current floor to match next floor
  clear_request_sim <= '1' WHEN next_floor_internal = current_floor_internal ELSE
    '0';

END ARCHITECTURE test;