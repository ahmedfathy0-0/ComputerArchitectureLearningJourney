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
            d : IN STD_LOGIC;
            q : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL d_gated : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL q_internal : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
    gen_dffs : FOR i IN 0 TO 7 GENERATE
        -- Mux: if en=1, use new data; if en=0, feedback old data
        d_gated(i) <= d(i) WHEN en = '1' ELSE
        q_internal(i);

        dff_inst : dff_dff
        PORT MAP(
            clk => clk,
            rst => rst,
            d => d_gated(i),
            q => q_internal(i)
        );
    END GENERATE gen_dffs;

    q <= q_internal;

END ARCHITECTURE structural;