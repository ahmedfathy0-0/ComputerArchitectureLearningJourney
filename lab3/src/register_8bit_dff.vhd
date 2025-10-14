LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY register_8bit_dff IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        en : IN STD_LOGIC;
        d : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY register_8bit_dff;

ARCHITECTURE structural OF register_8bit_dff IS
    COMPONENT dff_dff
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            en : IN STD_LOGIC;
            d : IN STD_LOGIC;
            q : OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN
    gen_dffs : FOR i IN 0 TO 7 GENERATE
        dff_inst : dff_dff
        PORT MAP(
            clk => clk,
            rst => rst,
            en => en,
            d => d(i),
            q => q(i)
        );
    END GENERATE gen_dffs;
END ARCHITECTURE structural;