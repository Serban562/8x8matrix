----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/20/2024 03:18:32 AM
-- Design Name: 
-- Module Name: fsm - Behavioral
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

entity fsm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (2 downto 0);
            out_bit: out STD_LOGIC;
            clk16kHz : out STD_LOGIC
            );
end fsm;

architecture Behavioral of fsm is
type states is(start,left_light_off, right_light_off, hazard_light_off , left_light, right_light, hazard_light);
signal current_state, next_state : states;
signal matrix: STD_LOGIC_VECTOR(63 downto 0);
signal state : STD_LOGIC_VECTOR(12 downto 0) := (others => '0');
component MatrixDriver is
      Port ( clk : in STD_LOGIC;
           DIN : in STD_LOGIC_VECTOR (63 downto 0);
           rst : in STD_LOGIC;
           out_bit: out STD_LOGIC);
end component MatrixDriver;
begin
ff : process(rst, clk)
begin
  if rst = '1' then
    current_state <= start;
  elsif rising_edge(clk) then
    current_state <= next_state;  
  end if;
end process;
process(clk, rst)
    begin
        if rst = '1' then
            state <= (others => '0');
        else
            if rising_edge(clk) then
                if state = "110000111001" then -- if counter reaches 6249
                    state <= (others => '0');   -- reset back to 0
                else
                    state <= state + 1;
                end if;
            end if;
        end if;
    end process;

    clk16kHz <= state (12);  -- Output clk_2 signal
clc : process(current_state, sw)
begin
  case current_state is 
     when start => if sw(0)='1' then
                   next_state<=left_light;
                   end if;
                   if sw(1)='1' then
                   next_state <=hazard_light;
                   end if;
                   if sw(2)='1' then
                   next_state <= right_light;
                   end if;
     when left_light => if sw(0)='0' then
                        next_state <=left_light_off;
                        else
                        next_state <=left_light;
                        end if;
     when left_light_off => next_state <=start;
      when right_light =>
      if sw(2) = '0' then
        next_state <= right_light_off;
      else
        next_state <= right_light;
      end if;
      
    when right_light_off =>
      next_state <= start;
      
    when hazard_light =>
      if sw(1) = '0' then
        next_state <= hazard_light_off;
      else
        next_state <= hazard_light;
      end if;
      
    when hazard_light_off =>
      next_state <= start;
     when others =>next_state <= start;                      
  end case;
end process;
left_lighting:process(rst, clk)
begin
   if rst='1' then
   matrix <= x"0000000000000000";
   elsif rising_edge(clk) then
      if current_state=left_light then
        matrix <= "00000100"&
                  "00000110"&
                  "00000110"&
                  "00000111"&
                  "00000111"&
                  "00000110"&
                  "00000110"&
                  "00000100";
      elsif current_state=left_light_off then
         matrix <= x"0000000000000000";
      end if;
   end if;                  
end process;
right_lighting: process(rst, clk)
begin
  if rst = '1' then
    matrix <= x"0000000000000000";
  elsif rising_edge(clk) then
    if current_state = right_light then
      matrix <= "00100000" &
                "01100000" &
                "01100000" &
                "11100000" &
                "11100000" &
                "01100000" &
                "01100000" &
                "00100000";
    elsif current_state = right_light_off then
      matrix <= x"0000000000000000";
    end if;
  end if;
end process;
hazard_lighting: process(rst, clk)
begin
  if rst = '1' then
    matrix <= x"0000000000000000";
  elsif rising_edge(clk) then
    if current_state = hazard_light then
      matrix <= "00100100" &
                "01100110" &
                "01100110" &
                "11100111" &
                "11100111" &
                "01100110" &
                "01100110" &
                "00100100";
    elsif current_state = hazard_light_off then
      matrix <= x"0000000000000000";
    end if;
  end if;
end process;
mDrive : MatrixDriver port map(clk=>clk,
                               DIN => matrix,
                               rst =>rst,
                               out_bit =>out_bit);
end Behavioral;
