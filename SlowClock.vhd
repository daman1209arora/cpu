library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SlowClock is
  Port (clk: IN STD_LOGIC;
        clkSlow : BUFFER STD_LOGIC := '0');
end SlowClock;

architecture Behavioral of SlowClock is
signal count : integer := 0;
begin
    process(clk) 
    begin
        if(rising_edge(clk)) then 
            if(count = 9999) then 
                count <= 0;
                clkSlow <= not(clkSlow);
            else
                count <= count + 1;
            end if;
        end if;
    end process;

end Behavioral;
