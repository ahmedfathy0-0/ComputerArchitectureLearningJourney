LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.elevator_types.ALL;

-- Hardware Wrapper for Elevator System
-- Converts INTEGER and enumeration types to STD_LOGIC for pin connections
-- This entity is the top-level for hardware implementation
-- Buttons are active-low (pressed = '0', not pressed = '1')

ENTITY elevator_system_hw IS
  GENERIC (
    MAX_FLOOR : INTEGER := 9; -- Maximum floor number (0 to MAX_FLOOR)
    CLOCK_FREQ : INTEGER := 50_000_000 -- Clock frequency in Hz
  );
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC; -- Active low - Clears pending requests only
    floor_select : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Binary floor selection (0-9)
    request_button : IN STD_LOGIC; -- Active low - Push button to register request

    current_floor : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Current floor as 4-bit binary
    door_state : OUT STD_LOGIC; -- Door status: '1' = OPEN, '0' = CLOSED
    ssd_floor : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) -- Seven segment display (active low)
  );
END ENTITY elevator_system_hw;

ARCHITECTURE wrapper OF elevator_system_hw IS

  -- Component declaration for the original elevator_system
  COMPONENT Elevator_system
    GENERIC (
      MAX_FLOOR : INTEGER := 9;
      CLOCK_FREQ : INTEGER := 50_000_000
    );
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      floor_select : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      request_button : IN STD_LOGIC;
      current_floor : OUT INTEGER RANGE 0 TO MAX_FLOOR;
      door_state : OUT door_state_type;
      ssd_floor : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
  END COMPONENT;

  -- Internal signals
  SIGNAL current_floor_internal : INTEGER RANGE 0 TO MAX_FLOOR;
  SIGNAL door_state_internal : door_state_type;
  SIGNAL reset_internal : STD_LOGIC;
  SIGNAL request_button_internal : STD_LOGIC;

BEGIN

  -- Convert active-low buttons to active-high
  reset_internal <= NOT reset;
  request_button_internal <= NOT request_button;

  -- Instantiate the original elevator system
  elevator_inst : Elevator_system
  GENERIC MAP(
    MAX_FLOOR => MAX_FLOOR,
    CLOCK_FREQ => CLOCK_FREQ
  )
  PORT MAP(
    clk => clk,
    reset => reset_internal,
    floor_select => floor_select,
    request_button => request_button_internal,
    current_floor => current_floor_internal,
    door_state => door_state_internal,
    ssd_floor => ssd_floor
  );

  -- Convert INTEGER current_floor to STD_LOGIC_VECTOR for pins
  current_floor <= STD_LOGIC_VECTOR(to_unsigned(current_floor_internal, 4));

  -- Convert door_state enumeration to STD_LOGIC for LED
  -- '1' when door is open, '0' when door is closed
  door_state <= '1' WHEN door_state_internal = DOOR_OPEN ELSE
    '0';

END ARCHITECTURE wrapper;