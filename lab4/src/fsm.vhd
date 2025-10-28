LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY elevator_fsm IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    floor_request : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    request_valid : IN STD_LOGIC;
    seven_segment : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    current_floor : OUT INTEGER RANGE 0 TO 9;
    door_status : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
  );
END ENTITY elevator_fsm;
ARCHITECTURE behavioral OF elevator_fsm IS

  TYPE state_type IS (IDLE, MV_UP, MV_DN, DOOR_OPEN);
  SIGNAL current_state, next_state : state_type;

  SIGNAL target_floor : INTEGER RANGE 0 TO 9 := 0;
  SIGNAL current_floor_internal : INTEGER RANGE 0 TO 9 := 0;
  SIGNAL door_timer : INTEGER RANGE 0 TO 2 := 0;

  CONSTANT seg_encoding : STD_LOGIC_VECTOR(6 DOWNTO 0) :=
  "0111111" & -- 0
  "0000110" & -- 1
  "1011011" & -- 2
  "1001111" & -- 3
  "1100110" & -- 4
  "1101101" & -- 5
  "1111101" & -- 6
  "0000111" & -- 7
  "1111111" & -- 8
  "1101111"; -- 9

BEGIN
  PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      current_state <= IDLE;
      current_floor_internal <= 0;
      target_floor <= 0;
      door_timer <= 0;
    ELSIF rising_edge(clk) THEN
      current_state <= next_state;

      IF request_valid = '1' THEN
        FOR i IN 0 TO 9 LOOP
          IF floor_request(i) = '1' THEN
            target_floor <= i;
            EXIT;
          END IF;
        END LOOP;
      END IF;

      CASE current_state IS
        WHEN MV_UP =>
          IF current_floor_internal < target_floor THEN
            current_floor_internal <= current_floor_internal + 1;
          END IF;
        WHEN MV_DN =>
          IF current_floor_internal > target_floor THEN
            current_floor_internal <= current_floor_internal - 1;
          END IF;
        WHEN DOOR_OPEN =>
          door_timer <= door_timer + 1;
        WHEN OTHERS =>
          door_timer <= 0;
      END CASE;
    END IF;
  END PROCESS;

  PROCESS (current_state, current_floor_internal, target_floor, door_timer)
  BEGIN
    CASE current_state IS
      WHEN IDLE =>
        IF current_floor_internal < target_floor THEN
          next_state <= MV_UP;
        ELSIF current_floor_internal > target_floor THEN
          next_state <= MV_DN;
        ELSE
          next_state <= DOOR_OPEN;
        END IF;

      WHEN MV_UP =>
        IF current_floor_internal = target_floor THEN
          next_state <= DOOR_OPEN;
        ELSE
          next_state <= MV_UP;
        END IF;

      WHEN MV_DN =>
        IF current_floor_internal = target_floor THEN
          next_state <= DOOR_OPEN;
        ELSE
          next_state <= MV_DN;
        END IF;

      WHEN DOOR_OPEN =>
        IF door_timer >= 2 THEN
          next_state <= IDLE;
        ELSE
          next_state <= DOOR_OPEN;
        END IF;

      WHEN OTHERS =>
        next_state <= IDLE;
    END CASE;
  END PROCESS;

  PROCESS (current_floor_internal, current_state)
  BEGIN
    seven_segment <= seg_encoding((floor * 7) + 6 DOWNTO floor * 7);
    current_floor <= current_floor_internal;

    door_status <= (OTHERS => '0');
    IF current_state = DOOR_OPEN THEN
      door_status(current_floor_internal) <= '1';
    END IF;
  END PROCESS;

END ARCHITECTURE behavioral;

