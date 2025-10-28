-- ============================================================
-- Entity: elevator_ctrl
-- Description: Top-level modular elevator controller
--              Integrates all subsystem components
-- ============================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.elevator_pkg.ALL;

ENTITY elevator_ctrl IS
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
END ENTITY elevator_ctrl;

ARCHITECTURE structural OF elevator_ctrl IS
  
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
  
  COMPONENT request_mgr IS
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
  
  COMPONENT scan_sched IS
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
  
  COMPONENT fsm_ctrl IS
    GENERIC (N_FLOORS : INTEGER := 10);
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      current_floor : IN INTEGER RANGE 0 TO 9;
      target_floor : IN INTEGER RANGE 0 TO 9;
      direction : IN direction_type;
      pending_requests : IN STD_LOGIC_VECTOR(N_FLOORS - 1 DOWNTO 0);
      door_timer_done : IN STD_LOGIC;
      move_timer_done : IN STD_LOGIC;
      current_state : OUT state_type;
      next_state : OUT state_type
    );
  END COMPONENT;
  
  COMPONENT move_ctrl IS
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      current_state : IN state_type;
      move_timer_done : IN STD_LOGIC;
      move_timer_reset : OUT STD_LOGIC;
      move_timer_enable : OUT STD_LOGIC;
      current_floor : INOUT INTEGER RANGE 0 TO 9
    );
  END COMPONENT;
  
  COMPONENT door_ctrl IS
    GENERIC (N_FLOORS : INTEGER := 10);
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      current_state : IN state_type;
      current_floor : IN INTEGER RANGE 0 TO 9;
      door_timer_done : IN STD_LOGIC;
      door_timer_reset : OUT STD_LOGIC;
      door_timer_enable : OUT STD_LOGIC;
      door_status : OUT STD_LOGIC_VECTOR(N_FLOORS - 1 DOWNTO 0);
      request_cleared : OUT STD_LOGIC
    );
  END COMPONENT;
  
  -- ============================================================
  -- Internal Signals
  -- ============================================================
  
  -- State machine
  SIGNAL current_state : state_type;
  SIGNAL next_state : state_type;
  SIGNAL direction : direction_type := IDLE;
  
  -- Floor tracking
  SIGNAL target_floor : INTEGER RANGE 0 TO 9 := 0;
  SIGNAL current_floor_internal : INTEGER RANGE 0 TO 9 := 0;
  
  -- Request management
  SIGNAL pending_requests : STD_LOGIC_VECTOR(N_FLOORS - 1 DOWNTO 0);
  SIGNAL clear_floor : INTEGER RANGE 0 TO 9 := 0;
  SIGNAL clear_request : STD_LOGIC := '0';
  
  -- Timer signals
  SIGNAL door_timer_reset : STD_LOGIC;
  SIGNAL door_timer_enable : STD_LOGIC;
  SIGNAL door_timer_done : STD_LOGIC;
  
  SIGNAL move_timer_reset : STD_LOGIC;
  SIGNAL move_timer_enable : STD_LOGIC;
  SIGNAL move_timer_done : STD_LOGIC;
  
  -- Display
  SIGNAL ssd_binary_in : STD_LOGIC_VECTOR(3 DOWNTO 0);


BEGIN

  -- ============================================================
  -- Component Instantiations
  -- ============================================================
  
  -- Request Manager: Handles floor request queue
  req_mgr_inst : request_mgr
    GENERIC MAP(N_FLOORS => N_FLOORS)
    PORT MAP(
      clk => clk,
      reset => reset,
      floor_request => floor_request,
      request_valid => request_valid,
      clear_floor => current_floor_internal,
      clear_request => clear_request,
      pending_requests => pending_requests
    );
  
  -- SCAN Scheduler: Determines next target floor
  scan_inst : scan_sched
    GENERIC MAP(N_FLOORS => N_FLOORS)
    PORT MAP(
      clk => clk,
      reset => reset,
      current_floor => current_floor_internal,
      pending_requests => pending_requests,
      direction => direction,
      target_floor => target_floor
    );
  
  -- FSM Controller: Main state machine
  fsm_inst : fsm_ctrl
    GENERIC MAP(N_FLOORS => N_FLOORS)
    PORT MAP(
      clk => clk,
      reset => reset,
      current_floor => current_floor_internal,
      target_floor => target_floor,
      direction => direction,
      pending_requests => pending_requests,
      door_timer_done => door_timer_done,
      move_timer_done => move_timer_done,
      current_state => current_state,
      next_state => next_state
    );
  
  -- Movement Controller: Handles floor transitions
  move_inst : move_ctrl
    PORT MAP(
      clk => clk,
      reset => reset,
      current_state => current_state,
      move_timer_done => move_timer_done,
      move_timer_reset => move_timer_reset,
      move_timer_enable => move_timer_enable,
      current_floor => current_floor_internal
    );
  
  -- Door Controller: Manages door operations
  door_inst : door_ctrl
    GENERIC MAP(N_FLOORS => N_FLOORS)
    PORT MAP(
      clk => clk,
      reset => reset,
      current_state => current_state,
      current_floor => current_floor_internal,
      door_timer_done => door_timer_done,
      door_timer_reset => door_timer_reset,
      door_timer_enable => door_timer_enable,
      door_status => door_status,
      request_cleared => clear_request
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
  -- Output Assignments
  -- ============================================================
  
  -- Convert current floor to binary for SSD
  ssd_binary_in <= STD_LOGIC_VECTOR(to_unsigned(current_floor_internal, 4));
  
  -- Current floor output
  current_floor <= current_floor_internal;

END ARCHITECTURE structural;