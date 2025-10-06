LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY partA_alsu IS
    GENERIC (n : INTEGER := 8);
    PORT (
        A, B : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        cin : IN STD_LOGIC;
        selector : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        F : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        Cout : OUT STD_LOGIC
    );
END partA_alsu;

ARCHITECTURE arch_part_a OF partA_alsu IS
    -- Signals for adder inputs
    SIGNAL A_int, B_int : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL Cin_int : STD_LOGIC;
BEGIN
    PROCESS (A, B, cin, selector)
    BEGIN
        CASE selector IS
            WHEN "00" =>
                -- F = A (cin=0) or F = A+1 (cin=1)
                A_int <= A;
                B_int <= (OTHERS => '0');
                Cin_int <= cin;

            WHEN "01" =>
                -- F = A+B (cin=0) or F = A+B+1 (cin=1)
                A_int <= A;
                B_int <= B;
                Cin_int <= cin;

            WHEN "10" =>
                -- F = A-B-1 (cin=0) or F = A-B (cin=1)
                -- A - B - 1 = A + NOT B + 0
                -- A - B = A + NOT B + 1
                A_int <= A;
                B_int <= NOT B;
                Cin_int <= cin;

            WHEN "11" =>
                -- F = A-1 (cin=0) or F = 0 (cin=1)
                IF cin = '0' THEN
                    -- A - 1 = A + (all 1's) + 0
                    A_int <= A;
                    B_int <= (OTHERS => '1');
                    Cin_int <= '0';
                ELSE
                    -- F = 0: Simply add 0 + 0 + 0
                    A_int <= (OTHERS => '0');
                    B_int <= (OTHERS => '0');
                    Cin_int <= '0';
                END IF;

            WHEN OTHERS =>
                A_int <= (OTHERS => '0');
                B_int <= (OTHERS => '0');
                Cin_int <= '0';
        END CASE;
    END PROCESS;

    full_adder : ENTITY work.full_adder_8_bit
        GENERIC MAP(n => n)
        PORT MAP(
            a => A_int,
            b => B_int,
            cin => Cin_int,
            s => F,
            cout => Cout
        );
END arch_part_a;