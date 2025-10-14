LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

-- D Flip-Flop Component
ENTITY dff_dff IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        d : IN STD_LOGIC;
        q : OUT STD_LOGIC
    );
END ENTITY dff_dff;

ARCHITECTURE behavioral OF dff_dff IS

BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            q <= '0';
        ELSIF rising_edge(clk) THEN
            q <= d;
        END IF;
    END PROCESS;
END ARCHITECTURE behavioral;