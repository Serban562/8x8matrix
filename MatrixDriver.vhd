----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/20/2024 03:00:48 AM
-- Design Name: 
-- Module Name: MatrixDriver - Behavioral
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

entity MatrixDriver is
    Port ( clk : in STD_LOGIC;
           DIN : in STD_LOGIC_VECTOR (63 downto 0);
           rst : in STD_LOGIC;
           out_bit: out STD_LOGIC);
end MatrixDriver;

architecture Behavioral of MatrixDriver is
signal clk1kHz : STD_LOGIC;
signal addr : STD_LOGIC_VECTOR(2 downto 0);
signal state : STD_LOGIC_VECTOR(16 downto 0);
signal dataout : STD_LOGIC_VECTOR (15 downto 0);
signal started: integer range 0 to 1;
component serial is
       Port ( dataout : in STD_LOGIC_VECTOR (15 downto 0);
              out_bit : out STD_LOGIC;
              clk : in STD_LOGIC;
              rst : in STD_LOGIC);
end component serial;
begin
div1kHz: process(clk, rst)
begin
   if rst = '1' then 
        state <= '0' & X"0000";
   else
     if rising_edge(clk) then
        if state = '1' & X"869F" then --if counte reaches 99999
            state <= '0' & X"0000"; -- reset back to 0
        else
            state <= state+1;
        end if;
     end if;
   end if;         
end process;

clk1Khz <= state(16);
counter_2bits: process(clk1kHz)
begin
  if rising_edge(clk1kHz) then       
           addr <= addr+1;   
  end if;   
end process;
dcd3_8: process(addr)
begin
if(started = 1)then
  case addr is 
      when "000" =>  dataout <= "00000000" & DIN(63 downto 56); 
      when "001" =>  dataout <= "00000001" & DIN(55 downto 48);       
      when "010" =>  dataout <= "00000010" & DIN(47 downto 40); 
      when "011" =>  dataout <= "00000011" & DIN(39 downto 32); 
      when "100" =>  dataout <= "00000100" & DIN(31 downto 24); 
      when "101" =>  dataout <= "00000101" & DIN(23 downto 16); 
      when "110" =>  dataout <= "00000110" & DIN(15 downto 8); 
      when "111" =>  dataout <= "00000111" & DIN(7 downto 0); 
      when others => dataout <= "0000000000000000";
   end case;
else
   dataout<="0000110000000001";
   started<=1;
end if; 
end process;

serial_v : serial port map( dataout => dataout,
                            out_bit=>out_bit,
                            clk =>clk,
                            rst =>rst);
end Behavioral;
