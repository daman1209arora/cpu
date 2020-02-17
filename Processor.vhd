library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Processor is
  Port (
        clk :IN STD_Logic ;
        start: IN STD_LOGIC := '0';
        cathodes: OUT STD_LOGIC_VECTOR(6 downto 0);
        anodes: OUT STD_LOGIC_VECTOR(3 downto 0);
        choice: IN STD_LOGIC);
end Processor;


architecture Behavioral of Processor is 
	signal count : integer := 0;
	signal ena :std_logic := '0';
	signal wea :std_logic_vector(0 downto 0) := "0";
	signal temp :integer :=0;
	signal addra: std_logic_vector(11 downto 0) := "000000000000";
	signal din,dout :std_logic_vector(31 downto 0);
	signal change : std_logic := '0';
	type RF_type is array (0 to 31) of std_logic_vector (31 downto 0);
	signal registerFile : RF_type := (others => (others => '0'));
	
    COMPONENT BlockRAM PORT(    clka : IN STD_LOGIC;
                                ena : IN STD_LOGIC;
                                wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
                                addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
                                dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                                douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); 
    END COMPONENT;
    
    COMPONENT SlowClock PORT(  clk: IN STD_LOGIC;
                                clkSlow: BUFFER STD_LOGIC);
    END COMPONENT;
    
    COMPONENT Display PORT(     clk: IN STD_LOGIC;
                                choice: IN STD_LOGIC;
                                v1: IN STD_LOGIC_VECTOR(31 downto 0);
                                v2: IN STD_LOGIC_VECTOR(31 downto 0);
                                cathodes: OUT STD_LOGIC_VECTOR(6 downto 0);
                                anodes: OUT STD_LOGIC_VECTOR(3 downto 0));
    END COMPONENT;
    signal clkSlow : std_logic;
    signal instrCount : integer := 0;
	signal wrAddr : std_logic_vector(4 downto 0);
	type stateType is (idle, latent, readInstr, stopped, waitState, lw1, lw2, sw1, sw2, errorState);
	signal state : stateType := idle;	
	signal zero: std_logic_vector(31 downto 0) := (others => '0');
	signal last, instrCountVector: std_logic_vector (31 downto 0) := (others => '0');
	begin
    Memory: BlockRAM PORT MAP(  clka => clk,       
                                ena => ena,
                                wea => wea,
                                addra => addra,
                                dina => din,
                                douta => dout);
                                
    DisplayClock: SlowClock PORT MAP(   clk => clk,
                                        clkSlow =>clkSlow);
                                        
    SevenSeg: Display PORT MAP( clk => clkSlow,
                                choice => choice,
                                v1 => last,
                                v2 => instrCountVector,
                                cathodes => cathodes,
                                anodes => anodes);
                                
    instrCountVector <=  std_logic_vector(to_unsigned(instrCount, 32));
	process(clk)
	begin
        if(rising_edge(clk)) then 
            if(state = idle) then
                if(start = '1') then
                   ena <= '1';
                   addra <= std_logic_vector(to_unsigned(count, 12));
                   state <= latent;
                end if;
            elsif(state = latent) then 
                 instrCount <= 1;
                 state <= readInstr;
            elsif(state = readInstr) then 
                if(dout(31 downto 26) = "000000" and dout(5 downto 0) = "100000") then 
                    registerFile(to_integer(unsigned(dout(15 downto 11)))) <= registerFile(to_integer(unsigned(dout(25 downto 21)))) + registerFile(to_integer(unsigned(dout(20 downto 16))));
                    last <= registerFile(to_integer(unsigned(dout(25 downto 21)))) + registerFile(to_integer(unsigned(dout(20 downto 16))));
                    addra <= addra + 1;
                    count <= count + 1;
                    instrCount <= instrCount + 2;
                    state <= waitState;
                elsif(dout(31 downto 26) = "000000" and dout(5 downto 0) = "100010") then 
                    registerFile(to_integer(unsigned(dout(15 downto 11)))) <= registerFile(to_integer(unsigned(dout(25 downto 21)))) - registerFile(to_integer(unsigned(dout(20 downto 16))));
                    last <= registerFile(to_integer(unsigned(dout(25 downto 21)))) - registerFile(to_integer(unsigned(dout(20 downto 16))));
                    addra <= addra + 1;
                    count <= count + 1;
                    instrCount <= instrCount + 2;
                    state <= waitState;
                elsif(dout(31 downto 26) = "000000" and dout(5 downto 0) = "000000" and not(dout = zero)) then
                    registerFile(to_integer(unsigned(dout(15 downto 11)))) <= std_logic_vector(shift_left(signed(registerFile(to_integer(unsigned(dout(20 downto 16))))), to_integer(unsigned(dout(10 downto 6)))));
                    --registerFile(to_integer(unsigned(dout(15 downto 11)))) <= registerFile(to_integer(unsigned(dout(20 downto 16))))((31 - to_integer(unsigned(dout(10 downto 6)))) downto 0) & zero((to_integer(unsigned(dout(10 downto 6))) - 1) downto 0);
                    last <= std_logic_vector(shift_left(signed(registerFile(to_integer(unsigned(dout(20 downto 16))))), to_integer(unsigned(dout(10 downto 6)))));
                    addra <= addra+1;
                    count <= count + 1;
                    instrCount <= instrCount + 2;
                    state <= waitState;
                elsif(dout(31 downto 26) = "000000" and dout(5 downto 0) = "000010") then 
                    registerFile(to_integer(unsigned(dout(15 downto 11)))) <= std_logic_vector(shift_right(signed(registerFile(to_integer(unsigned(dout(20 downto 16))))), to_integer(unsigned(dout(10 downto 6)))));
                    --registerFile(to_integer(unsigned(dout(15 downto 11)))) <= registerFile(to_integer(unsigned(dout(20 downto 16))))((31 - to_integer(unsigned(dout(10 downto 6)))) downto 0) & zero((to_integer(unsigned(dout(10 downto 6))) - 1) downto 0);
                    last <= std_logic_vector(shift_right(signed(registerFile(to_integer(unsigned(dout(20 downto 16))))), to_integer(unsigned(dout(10 downto 6)))));
                    --registerFile(to_integer(unsigned(dout(15 downto 11)))) <=  zero(to_integer(unsigned(dout(10 downto 6))) - 1 downto 0) & registerFile(to_integer(unsigned(dout(20 downto 16))))(31 downto to_integer(unsigned(dout(10 downto 6))));
                    --last <= zero(to_integer(unsigned(dout(10 downto 6))) - 1 downto 0) & registerFile(to_integer(unsigned(dout(20 downto 16))))(31 downto to_integer(unsigned(dout(10 downto 6))));
                    addra <= addra + 1;
                    count <= count + 1;
                    instrCount <= instrCount + 2;
                    state <= waitState;
                elsif(dout(31 downto 26) = "101011") then 
                    addra <= std_logic_vector(to_unsigned(to_integer(unsigned(dout(15 downto 0))) + to_integer(unsigned(registerFile(to_integer(unsigned(dout(25 downto 21)))))), 12));
                    last <= registerFile(to_integer(unsigned(dout(20 downto 16))));
                    wea <= "1";
                    din <= registerFile(to_integer(unsigned(dout(20 downto 16))));
                    state <= sw1;
                    instrCount <= instrCount + 3;
                elsif(dout(31 downto 26) = "100011") then 
                    addra <= std_logic_vector(to_unsigned((to_integer(unsigned(dout(15 downto 0))) + to_integer(unsigned(registerFile(to_integer(unsigned(dout(25 downto 21))))))),12));
                    wrAddr <= dout(20 downto 16);
                    state <= lw1;
                    instrCount <= instrCount + 3;
                elsif(dout = zero) then 
                   state <= stopped;
                else 
                   state <= errorState;
                end if;
            elsif(state = waitState) then 
                state <= readInstr;
            elsif(state = sw1) then 
                addra <= std_logic_vector(to_unsigned(count + 1, 12));
                count <= count+1;
                wea <= "0";
                state <= sw2;
            elsif(state = sw2) then 
                state <= readInstr;
            elsif(state = lw1) then
                addra <= std_logic_vector(to_unsigned(count + 1, 12));
                count <= count + 1; 
                state <= lw2;
            elsif(state = lw2) then
                registerFile((to_integer(unsigned(wrAddr)))) <= dout;
                last <= registerFile((to_integer(unsigned(wrAddr))));
                state <= readInstr;
            end if;
        end if;
	end process;
end Behavioral;
