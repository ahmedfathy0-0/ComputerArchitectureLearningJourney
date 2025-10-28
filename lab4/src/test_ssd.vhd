LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Simple test entity for Seven Segment Display
-- Directly maps switches to SSD to verify pin connections
-- SW[3:0] controls which digit (0-9) is displayed on HEX0

ENTITY test_ssd IS
  PORT (
    floor_select : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Switches SW[3:0]
    ssd_floor : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) -- Seven segment display HEX0
  );
END ENTITY test_ssd;

ARCHITECTURE simple OF test_ssd IS

  COMPONENT ssd
    PORT (
      binary_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      ssd_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
  END COMPONENT;

BEGIN

  -- Directly connect switches to SSD
  ssd_inst : ssd
  PORT MAP(
    binary_in => floor_select,
    ssd_out => ssd_floor
  );

END ARCHITECTURE simple;