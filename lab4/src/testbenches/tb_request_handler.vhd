LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Simple testbench to debug request_handler

ENTITY tb_request_handler IS
END ENTITY tb_request_handler;

ARCHITECTURE behavior OF tb_request_handler IS

  COMPONENT Request_handler
    GENERIC (N : INTEGER := 9);
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      floor_select : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      request_button : IN STD_LOGIC;
      current_floor : IN INTEGER RANGE 0 TO 9;
      clear_request : IN STD_LOGIC;
      next_floor : OUT INTEGER RANGE 0 TO 9
    );
  END COMPONENT;

  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL reset : STD_LOGIC := '0';
  SIGNAL floor_select : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
  SIGNAL request_button : STD_LOGIC := '0';
  SIGNAL current_floor : INTEGER RANGE 0 TO 9 := 0;
  SIGNAL clear_request : STD_LOGIC := '0';
  SIGNAL next_floor : INTEGER RANGE 0 TO 9;

  CONSTANT clk_period : TIME := 20 ns;
  SIGNAL test_running : BOOLEAN := TRUE;

BEGIN

  uut : Request_handler
  GENERIC MAP(N => 9)
  PORT MAP(
    clk => clk,
    reset => reset,
    floor_select => floor_select,
    request_button => request_button,
    current_floor => current_floor,
    clear_request => clear_request,
    next_floor => next_floor
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
    REPORT "Testing Request Handler";

    -- Reset
    reset <= '1';
    WAIT FOR 100 ns;
    reset <= '0';
    WAIT FOR 100 ns;

    REPORT "Initial: current=" & INTEGER'IMAGE(current_floor) & ", next=" & INTEGER'IMAGE(next_floor);

    -- Request floor 3
    REPORT "Requesting floor 3";
    floor_select <= "0011";
    WAIT FOR 50 ns;
    request_button <= '1';
    WAIT FOR 200 ns;
    request_button <= '0';
    WAIT FOR 200 ns;

    REPORT "After request: current=" & INTEGER'IMAGE(current_floor) & ", next=" & INTEGER'IMAGE(next_floor);

    -- Simulate moving to floor 1
    current_floor <= 1;
    WAIT FOR 100 ns;
    REPORT "Moved to floor 1: next=" & INTEGER'IMAGE(next_floor);

    -- Simulate moving to floor 2
    current_floor <= 2;
    WAIT FOR 100 ns;
    REPORT "Moved to floor 2: next=" & INTEGER'IMAGE(next_floor);

    -- Simulate moving to floor 3
    current_floor <= 3;
    WAIT FOR 100 ns;
    REPORT "Moved to floor 3: next=" & INTEGER'IMAGE(next_floor);

    -- Clear request at floor 3
    clear_request <= '1';
    WAIT FOR 40 ns;
    clear_request <= '0';
    WAIT FOR 100 ns;
    REPORT "Cleared floor 3: next=" & INTEGER'IMAGE(next_floor);

    REPORT "Test complete!";
    test_running <= FALSE;
    WAIT;
  END PROCESS;

END ARCHITECTURE behavior;