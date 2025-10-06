LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY full_adder_1_bit IS
    PORT (
        a, b, cin : IN STD_LOGIC;
        s, cout : OUT STD_LOGIC
    );
END full_adder_1_bit;

ARCHITECTURE a_1_bit_adder OF full_adder_1_bit IS
BEGIN
    s <= a XOR b XOR cin;
    cout <= (a AND b) OR (cin AND (a XOR b));
END a_1_bit_adder;

-- We need to add library declarations again for the second entity
-- Learnt this the hard way :<
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY full_adder_8_bit IS GENERIC (n : INTEGER := 8);
PORT (
    a, b : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    cin : IN STD_LOGIC;
    s : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    cout : OUT STD_LOGIC);
END full_adder_8_bit;

ARCHITECTURE an_8bit_full_adder OF full_adder_8_bit IS
    COMPONENT full_adder_1_bit IS
        PORT (
            a, b, cin : IN STD_LOGIC;
            s, cout : OUT STD_LOGIC);

    END COMPONENT;
    SIGNAL temp : STD_LOGIC_VECTOR(n DOWNTO 0);
BEGIN
    temp(0) <= cin;
    loop1 : FOR i IN 0 TO n - 1 GENERATE
        fx : full_adder_1_bit PORT MAP(a(i), b(i), temp(i), s(i), temp(i + 1));
    END GENERATE;
    cout <= temp(n);
END an_8bit_full_adder;