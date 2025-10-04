LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY tb_ALU IS
END ENTITY;

ARCHITECTURE behavior OF tb_ALU IS
    SIGNAL A, B : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Cin : STD_LOGIC;
    SIGNAL S : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL F : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Cout : STD_LOGIC;

BEGIN
    -- Instantiate the ALU
    UUT: ENTITY work.ALU
        PORT MAP(
            A => A,
            B => B,
            Cin => Cin,
            S => S,
            F => F,
            Cout => Cout
        );

    -- Stimulus process
    stim_proc: PROCESS
    BEGIN
        -- Part B: AND, OR, NOR, NOT
        A <= "10101010"; B <= "11001100"; Cin <= '0';
        S <= "0100"; WAIT FOR 10 ns;  -- AND
        S <= "0101"; WAIT FOR 10 ns;  -- OR
        S <= "0110"; WAIT FOR 10 ns;  -- NOR
        S <= "0111"; WAIT FOR 10 ns;  -- NOT A

        -- Part C: Right shifts/rotates
        A <= "10110010"; Cin <= '1';
        S <= "1000"; WAIT FOR 10 ns;  -- Logic shift right
        S <= "1001"; WAIT FOR 10 ns;  -- Rotate right
        S <= "1010"; WAIT FOR 10 ns;  -- Rotate right with carry
        S <= "1011"; WAIT FOR 10 ns;  -- Arithmetic shift right

        -- Part D: Left shifts/rotates
        A <= "10110010"; Cin <= '1';
        S <= "1100"; WAIT FOR 10 ns;  -- Logic shift left
        S <= "1101"; WAIT FOR 10 ns;  -- Rotate left
        S <= "1110"; WAIT FOR 10 ns;  -- Rotate left with carry
        S <= "1111"; WAIT FOR 10 ns;  -- Output zero

        WAIT;
    END PROCESS;

END ARCHITECTURE behavior;
