LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY register_file_dff IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        write_enable : IN STD_LOGIC;
        address_write : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        address_read_a : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        address_read_b : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        data_out_a : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        data_out_b : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY register_file_dff;

ARCHITECTURE structural_dff OF register_file_dff IS
    COMPONENT register_8bit_dff
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            en : IN STD_LOGIC;
            d : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    TYPE register_outputs IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL reg_out : register_outputs;
    SIGNAL reg_enable : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
    --that for enabling that targeted register only
    PROCESS (write_enable, address_write)
    BEGIN
        reg_enable <= (OTHERS => '0');
        IF write_enable = '1' THEN
            reg_enable(to_integer(unsigned(address_write))) <= '1';
        END IF;
    END PROCESS;
    -- Generate 8 registers, each 8 bits wide
    gen_registers : FOR i IN 0 TO 7 GENERATE
        reg_inst : register_8bit_dff
        PORT MAP(
            clk => clk,
            rst => rst,
            en => reg_enable(i),
            d => data_in,
            q => reg_out(i)
        );
    END GENERATE gen_registers;

    data_out_a <= reg_out(to_integer(unsigned(address_read_a)));

    data_out_b <= reg_out(to_integer(unsigned(address_read_b)));

END ARCHITECTURE structural_dff;