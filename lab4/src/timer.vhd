LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Usage:
-- 1. Set reset = 0 and enable = 1 to start the timer.
--  1.1. Set enable = 0 to stop/resume the timer
-- 2. When 'done' output goes high, the specified duration has elapsed.
-- 3. Set reset = 1 to reset the timer.
-- Separate timer entity

ENTITY timer IS
    GENERIC (
        CLOCK_FREQ : INTEGER := 50_000_000;
        DURATION_SEC : INTEGER := 2
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        enable : IN STD_LOGIC; -- Start/stop timer
        done : OUT STD_LOGIC
    );
END timer;

ARCHITECTURE rtl OF timer IS
    SIGNAL counter : INTEGER RANGE 0 TO MAX_COUNT := 0;
BEGIN
    -- Single counter for the entire duration
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            counter <= 0;
        ELSIF rising_edge(clk) THEN
            IF enable = '0' THEN
                counter <= 0; -- Reset when disabled
            ELSIF counter < MAX_COUNT THEN
                counter <= counter + 1;
            END IF;
        END IF;
    END PROCESS;

    done <= '1' WHEN counter = MAX_COUNT ELSE
        '0';

END rtl;