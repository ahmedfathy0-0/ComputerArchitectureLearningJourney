LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY partB_alsu IS
    GENERIC (n : INTEGER := 8);
    PORT (
        A, B : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        S0, S1 : IN STD_LOGIC;
        F : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
    );
END ENTITY partB_alsu;

ARCHITECTURE behavior OF partB_alsu IS
    SIGNAL sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
    sel <= S1 & S0;

    PROCESS (A, B, sel)
    BEGIN
        CASE sel IS
            WHEN "00" =>
                F <= A AND B;
            WHEN "01" =>
                F <= A OR B;
            WHEN "10" =>
                F <= NOT (A OR B);
            WHEN OTHERS =>
                F <= NOT A;
        END CASE;
    END PROCESS;
END ARCHITECTURE behavior;