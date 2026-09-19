--------------------------------------------------------------------------------
-- Copyright (c) 2023 by BittWare, A Molex Company
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--------------------------------------------------------------------------------
--      UNCLASSIFIED//FOR OFFICIAL USE ONLY
--------------------------------------------------------------------------------
-- Title       : Arbiter
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : Top level of arbiter.
--
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity arbiter is
  port (
    clk                 : in  std_logic                     := '0';  -- clock.clk
    reset               : in  std_logic                     := '0';  -- reset.reset
    pcie_s0_address     : in  std_logic_vector(1 downto 0)  := (others => '0');  --    s0.address
    pcie_s0_read        : in  std_logic                     := '0';  --      .read
    pcie_s0_readdata    : out std_logic_vector(31 downto 0);  --      .readdata
    pcie_s0_write       : in  std_logic                     := '0';  --      .write
    pcie_s0_writedata   : in  std_logic_vector(31 downto 0) := (others => '0');  --      .writedata
    pcie_s0_waitrequest : out std_logic;  --      .waitrequest
    bmc_s0_address      : in  std_logic_vector(1 downto 0)  := (others => '0');  --    s0.address
    bmc_s0_read         : in  std_logic                     := '0';  --      .read
    bmc_s0_readdata     : out std_logic_vector(31 downto 0);  --      .readdata
    bmc_s0_write        : in  std_logic                     := '0';  --      .write
    bmc_s0_writedata    : in  std_logic_vector(31 downto 0) := (others => '0');  --      .writedata
    bmc_s0_waitrequest  : out std_logic;  --      .waitrequest
    hps_gp_o            : in  std_logic_vector(31 downto 0);
    hps_gp_i            : out std_logic_vector(31 downto 0)
    );
end entity arbiter;

architecture rtl of arbiter is

  component arbiter_frr
    generic (
      width   :     natural);
    port (
      clock   : in  std_logic;
      reset   : in  std_logic;
      request : in  std_logic_vector(width-1 downto 0);
      grant   : out std_logic_vector(width-1 downto 0));
  end component;

  constant ARB_WIDTH : integer := 2;

  signal pcie_read_d1 : std_logic;
  signal bmc_read_d1  : std_logic;
  signal request : std_logic_vector(ARB_WIDTH-1 downto 0);
  signal grant   : std_logic_vector(ARB_WIDTH-1 downto 0);

begin

  i_arbiter_frr : arbiter_frr
    generic map (
      width   => ARB_WIDTH)
    port map (
      clock   => clk,                   -- in
      reset   => reset,                 -- in
      request => request,               -- in
      grant   => grant);                -- out

  -- PCIe Register
  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        pcie_read_d1 <= '0';
        request(0)   <= '0';
      else
        pcie_read_d1 <= pcie_s0_read and not pcie_read_d1;

        if pcie_s0_write = '1' then
          if pcie_s0_address = "00" then
            request(0) <= pcie_s0_writedata(0);
          end if;
        end if;

        if pcie_s0_read = '1' then
          if pcie_s0_address = "00" then
            pcie_s0_readdata <= (0 => request(0), 1 => request(1), 4 => grant(0), 5 => grant(1), others => '0');
          else
            pcie_s0_readdata <= (others => '0');
          end if;
        end if;

      end if;
    end if;
  end process;

  pcie_s0_waitrequest <= pcie_s0_read and not pcie_read_d1;

  -- BMC Register
  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        bmc_read_d1  <= '0';
        request(1)   <= '0';
      else
        bmc_read_d1  <= bmc_s0_read and not bmc_read_d1;

        if bmc_s0_write = '1' then
          if bmc_s0_address = "00" then
            request(1) <= bmc_s0_writedata(1);
          end if;
        end if;

        if bmc_s0_read = '1' then
          if bmc_s0_address = "00" then
            bmc_s0_readdata <= (0 => request(0), 1 => request(1), 4 => grant(0), 5 => grant(1), others => '0');
          else
            bmc_s0_readdata <= (others => '0');
          end if;
        end if;

      end if;
    end if;
  end process;

  bmc_s0_waitrequest <= bmc_s0_read and not bmc_read_d1;

end architecture rtl;

