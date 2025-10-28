-- ============================================================
-- Entity: elevator_fsm
-- Description: Main elevator finite state machine controller
-- ============================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.elevator_types.ALL;

ENTITY elevator_fsm IS
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
END ENTITY elevator_fsm;

ARCHITECTURE behavioral OF elevator_fsm IS
  
  -- ============================================================
  -- Component Declarations
  -- ============================================================
  
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

  COMPONENT ssd IS
    PORT (
      binary_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      ssd_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
  END COMPONENT;
  
  COMPONENT request_manager IS
    GENERIC (N_FLOORS : INTEGER := 10);
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      floor_request : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      request_valid : IN STD_LOGIC;
      clear_floor : IN INTEGER RANGE 0 TO 9;
      clear_request : IN STD_LOGIC;
      pending_requests : OUT STD_LOGIC_VECTOR(N_FLOORS - 1 DOWNTO 0)
    );
  END COMPONENT;
  
  COMPONENT scan_scheduler IS
    GENERIC (N_FLOORS : INTEGER := 10);
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      current_floor : IN INTEGER RANGE 0 TO 9;
      pending_requests : IN STD_LOGIC_VECTOR(N_FLOORS - 1 DOWNTO 0);
      direction : INOUT direction_type;
      target_floor : OUT INTEGER RANGE 0 TO 9
    );
  END COMPONENT;

  -- ============================================================
  -- Internal Signals
  -- ============================================================
  
  -- State machine
  SIGNAL current_state, next_state : state_type;
  SIGNAL direction : direction_type := IDLE;
  
  -- Floor tracking
  SIGNAL target_floor : INTEGER RANGE 0 TO 9 := 0;
  SIGNAL current_floor_internal : INTEGER RANGE 0 TO 9 := 0;
  
  -- Request management
  SIGNAL pending_requests : STD_LOGIC_VECTOR(N_FLOORS - 1 DOWNTO 0);
  SIGNAL clear_floor : INTEGER RANGE 0 TO 9 := 0;
  SIGNAL clear_request : STD_LOGIC := '0';
  
  -- Timer signals
  SIGNAL door_timer_reset : STD_LOGIC := '1';
  SIGNAL door_timer_enable : STD_LOGIC := '0';
  SIGNAL door_timer_done : STD_LOGIC;
  
  SIGNAL move_timer_reset : STD_LOGIC := '1';
  SIGNAL move_timer_enable : STD_LOGIC := '0';
  SIGNAL move_timer_done : STD_LOGIC;
  
  -- Seven segment display
  SIGNAL ssd_binary_in : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

  -- ============================================================
  -- Component Instantiations
  -- ============================================================
  
  -- Request Manager: Handles floor request queue
  request_mgr_inst : request_manager
    GENERIC MAP(N_FLOORS => N_FLOORS)
    PORT MAP(
      clk => clk,
      reset => reset,
      floor_request => floor_request,
      request_valid => request_valid,
      clear_floor => clear_floor,
      clear_request => clear_request,
      pending_requests => pending_requests
    );
  
  -- SCAN Scheduler: Determines next target floor
  scheduler_inst : scan_scheduler
    GENERIC MAP(N_FLOORS => N_FLOORS)
    PORT MAP(
      clk => clk,
      reset => reset,
      current_floor => current_floor_internal,
      pending_requests => pending_requests,
      direction => direction,
      target_floor => target_floor
    );
  
  -- Door Timer: Controls door open duration
  door_timer_inst : timer
    GENERIC MAP(
      CLOCK_FREQ => 50_000_000,
      DURATION_SEC => 2
    )
    PORT MAP(
      clk => clk,
      reset => door_timer_reset,
      enable => door_timer_enable,
      done => door_timer_done
    );

  -- Movement Timer: Controls time between floors
  move_timer_inst : timer
    GENERIC MAP(
      CLOCK_FREQ => 50_000_000,
      DURATION_SEC => 2
    )
    PORT MAP(
      clk => clk,
      reset => move_timer_reset,
      enable => move_timer_enable,
      done => move_timer_done
    );

  -- Seven Segment Display: Shows current floor
  ssd_inst : ssd
    PORT MAP(
      binary_in => ssd_binary_in,
      ssd_out => seven_segment
    );

  -- ============================================================
  -- Floor to Binary Conversion
  -- ============================================================
  ssd_binary_in <= STD_LOGIC_VECTOR(to_unsigned(current_floor_internal, 4));

  -- ============================================================
  -- Main State Machine: Sequential Logic
  -- ============================================================
  state_register : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      current_state <= IDLE;
      door_timer_reset <= '1';
      door_timer_enable <= '0';
      move_timer_reset <= '1';
      move_timer_enable <= '0';
      clear_request <= '0';
      
    ELSIF rising_edge(clk) THEN
      -- State transition
      current_state <= next_state;
      
      -- Clear request when door timer completes
      IF current_state = DOOR_OPEN AND door_timer_done = '1' THEN
        clear_floor <= current_floor_internal;
        clear_request <= '1';
      ELSE
        clear_request <= '0';
      END IF;
      
      -- State-specific actions
      CASE current_state IS
        WHEN MV_UP =>
          -- Handle upward movement with timer
          IF move_timer_enable = '0' THEN
            move_timer_reset <= '0';
            move_timer_enable <= '1';
          ELSIF move_timer_done = '1' THEN
            current_floor_internal <= current_floor_internal + 1;
            move_timer_reset <= '1';
            move_timer_enable <= '0';
          END IF;
          
        WHEN MV_DN =>
          -- Handle downward movement with timer
          IF move_timer_enable = '0' THEN
            move_timer_reset <= '0';
            move_timer_enable <= '1';
          ELSIF move_timer_done = '1' THEN
            current_floor_internal <= current_floor_internal - 1;
            move_timer_reset <= '1';
            move_timer_enable <= '0';
          END IF;
          
        WHEN DOOR_OPEN =>
          door_timer_reset <= '0';
          door_timer_enable <= '1';
          move_timer_reset <= '1';
          move_timer_enable <= '0';
          
        WHEN IDLE =>
          door_timer_reset <= '1';
          door_timer_enable <= '0';
          move_timer_reset <= '1';
          move_timer_enable <= '0';
          
        WHEN OTHERS =>
          NULL;
      END CASE;
      
    END IF;
  END PROCESS state_register;

  -- ============================================================
  -- Next State Logic: Combinational
  -- ============================================================
  next_state_logic : PROCESS (current_state, current_floor_internal, target_floor, 
                                door_timer_done, move_timer_done, pending_requests)
  BEGIN
    CASE current_state IS
      WHEN IDLE =>
        IF pending_requests /= (pending_requests'RANGE => '0') THEN
          IF current_floor_internal < target_floor THEN
            next_state <= MV_UP;
          ELSIF current_floor_internal > target_floor THEN
            next_state <= MV_DN;
          ELSIF pending_requests(target_floor) = '1' THEN
            next_state <= DOOR_OPEN;
          ELSE
            next_state <= IDLE;
          END IF;
        ELSE
          next_state <= IDLE;
        END IF;

      WHEN MV_UP =>
        IF move_timer_done = '1' AND (current_floor_internal + 1) = target_floor THEN
          next_state <= DOOR_OPEN;
        ELSE
          next_state <= MV_UP;
        END IF;

      WHEN MV_DN =>
        IF move_timer_done = '1' AND (current_floor_internal - 1) = target_floor THEN
          next_state <= DOOR_OPEN;
        ELSE
          next_state <= MV_DN;
        END IF;

      WHEN DOOR_OPEN =>
        IF door_timer_done = '1' THEN
          next_state <= IDLE;
        ELSE
          next_state <= DOOR_OPEN;
        END IF;

      WHEN OTHERS =>
        next_state <= IDLE;
    END CASE;
  END PROCESS next_state_logic;

  -- ============================================================
  -- Output Logic
  -- ============================================================
  
  -- Current floor output
  current_floor <= current_floor_internal;

  -- Door status output
  door_output : PROCESS (current_state, current_floor_internal)
  BEGIN
    door_status <= (OTHERS => '0');
    IF current_state = DOOR_OPEN THEN
      door_status(current_floor_internal) <= '1';
    END IF;
  END PROCESS door_output;

END ARCHITECTURE behavioral;
