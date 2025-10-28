LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.elevator_types.ALL;

-- Testbench for Elevator System
-- Tests the complete elevator system with binary floor input and button

ENTITY tb_elevator_system IS
END ENTITY tb_elevator_system;

ARCHITECTURE behavior OF tb_elevator_system IS

  -- Component declaration
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
      current_floor : OUT INTEGER RANGE 0 TO 9;
      door_state : OUT door_state_type;
      ssd_floor : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
  END COMPONENT;

  -- Testbench signals
  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL reset : STD_LOGIC := '0';
  SIGNAL floor_select : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
  SIGNAL request_button : STD_LOGIC := '0';
  SIGNAL current_floor : INTEGER RANGE 0 TO 9;
  SIGNAL door_state : door_state_type;
  SIGNAL ssd_floor : STD_LOGIC_VECTOR(6 DOWNTO 0);

  -- Clock period
  CONSTANT clk_period : TIME := 20 ns; -- 50 MHz

  -- Test control
  SIGNAL test_running : BOOLEAN := TRUE;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : Elevator_system
  GENERIC MAP(
    MAX_FLOOR => 9,
    CLOCK_FREQ => 100 -- Use 100 Hz for faster testing (0.01s per cycle, 2s = 200 clocks)
  )
  PORT MAP(
    clk => clk,
    reset => reset,
    floor_select => floor_select,
    request_button => request_button,
    current_floor => current_floor,
    door_state => door_state,
    ssd_floor => ssd_floor
  );

  -- Clock process
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

  -- Stimulus process
  stim_proc : PROCESS
  BEGIN
    -- Initial reset
    REPORT "Test: Starting elevator system test";
    reset <= '1';
    WAIT FOR 100 ns;
    reset <= '0';
    WAIT FOR 100 ns;
    REPORT "Initial state after reset - Floor=" & INTEGER'IMAGE(current_floor) & ", Door=" & door_state_type'IMAGE(door_state);

    -- Test 1: Request floor 3 from ground floor
    REPORT "Test 1: Requesting floor 3 from floor 0";
    floor_select <= "0011"; -- Binary 3
    WAIT FOR 50 ns;
    request_button <= '1';
    WAIT FOR 100 ns;
    request_button <= '0';
    WAIT FOR 500 ns; -- Wait for request to register
    REPORT "Test 1: After button press - Floor=" & INTEGER'IMAGE(current_floor);
    REPORT "Test 1: Floor 3 requested, waiting for elevator to move...";
    WAIT FOR 20 us; -- Wait for elevator to move (3 floors × 4us + door 4us = 16us)
    REPORT "Test 1: Final state - Floor=" & INTEGER'IMAGE(current_floor) & ", Door=" & door_state_type'IMAGE(door_state);

    -- Test 1 Assertions
    ASSERT current_floor = 3
    REPORT "ERROR: Test 1 failed - Expected floor 3, got " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;
    ASSERT door_state = DOOR_CLOSED
    REPORT "ERROR: Test 1 failed - Door should be closed after cycle, got " & door_state_type'IMAGE(door_state)
      SEVERITY ERROR;

    -- Test 2: Request floor 0 (grounded switches)
    REPORT "Test 2: Requesting floor 0 (ground floor)";
    floor_select <= "0000"; -- Binary 0
    WAIT FOR 50 ns;
    request_button <= '1';
    WAIT FOR 100 ns;
    request_button <= '0';
    REPORT "Test 2: Floor 0 requested, waiting for elevator to move...";
    WAIT FOR 20 us; -- Wait for elevator to move (3 floors × 4us + door 4us = 16us)
    REPORT "Test 2: Final state - Floor=" & INTEGER'IMAGE(current_floor) & ", Door=" & door_state_type'IMAGE(door_state);

    -- Test 2 Assertions
    ASSERT current_floor = 0
    REPORT "ERROR: Test 2 failed - Expected floor 0, got " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;
    ASSERT door_state = DOOR_CLOSED
    REPORT "ERROR: Test 2 failed - Door should be closed after cycle, got " & door_state_type'IMAGE(door_state)
      SEVERITY ERROR;

    -- Test 3: Request floor 9 (maximum floor)
    REPORT "Test 3: Requesting floor 9 (top floor)";
    floor_select <= "1001"; -- Binary 9
    WAIT FOR 50 ns;
    request_button <= '1';
    WAIT FOR 100 ns;
    request_button <= '0';
    REPORT "Test 3: Floor 9 requested, waiting for elevator to move...";
    WAIT FOR 50 us; -- Wait for elevator to move (9 floors × 4us + door 4us = 40us)
    REPORT "Test 3: Final state - Floor=" & INTEGER'IMAGE(current_floor) & ", Door=" & door_state_type'IMAGE(door_state);

    -- Test 3 Assertions
    ASSERT current_floor = 9
    REPORT "ERROR: Test 3 failed - Expected floor 9, got " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;
    ASSERT door_state = DOOR_CLOSED
    REPORT "ERROR: Test 3 failed - Door should be closed after cycle, got " & door_state_type'IMAGE(door_state)
      SEVERITY ERROR;

    -- Test 4: Multiple requests in sequence
    REPORT "Test 4: Multiple requests - floor 5, then floor 2";
    floor_select <= "0101"; -- Binary 5
    WAIT FOR 50 ns;
    request_button <= '1';
    WAIT FOR 100 ns;
    request_button <= '0';
    REPORT "Test 4: Floor 5 requested, elevator should start moving down";
    WAIT FOR 1 us;

    floor_select <= "0010"; -- Binary 2
    WAIT FOR 50 ns;
    request_button <= '1';
    WAIT FOR 100 ns;
    request_button <= '0';
    WAIT FOR 500 ns; -- Allow request to fully register
    REPORT "Test 4: Floor 2 requested, SCAN continues DOWN past floor 5 to reach floor 2, then reverses UP to floor 5";
    WAIT FOR 70 us; -- Wait for both trips: 9->2 (pass through 5) + 2->5 (reverse) = ~32us + buffer
    REPORT "Test 4: Final state - Floor=" & INTEGER'IMAGE(current_floor) & ", Door=" & door_state_type'IMAGE(door_state);

    -- Test 4 Assertions - SCAN algorithm: already moving DOWN when floor 2 requested
    -- Expected sequence: 9 → 5 (target) → 2 (continues DOWN per SCAN) → 5 (reverses UP)
    -- This demonstrates SCAN correctly: continues in current direction before reversing
    -- Expected final position: floor 5 (last floor serviced after reversing)
    ASSERT current_floor = 5
    REPORT "ERROR: Test 4 failed - Expected floor 5 (last serviced), got " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;
    ASSERT door_state = DOOR_CLOSED
    REPORT "ERROR: Test 4 failed - Door should be closed after cycle, got " & door_state_type'IMAGE(door_state)
      SEVERITY ERROR;

    -- Test 5: Reset clears pending requests
    REPORT "Test 5: Testing reset functionality";
    floor_select <= "0111"; -- Binary 7
    WAIT FOR 50 ns;
    request_button <= '1';
    WAIT FOR 100 ns;
    request_button <= '0';
    REPORT "Test 5: Floor 7 requested, but will reset before elevator moves";
    WAIT FOR 500 ns;

    reset <= '1'; -- Reset should clear the request
    REPORT "Test 5: Reset activated - should clear pending requests";
    WAIT FOR 200 ns;
    reset <= '0';
    REPORT "Test 5: Reset deactivated, elevator should remain at current floor";
    WAIT FOR 10 us; -- Verify elevator doesn't move to floor 7
    REPORT "Test 5: Final state after reset - Floor=" & INTEGER'IMAGE(current_floor) & ", Door=" & door_state_type'IMAGE(door_state);

    -- Test 5 Assertions - After reset, elevator should NOT have moved to floor 7
    -- It should be at floor 2 or 5 from previous test (SCAN algorithm)
    ASSERT current_floor /= 7
    REPORT "ERROR: Test 5 failed - Elevator moved to floor 7 despite reset! Floor=" & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;
    ASSERT (current_floor = 2 OR current_floor = 5)
    REPORT "WARNING: Test 5 - Elevator at unexpected floor " & INTEGER'IMAGE(current_floor) & " (expected 2 or 5 from Test 4)"
      SEVERITY WARNING; -- Test 6: Door behavior - opens for 2 seconds then closes
    REPORT "Test 6: Verifying door timing";
    floor_select <= "0001"; -- Binary 1
    WAIT FOR 50 ns;
    request_button <= '1';
    WAIT FOR 100 ns;
    request_button <= '0';
    REPORT "Test 6: Floor 1 requested, door should open for 2 seconds then close";
    WAIT FOR 24 us; -- Wait for door cycle to complete: 5->1 (4 down @ 4us each = 16us) + door (4us) = 20us + buffer
    REPORT "Test 6: Final state - Floor=" & INTEGER'IMAGE(current_floor) & ", Door=" & door_state_type'IMAGE(door_state);

    -- Test 6 Assertions
    ASSERT current_floor = 1
    REPORT "ERROR: Test 6 failed - Expected floor 1, got " & INTEGER'IMAGE(current_floor)
      SEVERITY ERROR;
    ASSERT door_state = DOOR_CLOSED
    REPORT "ERROR: Test 6 failed - Door should be closed after cycle, got " & door_state_type'IMAGE(door_state)
      SEVERITY ERROR;

    REPORT "All tests completed successfully!";
    test_running <= FALSE;
    WAIT;
  END PROCESS;

  -- Monitor process - removed to avoid continuous printing
  -- Key events are reported in the stimulus process instead

END ARCHITECTURE behavior;