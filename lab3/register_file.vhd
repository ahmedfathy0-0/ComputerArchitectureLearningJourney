LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY register_file IS
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
END ENTITY register_file;

ARCHITECTURE sync_ram_with_write_priority OF register_file IS
    TYPE ram_type IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ram_array : ram_type := (OTHERS => (OTHERS => '0'));

BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            ram_array <= (OTHERS => (OTHERS => '0'));
        ELSIF rising_edge(clk) THEN
            IF write_enable = '1' THEN
                ram_array(to_integer(unsigned(address_write))) <= data_in;
            END IF;
        END IF;
    END PROCESS;

    data_out_a <= data_in WHEN write_enable = '1' AND address_read_a = address_write ELSE
                  ram_array(to_integer(unsigned(address_read_a)));

    data_out_b <= data_in WHEN write_enable = '1' AND address_read_b = address_write ELSE
                  ram_array(to_integer(unsigned(address_read_b)));

END ARCHITECTURE sync_ram_with_write_priority;