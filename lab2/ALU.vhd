LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ALU IS
    GENERIC (n : INTEGER := 8);
    PORT (
        A, B : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        Cin : IN STD_LOGIC;
        S : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        F : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        Cout : OUT STD_LOGIC
    );
END ENTITY ALU;

ARCHITECTURE structural OF ALU IS
    SIGNAL F_A, F_B, F_C, F_D : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL Cout_A, Cout_C, Cout_D : STD_LOGIC;
    SIGNAL sel : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN
    sel <= S(3 DOWNTO 2);

    U_PARTA : ENTITY work.partA_alsu
        GENERIC MAP(n => n)
        PORT MAP(
            A => A,
            B => B,
            Cin => Cin,
            Selector => S(1 DOWNTO 0),
            F => F_A,
            Cout => Cout_A
        );

    U_PARTB : ENTITY work.partB_alsu
        GENERIC MAP(n => n)
        PORT MAP(
            A => A,
            B => B,
            S0 => S(0),
            S1 => S(1),
            F => F_B
        );

    U_PARTC : ENTITY work.partC_alsu
        GENERIC MAP(n => n)
        PORT MAP(
            A => A,
            Cin => Cin,
            S0 => S(0),
            S1 => S(1),
            F => F_C,
            Cout => Cout_C
        );

    U_PARTD : ENTITY work.partD_alsu
        GENERIC MAP(n => n)
        PORT MAP(
            A => A,
            Cin => Cin,
            S0 => S(0),
            S1 => S(1),
            F => F_D,
            Cout => Cout_D
        );

    -- Select between parts based on S3 & S2
    -- Just formated it to be more readable
    PROCESS (F_A, F_B, F_C, F_D, Cout_A, Cout_C, Cout_D, sel)
    BEGIN
        CASE sel IS
            WHEN "00" =>
                F <= F_A;
                Cout <= Cout_A;
            WHEN "01" =>
                F <= F_B;
                Cout <= '0';
            WHEN "10" =>
                F <= F_C;
                Cout <= Cout_C;
            WHEN OTHERS =>
                F <= F_D;
                Cout <= Cout_D;
        END CASE;
    END PROCESS;

END ARCHITECTURE structural;