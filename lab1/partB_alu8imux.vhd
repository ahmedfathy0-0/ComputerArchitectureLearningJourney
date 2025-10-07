LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY partB_alu8imux IS
    PORT(
        A, B : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        S0, S1 : IN STD_LOGIC;
        F : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY partB_alu8imux;

ARCHITECTURE behavior OF partB_alu8imux IS
    SIGNAL A_int, B_int : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL F_int : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
    A_int <= A;
    B_int <= B;
    sel <= S1 & S0;
    
    PROCESS(A_int, B_int, sel)
    BEGIN
        CASE sel IS
            WHEN "00" => F_int <= A_int AND B_int;   
            WHEN "01" => F_int <= A_int OR B_int;    
            WHEN "10" => F_int <= NOT (A_int OR B_int); 
            WHEN "11" => F_int <= NOT A_int;          
            WHEN OTHERS => F_int <= (OTHERS => '0');
        END CASE;
    END PROCESS;
    
    F <= F_int;
END ARCHITECTURE behavior;
