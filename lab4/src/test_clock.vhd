LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- Simple clock test - blinks LED using direct counter
-- No timer component needed - verifies clock is working
-- Should blink LED approximately every 0.67 seconds (2^26 / 50MHz)

ENTITY test_clock IS
  PORT (
    clk : IN STD_LOGIC;
    led_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) -- 4 LEDs for visual feedback
  );
END ENTITY test_clock;

ARCHITECTURE simple OF test_clock IS
  SIGNAL counter : unsigned(27 DOWNTO 0) := (OTHERS => '0');
BEGIN

  -- Simple counter on clock
  PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      counter <= counter + 1;
    END IF;
  END PROCESS;

  -- Output different bits to different LEDs
  -- If clock is working, these should blink at different rates
  led_out(0) <= counter(23); -- Blinks fast
  led_out(1) <= counter(24); -- Blinks medium
  led_out(2) <= counter(25); -- Blinks slow
  led_out(3) <= counter(26); -- Blinks very slow

END ARCHITECTURE simple;