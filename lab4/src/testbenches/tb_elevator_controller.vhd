LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.elevator_types.ALL;

ENTITY tb_elevator_controller IS
END ENTITY tb_elevator_controller;

ARCHITECTURE behavior OF tb_elevator_controller IS

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
      next_floor : IN INTEGER RANGE 0 TO 9;
      current_floor : OUT INTEGER RANGE 0 TO 9;
      door_state : OUT door_state_type;
      clear_request : OUT STD_LOGIC
    );
  END COMPONENT;

  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL reset : STD_LOGIC := '0';
  SIGNAL enable : STD_LOGIC := '0';
  SIGNAL next_floor : INTEGER RANGE 0 TO 9 := 0;
  SIGNAL current_floor : INTEGER RANGE 0 TO 9;
  SIGNAL door_state : door_state_type;
  SIGNAL clear_request : STD_LOGIC;

  CONSTANT clk_period : TIME := 20 ns;
  SIGNAL test_running : BOOLEAN := TRUE;

BEGIN

  uut : Elevator_controller
  GENERIC MAP(
    MAX_FLOOR => 9,
    CLOCK_FREQ => 100, -- Fast clock for simulation (100 Hz)
    DURATION_SEC => 2
  )
  PORT MAP(
    clk => clk,
    reset => reset,
    enable => enable,
    next_floor => next_floor,
    current_floor => current_floor,
    door_state => door_state,
    clear_request => clear_request
  );

  clk_process : PROCESS
  BEGIN
    WHILE test_running LOOP
      clk <= '0';
      WAIT FOR clk_period/2;
      clk <= '1';
      WAIT FOR clk_period/2;
    END LOOP;
    WAIT;
  END PROCESS;

  stim_proc : PROCESS
  BEGIN
    REPORT "Testing Elevator Controller";

    WAIT FOR 100 ns;
    REPORT "Initial: floor=" & INTEGER'IMAGE(current_floor) & ", door=" & door_state_type'IMAGE(door_state);

    -- Request movement to floor 3
    REPORT "Setting next_floor=3, enable=1";
    next_floor <= 3;
    enable <= '1';
    WAIT FOR 200 ns;

    REPORT "After enable: floor=" & INTEGER'IMAGE(current_floor);

    -- Wait for elevator to move (3 floors × 4us + door 4us = 16us)
    WAIT FOR 20 us;
    REPORT "After 20us: floor=" & INTEGER'IMAGE(current_floor) & ", door=" & door_state_type'IMAGE(door_state);

    -- Test assertions
    ASSERT current_floor = 3
    REPORT "ERROR: Expected floor 3, got " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;
    ASSERT door_state = DOOR_CLOSED
    REPORT "ERROR: Expected door closed, got " & door_state_type'IMAGE(door_state)
      SEVERITY ERROR;

    REPORT "Test complete - elevator reached floor 3!";
    test_running <= FALSE;
    WAIT;
  END PROCESS;

END ARCHITECTURE behavior;