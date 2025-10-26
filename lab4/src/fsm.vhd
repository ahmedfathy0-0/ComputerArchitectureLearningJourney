library ieee;
use ieee.std_logic_1164.all;

entity elevator_fsm is
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        floor_request   : in  std_logic_vector(9 downto 0);  
        request_valid   : in  std_logic;                     
        seven_segment   : out std_logic_vector(6 downto 0);   
        current_floor   : out integer range 0 to 9;          
        door_status     : out std_logic_vector(9 downto 0)    
    );
end entity elevator_fsm;


architecture behavioral of elevator_fsm is

    type state_type is (IDLE, MV_UP, MV_DN, DOOR_OPEN);
    signal current_state, next_state : state_type;

    signal target_floor : integer range 0 to 9 := 0;
    signal floor       : integer range 0 to 9 := 0;
    signal door_timer  : integer range 0 to 2 := 0;  

    constant seg_encoding : std_logic_vector(6 downto 0) := 
        "0111111" &  -- 0
        "0000110" &  -- 1
        "1011011" &  -- 2
        "1001111" &  -- 3
        "1100110" &  -- 4
        "1101101" &  -- 5
        "1111101" &  -- 6
        "0000111" &  -- 7
        "1111111" &  -- 8
        "1101111";   -- 9

begin

    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
            floor <= 0;
            target_floor <= 0;
            door_timer <= 0;
        elsif rising_edge(clk) then
            current_state <= next_state;

            if request_valid = '1' then
                for i in 0 to 9 loop
                    if floor_request(i) = '1' then
                        target_floor <= i;
                        exit;
                    end if;
                end loop;
            end if;

            case current_state is
                when MV_UP =>
                    if floor < target_floor then
                        floor <= floor + 1;
                    end if;
                when MV_DN =>
                    if floor > target_floor then
                        floor <= floor - 1;
                    end if;
                when DOOR_OPEN =>
                    door_timer <= door_timer + 1;  
                when others =>
                    door_timer <= 0; 
            end case;
        end if;
    end process;

    process(current_state, floor, target_floor, door_timer)
    begin
        case current_state is
            when IDLE =>
                if floor < target_floor then
                    next_state <= MV_UP;
                elsif floor > target_floor then
                    next_state <= MV_DN;
                else
                    next_state <= DOOR_OPEN;
                end if;

            when MV_UP =>
                if floor = target_floor then
                    next_state <= DOOR_OPEN;
                else
                    next_state <= MV_UP;
                end if;

            when MV_DN =>
                if floor = target_floor then
                    next_state <= DOOR_OPEN;
                else
                    next_state <= MV_DN;
                end if;

            when DOOR_OPEN =>
                if door_timer >= 2 then
                    next_state <= IDLE;
                else
                    next_state <= DOOR_OPEN;
                end if;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    process(floor, current_state)
    begin
        seven_segment <= seg_encoding((floor * 7) + 6 downto floor * 7);
        current_floor <= floor;
        
        door_status <= (others => '0');  
        if current_state = DOOR_OPEN then
            door_status(floor) <= '1';   
        end if;
    end process;

end architecture behavioral;


