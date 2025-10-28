LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- Seven Segment Display Converter
-- Converts a 4-bit binary number (0-9) to seven segment display format
-- Active low outputs
--
-- Segment layout:
--      a
--     ---
--  f |   | b
--     -g-
--  e |   | c
--     ---
--      d

ENTITY ssd IS
  PORT (
    binary_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4-bit binary input (0-15)
    ssd_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) -- 7-segment output (active low)
  );
END ENTITY ssd;

ARCHITECTURE behavior OF ssd IS
BEGIN
  PROCESS (binary_in)
  BEGIN
    CASE binary_in IS
        -- Encoding: gfedcba (active low, so '0' = on, '1' = off)
      WHEN "0000" => ssd_out <= "1000000"; -- 0
      WHEN "0001" => ssd_out <= "1111001"; -- 1
      WHEN "0010" => ssd_out <= "0100100"; -- 2
      WHEN "0011" => ssd_out <= "0110000"; -- 3
      WHEN "0100" => ssd_out <= "0011001"; -- 4
      WHEN "0101" => ssd_out <= "0010010"; -- 5
      WHEN "0110" => ssd_out <= "0000010"; -- 6
      WHEN "0111" => ssd_out <= "1111000"; -- 7
      WHEN "1000" => ssd_out <= "0000000"; -- 8
      WHEN "1001" => ssd_out <= "0010000"; -- 9
      WHEN "1010" => ssd_out <= "0001000"; -- A
      WHEN "1011" => ssd_out <= "0000011"; -- b
      WHEN "1100" => ssd_out <= "1000110"; -- C
      WHEN "1101" => ssd_out <= "0100001"; -- d
      WHEN "1110" => ssd_out <= "0000110"; -- E
      WHEN "1111" => ssd_out <= "0001110"; -- F
      WHEN OTHERS => ssd_out <= "1111111"; -- Blank (all off)
    END CASE;
  END PROCESS;
END ARCHITECTURE behavior;