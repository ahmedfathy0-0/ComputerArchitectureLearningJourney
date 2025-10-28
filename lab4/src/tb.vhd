
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY elevator_fsm_tb IS
END ENTITY elevator_fsm_tb;

ARCHITECTURE testbench OF elevator_fsm_tb IS
  -- Clock period for simulation: 1 ms (1 kHz)
  -- This matches CLOCK_FREQ = 1000 in the scaled timer
  CONSTANT clk_period : TIME := 1 ms;
  
  -- Signals
  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL reset : STD_LOGIC := '1';
  SIGNAL floor_request : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL request_valid : STD_LOGIC := '0';
  SIGNAL seven_segment : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL current_floor : INTEGER RANGE 0 TO 9;
  SIGNAL door_status : STD_LOGIC_VECTOR(9 DOWNTO 0);
  
  -- Simulation control
  SIGNAL sim_done : BOOLEAN := false;
  
  -- Component declaration with scaled generics
  COMPONENT elevator_fsm IS
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

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  -- Note: Timer inside uses CLOCK_FREQ = 1000, DURATION_SEC = 2
  uut : elevator_fsm
  PORT MAP(
    clk => clk,
    reset => reset,
    floor_request => floor_request,
    request_valid => request_valid,
    seven_segment => seven_segment,
    current_floor => current_floor,
    door_status => door_status
  );

  -- Clock generation process
  clk_process : PROCESS
  BEGIN
    WHILE NOT sim_done LOOP
      clk <= '0';
      WAIT FOR clk_period / 2;
      clk <= '1';
      WAIT FOR clk_period / 2;
    END LOOP;
    WAIT;
  END PROCESS;

  -- Stimulus process
  stim_process : PROCESS
  BEGIN
    -- Initial reset
    reset <= '1';
    request_valid <= '0';
    floor_request <= "0000";
    WAIT FOR 5 ms;
    
    reset <= '0';
    WAIT FOR 2 ms;
    
    -- Test Case 1: Request floor 5 from floor 0
    REPORT "Test Case 1: Request floor 5";
    floor_request <= "0101"; -- Floor 5
    request_valid <= '1';
    WAIT FOR 1 ms;
    request_valid <= '0';
    WAIT FOR 20 ms; -- Wait for elevator to move and door to open
    
    -- Test Case 2: Request floor 8 while at floor 5
    REPORT "Test Case 2: Request floor 8";
    floor_request <= "1000"; -- Floor 8
    request_valid <= '1';
    WAIT FOR 1 ms;
    request_valid <= '0';
    WAIT FOR 15 ms;
    
    -- Test Case 3: Request floor 3 (going down)
    REPORT "Test Case 3: Request floor 3";
    floor_request <= "0011"; -- Floor 3
    request_valid <= '1';
    WAIT FOR 1 ms;
    request_valid <= '0';
    WAIT FOR 20 ms;
    
    -- Test Case 4: Multiple requests (SCAN algorithm test)
    REPORT "Test Case 4: Multiple requests - floors 1, 4, 7, 9";
    floor_request <= "0001"; -- Floor 1
    request_valid <= '1';
    WAIT FOR 1 ms;
    request_valid <= '0';
    WAIT FOR 1 ms;
    
    floor_request <= "0100"; -- Floor 4
    request_valid <= '1';
    WAIT FOR 1 ms;
    request_valid <= '0';
    WAIT FOR 1 ms;
    
    floor_request <= "0111"; -- Floor 7
    request_valid <= '1';
    WAIT FOR 1 ms;
    request_valid <= '0';
    WAIT FOR 1 ms;
    
    floor_request <= "1001"; -- Floor 9
    request_valid <= '1';
    WAIT FOR 1 ms;
    request_valid <= '0';
    WAIT FOR 50 ms; -- Wait for all requests to be serviced
    
    -- Test Case 5: Request current floor
    REPORT "Test Case 5: Request current floor";
    floor_request <= STD_LOGIC_VECTOR(to_unsigned(current_floor, 4));
    request_valid <= '1';
    WAIT FOR 1 ms;
    request_valid <= '0';
    WAIT FOR 5 ms;
    
    -- End simulation
    REPORT "Simulation completed successfully";
    sim_done <= true;
    WAIT;
  END PROCESS;

END ARCHITECTURE testbench;