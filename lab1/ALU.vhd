LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ALU IS
    PORT (
        A, B : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        Cin : IN STD_LOGIC;
        S : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        F : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        Cout : OUT STD_LOGIC
    );
END ENTITY ALU;

ARCHITECTURE structural OF ALU IS
    SIGNAL F_B, F_C, F_D : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Cout_C, Cout_D : STD_LOGIC;
    SIGNAL sel : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN
    sel <= S(3 DOWNTO 2);

    U_PARTB : ENTITY work.partB_alsu
        PORT MAP(
            A => A,
            B => B,
            S0 => S(0),
            S1 => S(1),
            F => F_B
        );

    U_PARTC : ENTITY work.partC_alsu
        PORT MAP(
            A => A,
            Cin => Cin,
            S0 => S(0),
            S1 => S(1),
            F => F_C,
            Cout => Cout_C
        );

    U_PARTD : ENTITY work.partD_alsu
        PORT MAP(
            A => A,
            Cin => Cin,
            S0 => S(0),
            S1 => S(1),
            F => F_D,
            Cout => Cout_D
        );

    -- Select between parts based on S3 & S2
    PROCESS (F_B, F_C, F_D, Cout_C, Cout_D, sel)
    BEGIN
        CASE sel IS
            WHEN "01" => F <= F_B;
                Cout <= '0';
            WHEN "10" => F <= F_C;
                Cout <= Cout_C;
            WHEN "11" => F <= F_D;
                Cout <= Cout_D;
            WHEN OTHERS => F <= (OTHERS => '0');
                Cout <= '0';
        END CASE;
    END PROCESS;

END ARCHITECTURE structural;