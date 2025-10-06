LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY partC_alsu IS
    GENERIC (n : INTEGER := 8);
    PORT (
        A : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        Cin : IN STD_LOGIC;
        S0, S1 : IN STD_LOGIC;
        F : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        Cout : OUT STD_LOGIC
    );
END ENTITY partC_alsu;

ARCHITECTURE behavior OF partC_alsu IS
    SIGNAL sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
    sel <= S1 & S0;

    PROCESS (A, Cin, sel)
        VARIABLE temp : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    BEGIN
        CASE sel IS
            WHEN "00" =>
                temp := '0' & A(n - 1 DOWNTO 1);
                Cout <= A(0);
            WHEN "01" =>
                temp := A(0) & A(n - 1 DOWNTO 1);
                Cout <= A(0);
            WHEN "10" =>
                temp := Cin & A(n - 1 DOWNTO 1);
                Cout <= A(0);
            WHEN OTHERS =>
                temp := A(n - 1) & A(n - 1 DOWNTO 1);
                Cout <= A(0);
        END CASE;
        F <= temp;
    END PROCESS;
END ARCHITECTURE behavior;