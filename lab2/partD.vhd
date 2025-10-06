LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY partD_alsu IS
    GENERIC (n : INTEGER := 8);
    PORT (
        A : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        Cin : IN STD_LOGIC;
        S0, S1 : IN STD_LOGIC;
        F : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        Cout : OUT STD_LOGIC
    );
END ENTITY partD_alsu;

ARCHITECTURE behavior OF partD_alsu IS
    SIGNAL sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
    sel <= S1 & S0;

    PROCESS (A, Cin, sel)
        VARIABLE temp : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    BEGIN
        CASE sel IS
            WHEN "00" =>
                temp := A(n - 2 DOWNTO 0) & '0';
                Cout <= A(n - 1);
            WHEN "01" =>
                temp := A(n - 2 DOWNTO 0) & A(n - 1);
                Cout <= A(n - 1);
            WHEN "10" =>
                temp := A(n - 2 DOWNTO 0) & Cin;
                Cout <= A(n - 1);
            WHEN OTHERS =>
                temp := (OTHERS => '0');
                Cout <= '0';
        END CASE;
        F <= temp;
    END PROCESS;
END ARCHITECTURE behavior;