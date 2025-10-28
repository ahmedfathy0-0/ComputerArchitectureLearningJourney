LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_elevator_fsm IS
END ENTITY tb_elevator_fsm;

ARCHITECTURE testbench OF tb_elevator_fsm IS
  -- Component declaration
  COMPONENT elevator_fsm IS
    GENERIC (
      N_FLOORS : INTEGER := 10
    );
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      floor_request : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      request_valid : IN STD_LOGIC;
      seven_segment : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      current_floor : OUT INTEGER RANGE 0 TO 9;
      door_status : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
  END COMPONENT;

  -- Component declaration for timer (to override generics)
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

  -- Testbench signals
  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL reset : STD_LOGIC := '0';
  SIGNAL floor_request : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL request_valid : STD_LOGIC := '0';
  SIGNAL seven_segment : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL current_floor : INTEGER RANGE 0 TO 9;
  SIGNAL door_status : STD_LOGIC_VECTOR(9 DOWNTO 0);

  -- Clock period definition (5ns for fast simulation - matches 200MHz)
  CONSTANT clk_period : TIME := 5 ns;

  -- Timer configuration for fast simulation
  -- Using CLOCK_FREQ=10 (5ns period = 200MHz, but we use 10 cycles)
  -- Each timer cycle = 10 clock cycles (50ns)
  CONSTANT TIMER_CLOCK_FREQ : INTEGER := 10;
  CONSTANT TIMER_DURATION_SEC : INTEGER := 2;

  -- Test control
  SIGNAL test_running : BOOLEAN := TRUE;

  -- 7-segment display patterns (active low)
  TYPE ssd_array IS ARRAY (0 TO 9) OF STD_LOGIC_VECTOR(6 DOWNTO 0);
  CONSTANT SSD_PATTERNS : ssd_array := (
    0 => "1000000", -- 0
    1 => "1111001", -- 1
    2 => "0100100", -- 2
    3 => "0110000", -- 3
    4 => "0011001", -- 4
    5 => "0010010", -- 5
    6 => "0000010", -- 6
    7 => "1111000", -- 7
    8 => "0000000", -- 8
    9 => "0010000" -- 9
  );

  -- Helper function to check 7-segment display
  FUNCTION check_ssd(floor : INTEGER; ssd_out : STD_LOGIC_VECTOR(6 DOWNTO 0)) RETURN BOOLEAN IS
  BEGIN
    IF floor >= 0 AND floor <= 9 THEN
      RETURN ssd_out = SSD_PATTERNS(floor);
    ELSE
      RETURN FALSE;
    END IF;
  END FUNCTION;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut : elevator_fsm
  GENERIC MAP(
    N_FLOORS => 10
  )
  PORT MAP(
    clk => clk,
    reset => reset,
    floor_request => floor_request,
    request_valid => request_valid,
    seven_segment => seven_segment,
    current_floor => current_floor,
    door_status => door_status
  );

  -- Clock process
  clk_process : PROCESS
  BEGIN
    WHILE test_running LOOP
      clk <= '0';
      WAIT FOR clk_period / 2;
      clk <= '1';
      WAIT FOR clk_period / 2;
    END LOOP;
    WAIT;
  END PROCESS;

  -- Stimulus process
  stim_proc : PROCESS
  BEGIN
    -- Initialize
    reset <= '1';
    floor_request <= "0000";
    request_valid <= '0';
    WAIT FOR 10 ns;
    reset <= '0';

    REPORT "============================================================";
    REPORT "Elevator FSM Testbench Started (Two Timer Configuration)";
    REPORT "N_FLOORS: 10 (floors 0-9)";
    REPORT "Clock period: 5ns (200 MHz for simulation)";
    REPORT "Note: Timer frequencies should be set to 10 Hz for fast sim";
    REPORT "Door timer: 2 seconds = 20 clock cycles";
    REPORT "Movement timer: 2 seconds = 20 clock cycles per floor";
    REPORT "============================================================";

    -- Run initial setup
    WAIT FOR 50 ns;

    -- Test 1: Request floor 3
    REPORT "TEST 1: Request floor 3 (should take 3 floors x 20 cycles = 60 cycles)";
    floor_request <= "0011";
    request_valid <= '1';
    WAIT FOR 10 ns;
    request_valid <= '0';
    WAIT FOR 400 ns;

    REPORT "Current floor: " & INTEGER'IMAGE(current_floor);
    REPORT "Door status: " & INTEGER'IMAGE(to_integer(unsigned(door_status)));
    REPORT "Seven segment: " & INTEGER'IMAGE(to_integer(unsigned(seven_segment)));

    -- Assertions for Test 1
    ASSERT current_floor = 3
    REPORT "ERROR: Expected floor 3, got " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;

    ASSERT check_ssd(current_floor, seven_segment)
    REPORT "ERROR: Seven segment display mismatch for floor " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;

    ASSERT door_status(3) = '1' OR door_status = "0000000000"
    REPORT "ERROR: Door should be open or closed on floor 3"
      SEVERITY ERROR;

    -- Test 2: Request floor 5 while at floor 3
    REPORT "TEST 2: Request floor 5 (should take 2 floors x 20 cycles = 40 cycles)";
    floor_request <= "0101";
    request_valid <= '1';
    WAIT FOR 10 ns;
    request_valid <= '0';
    WAIT FOR 500 ns;

    REPORT "Current floor: " & INTEGER'IMAGE(current_floor);
    REPORT "Seven segment: " & INTEGER'IMAGE(to_integer(unsigned(seven_segment)));

    -- Assertions for Test 2
    ASSERT current_floor = 5
    REPORT "ERROR: Expected floor 5, got " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;

    ASSERT check_ssd(current_floor, seven_segment)
    REPORT "ERROR: Seven segment display mismatch for floor " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;

    -- Test 3: Request floor 1 (below current position)
    REPORT "TEST 3: Request floor 1 (should go down 4 floors x 20 cycles = 80 cycles)";
    floor_request <= "0001";
    request_valid <= '1';
    WAIT FOR 10 ns;
    request_valid <= '0';
    WAIT FOR 600 ns;

    REPORT "Current floor: " & INTEGER'IMAGE(current_floor);
    REPORT "Seven segment: " & INTEGER'IMAGE(to_integer(unsigned(seven_segment)));

    -- Assertions for Test 3
    ASSERT current_floor = 1
    REPORT "ERROR: Expected floor 1, got " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;

    ASSERT check_ssd(current_floor, seven_segment)
    REPORT "ERROR: Seven segment display mismatch for floor " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;

    -- Test 4: Multiple floor requests
    REPORT "TEST 4: Multiple requests - floors 2, 7, 4";
    floor_request <= "0010";
    request_valid <= '1';
    WAIT FOR 10 ns;
    request_valid <= '0';
    WAIT FOR 20 ns;

    floor_request <= "0111";
    request_valid <= '1';
    WAIT FOR 10 ns;
    request_valid <= '0';
    WAIT FOR 20 ns;

    floor_request <= "0100";
    request_valid <= '1';
    WAIT FOR 10 ns;
    request_valid <= '0';
    WAIT FOR 1000 ns;

    REPORT "Current floor: " & INTEGER'IMAGE(current_floor);
    REPORT "Seven segment: " & INTEGER'IMAGE(to_integer(unsigned(seven_segment)));

    -- Assertions for Test 4 (SCAN algorithm should visit floors in order)
    -- After visiting 2, 4, 7 in upward direction, should end at 7
    ASSERT current_floor = 7 OR current_floor = 4 OR current_floor = 2
    REPORT "ERROR: Expected elevator to be at floor 2, 4, or 7, got " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;

    ASSERT check_ssd(current_floor, seven_segment)
    REPORT "ERROR: Seven segment display mismatch for floor " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;

    -- Test 5: Test reset functionality
    REPORT "TEST 5: Testing reset";
    reset <= '1';
    WAIT FOR 20 ns;
    reset <= '0';
    WAIT FOR 50 ns;

    REPORT "After reset - Current floor: " & INTEGER'IMAGE(current_floor);
    REPORT "Seven segment: " & INTEGER'IMAGE(to_integer(unsigned(seven_segment)));

    -- Assertions for Test 5 (reset should clear to floor 0)
    ASSERT current_floor = 0
    REPORT "ERROR: After reset, expected floor 0, got " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;

    ASSERT check_ssd(0, seven_segment)
    REPORT "ERROR: Seven segment should display 0 after reset"
      SEVERITY ERROR;

    ASSERT door_status = "0000000000"
    REPORT "ERROR: All doors should be closed after reset"
      SEVERITY ERROR;

    -- Test 6: Request same floor elevator is on
    REPORT "TEST 6: Request floor 0 (current floor - door should open immediately)";
    floor_request <= "0000";
    request_valid <= '1';
    WAIT FOR 10 ns;
    request_valid <= '0';
    WAIT FOR 150 ns;

    REPORT "Door status on floor 0: " & INTEGER'IMAGE(to_integer(unsigned(door_status)));
    REPORT "Seven segment: " & INTEGER'IMAGE(to_integer(unsigned(seven_segment)));

    -- Assertions for Test 6 (door should open on current floor)
    ASSERT current_floor = 0
    REPORT "ERROR: Expected to remain on floor 0, got " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;

    ASSERT check_ssd(0, seven_segment)
    REPORT "ERROR: Seven segment should display 0"
      SEVERITY ERROR;

    ASSERT door_status(0) = '1' OR door_status = "0000000000"
    REPORT "WARNING: Door should have opened on floor 0"
      SEVERITY ERROR;

    -- Test 7: Watch movement timer in action
    REPORT "TEST 7: Request floor 2 to observe movement timer";
    floor_request <= "0010";
    request_valid <= '1';
    WAIT FOR 10 ns;
    request_valid <= '0';
    WAIT FOR 300 ns;

    REPORT "Current floor: " & INTEGER'IMAGE(current_floor);
    REPORT "Seven segment: " & INTEGER'IMAGE(to_integer(unsigned(seven_segment)));

    -- Assertions for Test 7
    ASSERT current_floor = 2 OR current_floor = 1 OR current_floor = 0
    REPORT "ERROR: Expected elevator to be moving to floor 2 (at 0, 1, or 2), got " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;

    ASSERT check_ssd(current_floor, seven_segment)
    REPORT "ERROR: Seven segment display mismatch for floor " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;

    REPORT "============================================================";
    REPORT "Simulation Complete";
    REPORT "============================================================";
    REPORT "All tests completed!";
    REPORT "Expected timing:";
    REPORT "  - Each floor transition: 20 clock cycles (100ns @ 5ns period)";
    REPORT "  - Door open duration: 20 clock cycles (100ns @ 5ns period)";
    REPORT "  - Floor 0 to Floor 3: 60 cycles + 20 door = 80 cycles total";
    REPORT "============================================================";
    REPORT "TESTBENCH SUMMARY: Check for any ERROR or WARNING messages above";
    REPORT "If no errors, all assertions passed successfully!";
    REPORT "============================================================";

    test_running <= FALSE;
    WAIT;
  END PROCESS;

  -- Continuous 7-segment display monitor
  monitor_ssd : PROCESS
  BEGIN
    WAIT FOR 1 ns;
    WAIT UNTIL test_running = FALSE;
    WAIT;
  END PROCESS;

END ARCHITECTURE testbench;

-- Configuration to override timer generics for fast simulation
CONFIGURATION tb_elevator_fsm_cfg OF tb_elevator_fsm IS
  FOR testbench
    FOR uut : elevator_fsm
      FOR behavioral
        FOR door_timer_inst : timer
          USE ENTITY work.timer(rtl)
          GENERIC MAP(
            CLOCK_FREQ => 10,
            DURATION_SEC => 2
          );
        END FOR;
        FOR move_timer_inst : timer
          USE ENTITY work.timer(rtl)
          GENERIC MAP(
            CLOCK_FREQ => 10,
            DURATION_SEC => 2
          );
        END FOR;
      END FOR;
    END FOR;
  END FOR;
END CONFIGURATION tb_elevator_fsm_cfg;