
library IEEE;                        
use IEEE.std_logic_1164.all;

-- Test bench interface is always empty.
entity P6502_RAM  is
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        display         : out std_logic_vector(7 downto 0);
        display_en_n    : out std_logic_vector(3 downto 0)
    );
end P6502_RAM;


-- Instantiate the components and generates the stimuli.
architecture behavioral of P6502_RAM is  
    
    signal rw, ce, we                       : std_logic;
    signal address                          : std_logic_vector(15 downto 0);
    signal RAMdata_in, RAMdata_out, dataBus : std_logic_vector(7 downto 0);
     
    signal reg1, reg2: std_logic_vector(7 downto 0);
    signal display0, display1, display2, display3: std_logic_vector(7 downto 0);
    
    function BCD7segments(number: in std_logic_vector(3 downto 0)) return std_logic_vector is
        variable display: std_logic_vector(7 downto 0);
    begin
        case number is
            when x"0" =>    display := "11000000";
            when x"1" =>    display := "11111001";
            when x"2" =>    display := "10100100";
            when x"3" =>    display := "10110000";
            when x"4" =>    display := "10011001";  
            when x"5" =>    display := "10010010";
            when x"6" =>    display := "10000011";
            when x"7" =>    display := "10111001";
            when x"8" =>    display := "10000000";
            when x"9" =>    display := "10011000";
            when x"A" =>    display := "10001000";
            when x"b" =>    display := "10000011";
            when x"C" =>    display := "11000110";
            when x"d" =>    display := "10100001";
            when x"E" =>    display := "10000110";
            when x"F" =>    display := "10001110";
            when others =>  display := "11111111";
        end case;
        return display;
    end BCD7segments;
    
begin
    
    -- 6502 processor
    P6502: entity work.P6502 
        port map (
            clk         => clk,
            rst         => rst,
            ce          => ce,
            rw          => rw,
            data        => dataBus,
            address     => address
        );
        
    -- Program/Data memory
     RAM: entity work.Memory(block_ram) -- or block_ram architecture for synthesis
        generic map (
            DATA_WIDTH    => 8,
            ADDR_WIDTH    => 16
        )
        port map (
            clk         => clk,
            we          => we,
            data_in     => dataBus,
            data_out    => RAMdata_out,
            address     => address
        );
        
    DISPLAY_CONTROL: entity work.DisplayCtrl
        port map (
            clk             => clk,
            rst             => rst,
            segments        => display,
            display_en_n    => display_en_n,
            display0        => display0,  -- Left most  display
            display1        => display1, 
            display2        => display2,  
            display3        => display3   -- Right most display
        );
     
     
    we <= '1' when ce = '1' and rw = '0' else '0';
    dataBus <= RAMdata_out when ce = '1' and rw = '1' else (others=>'Z');
    
    process(clk,rst)
    begin
        if rst = '1' then
            reg1 <= (others=>'0');
            reg2 <= (others=>'1');
        
        elsif rising_edge(clk) then
            if address = x"1000" and we = '1' then
                reg1 <= dataBus;
            end if;
            
            if address = x"1001" and we = '1' then
                reg2 <= dataBus;
            end if;
        end if;
    end process;
    
    display0 <= BCD7segments(reg2(3 downto 0));
    display1 <= BCD7segments(reg2(7 downto 4));
    display2 <= BCD7segments(reg1(3 downto 0));
    display3 <= BCD7segments(reg1(7 downto 4));
     
        
end behavioral;


