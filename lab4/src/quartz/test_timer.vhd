LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- Test entity for Timer
-- Blinks an LED every 1 second using the timer component
-- This verifies clock is working and timer is counting correctly
-- KEY[0] is active low, so button not pressed = '1' (no reset), button pressed = '0' (reset)

ENTITY test_timer IS
  GENERIC (
    CLOCK_FREQ : INTEGER := 50_000_000;
    DURATION_SEC : INTEGER := 1 -- 1 second for faster testing
  );
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC; -- Active low button
    led_out : OUT STD_LOGIC -- Blinks when timer completes
  );
END ENTITY test_timer;

ARCHITECTURE simple OF test_timer IS

  COMPONENT timer
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

  SIGNAL timer_done : STD_LOGIC;
  SIGNAL led_state : STD_LOGIC := '0';
  SIGNAL timer_reset : STD_LOGIC;
  SIGNAL timer_enable : STD_LOGIC;
  SIGNAL reset_internal : STD_LOGIC;

BEGIN

  -- Convert active-low button to active-high reset
  reset_internal <= NOT reset;

  -- Timer control logic
  -- Reset timer briefly when it completes, then let it run again
  PROCESS (clk, reset_internal)
  BEGIN
    IF reset_internal = '1' THEN
      timer_reset <= '1';
      timer_enable <= '0';
    ELSIF rising_edge(clk) THEN
      IF timer_done = '1' THEN
        -- Reset timer for one cycle, then re-enable
        timer_reset <= '1';
        timer_enable <= '0';
      ELSE
        timer_reset <= '0';
        timer_enable <= '1';
      END IF;
    END IF;
  END PROCESS;

  -- Timer instance
  timer_inst : timer
  GENERIC MAP(
    CLOCK_FREQ => CLOCK_FREQ,
    DURATION_SEC => DURATION_SEC
  )
  PORT MAP(
    clk => clk,
    reset => timer_reset,
    enable => timer_enable,
    done => timer_done
  );

  -- Toggle LED when timer completes
  PROCESS (clk, reset_internal)
  BEGIN
    IF reset_internal = '1' THEN
      led_state <= '0';
    ELSIF rising_edge(clk) THEN
      IF timer_done = '1' THEN
        led_state <= NOT led_state; -- Toggle
      END IF;
    END IF;
  END PROCESS;

  led_out <= led_state;

END ARCHITECTURE simple;