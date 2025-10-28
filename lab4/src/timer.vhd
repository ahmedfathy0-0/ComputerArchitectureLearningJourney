LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

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
BEGIN
    PROCESS (clk, reset)
        VARIABLE counter : INTEGER RANGE 0 TO CLOCK_FREQ * DURATION_SEC - 1 := 0;
    BEGIN
        IF reset = '1' THEN
            counter := 0;
        ELSIF rising_edge(clk) THEN
            IF enable = '1' THEN
                IF counter < CLOCK_FREQ * DURATION_SEC - 1 THEN
                    counter := counter + 1;
                ELSE
                    counter := 0;
                END IF;
            END IF;
        END IF;

        -- Immediate assignment (reflects variable’s updated value)
        IF counter = CLOCK_FREQ * DURATION_SEC - 1 THEN
            done <= '1';
        ELSE
            done <= '0';
        END IF;
    END PROCESS;
END rtl;