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
    SIGNAL clk_1sec_counter : INTEGER RANGE 0 TO CLOCK_FREQ - 1;
    SIGNAL clk_1sec_enable : STD_LOGIC;
    SIGNAL sec_counter : INTEGER RANGE 0 TO DURATION_SEC;
BEGIN
    -- 1 Hz clock enable generator
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            clk_1sec_counter <= 0;
            clk_1sec_enable <= '0';
        ELSIF rising_edge(clk) THEN
            IF clk_1sec_counter = CLOCK_FREQ - 1 THEN
                clk_1sec_counter <= 0;
                clk_1sec_enable <= '1';
            ELSE
                clk_1sec_counter <= clk_1sec_counter + 1;
                clk_1sec_enable <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Second counter
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            sec_counter <= 0;
        ELSIF rising_edge(clk) THEN
            IF enable = '0' THEN
                sec_counter <= 0; -- Reset when disabled
            ELSIF clk_1sec_enable = '1' THEN
                IF sec_counter < DURATION_SEC THEN
                    sec_counter <= sec_counter + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    done <= '1' WHEN sec_counter = DURATION_SEC ELSE
        '0';
END rtl;