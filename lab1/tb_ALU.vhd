LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

ENTITY tb_ALU IS
END ENTITY;

ARCHITECTURE behavior OF tb_ALU IS
    SIGNAL A, B : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Cin : STD_LOGIC;
    SIGNAL S : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL F : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Cout : STD_LOGIC;

    PROCEDURE print_result(
        operation : STRING;
        a_val, b_val, f_val : STD_LOGIC_VECTOR(7 DOWNTO 0);
        cin_val, cout_val : STD_LOGIC;
        s_val : STD_LOGIC_VECTOR(3 DOWNTO 0)
    ) IS
        VARIABLE l : LINE;
    BEGIN
        write(l, STRING'("Time: "));
        write(l, NOW);
        write(l, STRING'(" | Op: "));
        write(l, operation);
        write(l, STRING'(" | S="));
        write(l, s_val);
        write(l, STRING'(" | A="));
        hwrite(l, a_val);
        write(l, STRING'(" | B="));
        hwrite(l, b_val);
        write(l, STRING'(" | Cin="));
        write(l, cin_val);
        write(l, STRING'(" | F="));
        hwrite(l, f_val);
        write(l, STRING'(" | Cout="));
        write(l, cout_val);
        writeline(OUTPUT, l);
    END PROCEDURE;

BEGIN
    UUT: ENTITY work.ALU
        PORT MAP(
            A => A,
            B => B,
            Cin => Cin,
            S => S,
            F => F,
            Cout => Cout
        );

    stim_proc: PROCESS
    BEGIN
        REPORT "========== Starting ALU Testbench ==========" SEVERITY NOTE;
        
        REPORT "--- Part B: Logic Operations ---" SEVERITY NOTE;
        A <= X"F5"; B <= X"AA"; Cin <= '0';
        
        S <= "0100"; WAIT FOR 10 ns;  -- AND
        print_result("AND      ", A, B, F, Cin, Cout, S);
        ASSERT F = X"A0" REPORT "AND operation failed!" SEVERITY ERROR;
        
        S <= "0101"; WAIT FOR 10 ns;  -- OR
        print_result("OR       ", A, B, F, Cin, Cout, S);
        ASSERT F = X"FF" REPORT "OR operation failed!" SEVERITY ERROR;
        
        S <= "0110"; WAIT FOR 10 ns;  -- NOR
        print_result("NOR      ", A, B, F, Cin, Cout, S);
        ASSERT F = X"00" REPORT "NOR operation failed!" SEVERITY ERROR;
        
        S <= "0111"; WAIT FOR 10 ns;  -- NOT A
        print_result("NOT A    ", A, B, F, Cin, Cout, S);
        ASSERT F = X"0A" REPORT "NOT A operation failed!" SEVERITY ERROR;

        REPORT "--- Part C: Right Shift/Rotate Operations ---" SEVERITY NOTE;
        A <= X"F5"; B <= X"00"; Cin <= '0';
        
        S <= "1000"; WAIT FOR 10 ns;  -- Logic shift right
        print_result("LSR      ", A, B, F, Cin, Cout, S);
        ASSERT F = X"7A" REPORT "Logic shift right failed!" SEVERITY ERROR;
        ASSERT Cout = '1' REPORT "LSR Cout failed!" SEVERITY ERROR;
        
        S <= "1001"; WAIT FOR 10 ns;  -- Rotate right
        print_result("ROR      ", A, B, F, Cin, Cout, S);
        ASSERT F = X"FA" REPORT "Rotate right failed!" SEVERITY ERROR;
        ASSERT Cout = '1' REPORT "ROR Cout failed!" SEVERITY ERROR;
        
        -- Rotate right with carry, Cin=0
        Cin <= '0';
        S <= "1010"; WAIT FOR 10 ns;
        print_result("RRC(Cin=0)", A, B, F, Cin, Cout, S);
        ASSERT F = X"7A" REPORT "Rotate right with carry (Cin=0) failed!" SEVERITY ERROR;
        ASSERT Cout = '1' REPORT "RRC(Cin=0) Cout failed!" SEVERITY ERROR;
        
        -- Rotate right with carry, Cin=1
        Cin <= '1';
        S <= "1010"; WAIT FOR 10 ns;
        print_result("RRC(Cin=1)", A, B, F, Cin, Cout, S);
        ASSERT F = X"FA" REPORT "Rotate right with carry (Cin=1) failed!" SEVERITY ERROR;
        ASSERT Cout = '1' REPORT "RRC(Cin=1) Cout failed!" SEVERITY ERROR;
        
        S <= "1011"; WAIT FOR 10 ns;  -- Arithmetic shift right
        print_result("ASR      ", A, B, F, Cin, Cout, S);
        ASSERT F = X"FA" REPORT "Arithmetic shift right failed!" SEVERITY ERROR;
        ASSERT Cout = '1' REPORT "ASR Cout failed!" SEVERITY ERROR;

        -- Part D: Left shifts/rotates (A=F5)
        REPORT "--- Part D: Left Shift/Rotate Operations ---" SEVERITY NOTE;
        A <= X"F5"; B <= X"00"; Cin <= '0';
        
        S <= "1100"; WAIT FOR 10 ns;  -- Logic shift left
        print_result("LSL      ", A, B, F, Cin, Cout, S);
        ASSERT F = X"EA" REPORT "Logic shift left failed!" SEVERITY ERROR;
        ASSERT Cout = '1' REPORT "LSL Cout failed!" SEVERITY ERROR;
        
        S <= "1101"; WAIT FOR 10 ns;  -- Rotate left
        print_result("ROL      ", A, B, F, Cin, Cout, S);
        ASSERT F = X"EB" REPORT "Rotate left failed!" SEVERITY ERROR;
        ASSERT Cout = '1' REPORT "ROL Cout failed!" SEVERITY ERROR;
        
        -- Rotate left with carry, Cin=0
        Cin <= '0';
        S <= "1110"; WAIT FOR 10 ns;
        print_result("RLC(Cin=0)", A, B, F, Cin, Cout, S);
        ASSERT F = X"EA" REPORT "Rotate left with carry (Cin=0) failed!" SEVERITY ERROR;
        ASSERT Cout = '1' REPORT "RLC(Cin=0) Cout failed!" SEVERITY ERROR;
        
        Cin <= '1';
        S <= "1110"; WAIT FOR 10 ns;
        print_result("RLC(Cin=1)", A, B, F, Cin, Cout, S);
        ASSERT F = X"EB" REPORT "Rotate left with carry (Cin=1) failed!" SEVERITY ERROR;
        ASSERT Cout = '1' REPORT "RLC(Cin=1) Cout failed!" SEVERITY ERROR;
        
        S <= "1111"; WAIT FOR 10 ns;  -- Output zero
        print_result("ZERO     ", A, B, F, Cin, Cout, S);
        ASSERT F = X"00" REPORT "Zero output failed!" SEVERITY ERROR;
        ASSERT Cout = '0' REPORT "Zero Cout failed!" SEVERITY ERROR;

        REPORT "--- Additional Test ---" SEVERITY NOTE;
        A <= X"7A"; B <= X"00"; Cin <= '0';
        S <= "1001"; WAIT FOR 10 ns;  -- Rotate right
        print_result("ROR(7A)  ", A, B, F, Cin, Cout, S);
        ASSERT F = X"3D" REPORT "Rotate right (7A) failed!" SEVERITY ERROR;
        ASSERT Cout = '0' REPORT "ROR(7A) Cout failed!" SEVERITY ERROR;

        REPORT "========== ALU Testbench Complete ==========" SEVERITY NOTE;
        WAIT;
    END PROCESS;

END ARCHITECTURE behavior;