library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Display is
  Port (clk: IN STD_LOGIC;
        choice: IN STD_LOGIC;
        v1: IN STD_LOGIC_VECTOR(31 downto 0);
        v2: IN STD_LOGIC_VECTOR(31 downto 0);
        cathodes: OUT STD_LOGIC_VECTOR(6 downto 0);
        anodes: OUT STD_LOGIC_VECTOR(3 downto 0));
end Display;

architecture Behavioral of Display is

signal state1: integer := 0;
signal state2: integer := 0;
signal vec: STD_LOGIC_VECTOR(3 downto 0);
signal avec: STD_LOGIC_VECTOR(3 downto 0);
begin
    with vec select
       cathodes <= "1000000" when "0000",
                   "1111001" when "0001",
                   "0100100" when "0010",
                   "0110000" when "0011",
                   "0011001" when "0100",
                   "0010010" when "0101",
                   "0000010" when "0110",
                   "1111000" when "0111",
                   "0000000" when "1000",
                   "0010000" when "1001",
                   "0001000" when "1010",
                   "0000011" when "1011",
                   "1000110" when "1100",
                   "0100001" when "1101",
                   "0000110" when "1110",
                   "0001110" when "1111",
                   "1111111" when others;
    anodes<=avec;
    
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(choice = '0') then
                 if(state1 = 0) then 
                    vec <= v1(3 downto 0);
                    avec <= "1110";
                    state1 <= state1 + 1;
                 elsif(state1 = 1) then     
                    vec <= v1(7 downto 4);
                    avec <= "1101";
                    state1 <= state1 + 1;
                 elsif(state1 = 2) then 
                    vec <= v1(11 downto 8);
                    avec <= "1011";
                    state1 <= state1 + 1;
                 else
                    vec <= v1(15 downto 12);
                    avec <= "0111";
                    state1 <= 0;
                end if;
            else
                if(state2 = 0) then 
                    vec <= v2(3 downto 0);
                    avec <= "1110";
                    state2 <= state2 + 1;
                 elsif(state2 = 1) then     
                    vec <= v2(7 downto 4);
                    avec <= "1101";
                    state2 <= state2 + 1;
                 elsif(state2 = 2) then 
                    vec <= v2(11 downto 8);
                    avec <= "1011";
                    state2 <= state2 + 1;
                 else
                    vec <= v2(15 downto 12);
                    avec <= "0111";
                    state2 <= 0;
                end if;
            end if; 
        end if;
    end process;
   

end Behavioral;
