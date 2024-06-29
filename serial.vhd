----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/20/2024 12:49:51 PM
-- Design Name: 
-- Module Name: serial - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity serial is
    Port ( dataout : in STD_LOGIC_VECTOR (15 downto 0);
           out_bit : out STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC);
end serial;

architecture Behavioral of serial is
signal clk16kHz : STD_LOGIC;
signal state : STD_LOGIC_VECTOR(12 downto 0) := (others => '0');  -- 13 bits to count to 6249
signal i : integer range 0 to 15;
begin
process(clk, rst)
    begin
        if rst = '1' then
            state <= (others => '0');
        else
            if rising_edge(clk) then
                if state = "110000111001" then -- if counter reaches 6249
                    state <= (others => '0');   -- reset back to 0
                else
                    state <= state  + 1;
                end if;
            end if;
        end if;
    end process;

    clk16kHz <= state (12);  -- Output clk_2 signal
setbit: process(rst, clk16kHz)
begin
    if rst = '1' then
       i <= 0;
    elsif rising_edge(clk16kHz) then
       out_bit <= dataout(i);
       if i=15 then
         i <=0;
       else
         i <= i +1;
         end if;
    end if;
end process;
end Behavioral;
