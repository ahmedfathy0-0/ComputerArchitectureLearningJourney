LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY partC_alu8imux IS
    PORT(
        A : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        Cin : IN STD_LOGIC;
        S0, S1 : IN STD_LOGIC;
        F : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        Cout : OUT STD_LOGIC
    );
END ENTITY partC_alu8imux;

ARCHITECTURE behavior OF partC_alu8imux IS
    SIGNAL sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
    sel <= S1 & S0;
    
    PROCESS(A, Cin, sel)
        VARIABLE temp : STD_LOGIC_VECTOR(7 DOWNTO 0);
    BEGIN
        CASE sel IS
            WHEN "00" =>  
                temp := '0' & A(7 DOWNTO 1);
                Cout <= A(0);
            WHEN "01" => 
                temp := A(0) & A(7 DOWNTO 1);
                Cout <= A(0);
            WHEN "10" =>  
                temp := Cin & A(7 DOWNTO 1);
                Cout <= A(0);
            WHEN "11" =>  
                temp := A(7) & A(7 DOWNTO 1);
                Cout <= A(0);
            WHEN OTHERS =>
                temp := (OTHERS => '0');
                Cout <= '0';
        END CASE;
        F <= temp;
    END PROCESS;
END ARCHITECTURE behavior;
