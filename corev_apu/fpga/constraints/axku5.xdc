# ==============================================================================
# AXKU5 Board - CVA6 (ariane_xilinx) Vivado XDC
# Device: XCKU5P-FFVB676-2I
#
# Based on:
#   - fpga/axku5/axku5_template.xdc
#   - corev_apu/fpga/constraints/genesys-2.xdc
#   - fpga/axku5/board_files/alinx.com/axku5/1.0/part0_pins.xml
#
# This XDC assumes a top-level similar to ariane_xilinx (GENESYSII/NEXYS style):
#   - sys_clk_p, sys_clk_n        : differential system clock
#   - sys_rst_n (or cpu_resetn)   : active-low system reset
#   - led[3:0]                    : user LEDs
#   - tx, rx (or uart_tx, uart_rx): UART
#   - spi_clk_o, spi_ss, spi_mosi, spi_miso : SD card via SPI
#   - fan_pwm                     : fan PWM
#   - eth_*                       : RGMII Ethernet
# ==============================================================================

# ==============================================================================
# System Reference Clock (200 MHz differential clock on K22/K23)
# ==============================================================================
# AXKU5 template and board files use DIFF_SSTL12 here. If your oscillator is
# actually LVDS, you can switch IOSTANDARD to LVDS; for DDR-related designs,
# DIFF_SSTL12 is typically correct.

create_clock -period 5.000 -name sys_clk_pin [get_ports sys_clk_p]

set_property PACKAGE_PIN K22 [get_ports sys_clk_p]
set_property PACKAGE_PIN K23 [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sys_clk_p sys_clk_n}]

# Optional jitter model
# set_input_jitter [get_clocks sys_clk_pin] 0.050

# ==============================================================================
# Board Management: Reset, Key, Fan
# ==============================================================================

# Active-low system reset pushbutton (J14)
# ariane_xilinx uses cpu_resetn as the board-level reset input.
set_property PACKAGE_PIN J14 [get_ports cpu_resetn]
set_property IOSTANDARD LVCMOS33 [get_ports cpu_resetn]

# Optional user key (J15) - only if you expose 'key' at top-level
# set_property PACKAGE_PIN J15 [get_ports key]
# set_property IOSTANDARD LVCMOS33 [get_ports key]

# Fan PWM output (Y16)
set_property PACKAGE_PIN Y16 [get_ports fan_pwm]
set_property IOSTANDARD LVCMOS33 [get_ports fan_pwm]

# Recommended methodology: treat async reset as a false path
set_false_path -from [get_ports cpu_resetn]
set_property PULLTYPE PULLUP [get_ports cpu_resetn]

# ==============================================================================
# User LEDs (4x)
# ==============================================================================

# AXKU5 template pinout:
#   LED0: J12
#   LED1: H14
#   LED2: F13
#   LED3: H12

set_property PACKAGE_PIN J12 [get_ports {led[0]}]
set_property PACKAGE_PIN H14 [get_ports {led[1]}]
set_property PACKAGE_PIN F13 [get_ports {led[2]}]
set_property PACKAGE_PIN H12 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# Optional drive/slew tuning
# set_property SLEW SLOW [get_ports {led[*]}]
# set_property DRIVE 8   [get_ports {led[*]}]

# ==============================================================================
# UART (USB-UART bridge)
# ==============================================================================

# AXKU5 pins (from template/board_files):
#   UART_TXD: AD15
#   UART_RXD: AE15

# ariane_xilinx exposes 'tx' and 'rx' as the board UART pins.
set_property PACKAGE_PIN AD15 [get_ports tx]
set_property PACKAGE_PIN AE15 [get_ports rx]
set_property IOSTANDARD LVCMOS33 [get_ports {tx rx}]

# From AXKU5 manual: UART_TXD=B84_L3_P(AD15), UART_RXD=B84_L3_N(AE15)

# ==============================================================================
# SD Card (SPI mode) mapped to SoC SPI interface
# ==============================================================================
# AXKU5 template SPI pins:
#   SD_SCK  : Y13
#   SD_CS   : AF14
#   SD_MOSI : AA13
#   SD_MISO : W13
#
# Map these to the SoC SPI ports used for SD access:
#   spi_clk_o, spi_ss, spi_mosi, spi_miso

set_property PACKAGE_PIN Y13  [get_ports spi_clk_o]
set_property PACKAGE_PIN AF14 [get_ports spi_ss]
set_property PACKAGE_PIN AA13 [get_ports spi_mosi]
set_property PACKAGE_PIN W13  [get_ports spi_miso]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_clk_o spi_ss spi_mosi spi_miso}]

# Drive/slew and pullups from template
set_property DRIVE 16 [get_ports spi_clk_o]
set_property DRIVE 16 [get_ports spi_mosi]
set_property DRIVE 16 [get_ports spi_ss]

set_property SLEW SLOW [get_ports spi_clk_o]
set_property SLEW SLOW [get_ports spi_mosi]
set_property SLEW SLOW [get_ports spi_ss]

set_property PULLUP true [get_ports spi_clk_o]
set_property PULLUP true [get_ports spi_mosi]
set_property PULLUP true [get_ports spi_ss]
set_property PULLUP true [get_ports spi_miso]

# Optional SD card-detect (if you expose sd_cd at top-level)
# AXKU5 template: SD_CD at AD14
# set_property PACKAGE_PIN AD14 [get_ports sd_cd]
# set_property IOSTANDARD LVCMOS33 [get_ports sd_cd]

# ==============================================================================
# Ethernet: RGMII (1 GbE PHY)
# ==============================================================================
# Use eth_* port names as in ariane_xilinx and ariane_peripherals_xilinx.

# Pins from part0_pins.xml / axku5_template.xdc:
#   ETH_MDC    : N26
#   ETH_MDIO   : U19
#   ETH_RESET  : N22
#   ETH_RXCK   : U21
#   ETH_RXCTL  : R23
#   ETH_RXD0   : V19
#   ETH_RXD1   : P20
#   ETH_RXD2   : P21
#   ETH_RXD3   : R22
#   ETH_TXCK   : R25
#   ETH_TXCTL  : R26
#   ETH_TXD0   : V21
#   ETH_TXD1   : V22
#   ETH_TXD2   : N19
#   ETH_TXD3   : P19

# 125 MHz receive clock from PHY
create_clock -period 8.000 -name eth_rxck [get_ports eth_rxck]

# RX data and control
set_property PACKAGE_PIN U21 [get_ports eth_rxck]
set_property PACKAGE_PIN R23 [get_ports eth_rxctl]
set_property PACKAGE_PIN V19 [get_ports {eth_rxd[0]}]
set_property PACKAGE_PIN P20 [get_ports {eth_rxd[1]}]
set_property PACKAGE_PIN P21 [get_ports {eth_rxd[2]}]
set_property PACKAGE_PIN R22 [get_ports {eth_rxd[3]}]

# TX data and control
set_property PACKAGE_PIN R25 [get_ports eth_txck]
set_property PACKAGE_PIN R26 [get_ports eth_txctl]
set_property PACKAGE_PIN V21 [get_ports {eth_txd[0]}]
set_property PACKAGE_PIN V22 [get_ports {eth_txd[1]}]
set_property PACKAGE_PIN N19 [get_ports {eth_txd[2]}]
set_property PACKAGE_PIN P19 [get_ports {eth_txd[3]}]

# MDIO/MDC and PHY reset
set_property PACKAGE_PIN N26 [get_ports eth_mdc]
set_property PACKAGE_PIN U19 [get_ports eth_mdio]
set_property PACKAGE_PIN N22 [get_ports eth_rst_n]

# I/O standards (1.8 V bank for RGMII + MDIO/MDC/reset)
set_property IOSTANDARD LVCMOS18 [get_ports {eth_rxd[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {eth_txd[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {eth_rxck eth_rxctl eth_txck eth_txctl}]
set_property IOSTANDARD LVCMOS18 [get_ports {eth_mdc eth_mdio eth_rst_n}]

# Slew for TX
set_property SLEW FAST [get_ports {eth_txd[*]}]
set_property SLEW FAST [get_ports eth_txck]
set_property SLEW FAST [get_ports eth_txctl]

# You can also define asynchronous clock groups if you use multiple PLL outputs:
# set_clock_groups -asynchronous -group [get_clocks eth_rxck -include_generated_clocks] \
#                                  -group [get_clocks clk_out2_xlnx_clk_gen]

# ==============================================================================
# HDMI Control / DDC / HPD (optional)
# ==============================================================================
# Only enable if you expose these ports at the CVA6 top-level and use HDMI IP.

# Downstream (TX) side control lines
# AXKU5 template pins:
#   HDMI_NRESET : Y20
#   HDMI_SCL    : AB17
#   HDMI_SDA    : AC17

# set_property PACKAGE_PIN Y20  [get_ports hdmi_nreset]
# set_property PACKAGE_PIN AB17 [get_ports hdmi_scl]
# set_property PACKAGE_PIN AC17 [get_ports hdmi_sda]
# set_property IOSTANDARD LVCMOS18 [get_ports {hdmi_nreset hdmi_scl hdmi_sda}]

# Upstream (RX) side DDC/HPD
#   HDMI_HPD        : AD19
#   HDMI_DDC_SCL_IO : Y18
#   HDMI_DDC_SDA_IO : AA18

# set_property PACKAGE_PIN AD19 [get_ports hdmi_hpd]
# set_property PACKAGE_PIN Y18  [get_ports hdmi_ddc_scl_io]
# set_property PACKAGE_PIN AA18 [get_ports hdmi_ddc_sda_io]
# set_property IOSTANDARD LVCMOS18 [get_ports {hdmi_hpd hdmi_ddc_scl_io hdmi_ddc_sda_io}]

# ==============================================================================
# JTAG (RISC-V Debug Module via dmi_jtag) – Olimex ARM-USB-TINY on J8
# ==============================================================================
# ariane_xilinx exposes:
#   tck, tms, trst_n, tdi, tdo
#
# These are *not* the dedicated Xilinx configuration JTAG pins. They are extra
# GPIO pins wired to a second JTAG header.
#
# AXKU5 J8 40-pin expansion header mapping used here (high end of header):
#   J8-28 (IO1_13P, C12) -> TRST_N
#   J8-30 (IO1_14P, E13) -> TDI
#   J8-32 (IO1_15P, G12) -> TMS
#   J8-34 (IO1_16P, A13) -> TCK
#   J8-36 (IO1_17P, D14) -> TDO
#
# Olimex ARM-USB-TINY 20-pin JTAG header pinout (per Olimex docs):
#   1  VREF          2  VREF
#   3  TTRST_N       4  GND
#   5  TTDI          6  GND
#   7  TTMS          8  GND
#   9  TTCK          10 GND
#   11 TRTCK         12 GND
#   13 TTDO          14 GND
#   15 TSRST_N       16 GND
#   17 NC            18 GND
#   19 TARGET_SUPPLY 20 GND
#
# Recommended safe wiring to AXKU5 J8:
#   - Connect VREF (pins 1 and/or 2) to J8-39 or J8-40 (+3.3V) as reference only.
#   - Connect several GND pins (4,6,8,10,12,14,16,18,20) to J8-37/38/1 (GND).
#   - Connect TTRST_N (pin 3)  -> J8-28 (TRST_N -> trst_n).
#   - Connect TTDI (pin 5)     -> J8-30 (TDI    -> tdi).
#   - Connect TTMS (pin 7)     -> J8-32 (TMS    -> tms).
#   - Connect TTCK (pin 9)     -> J8-34 (TCK    -> tck).
#   - Connect TTDO (pin 13)    -> J8-36 (TDO    -> tdo).
#   - Leave TRTCK (11), TSRST_N (15), and TARGET_SUPPLY (19) unconnected unless
#     you have a specific reason and matching circuitry.
#
# Assign AXKU5 J8 pins to RISC-V JTAG ports:
set_property PACKAGE_PIN A13 [get_ports tck]
set_property PACKAGE_PIN G12 [get_ports tms]
set_property PACKAGE_PIN E13 [get_ports tdi]
set_property PACKAGE_PIN D14 [get_ports tdo]
set_property PACKAGE_PIN C12 [get_ports trst_n]

# JTAG is 3.3V single-ended on these IO pins
set_property IOSTANDARD LVCMOS33 [get_ports {tck tms trst_n tdi tdo}]

# Recommended pulls so TAP stays in reset/idle when no probe is attached
set_property PULLTYPE PULLUP [get_ports {tms trst_n}]

# Timing guidance similar to other boards
set_max_delay -to   [get_ports { tdo } ] 20
set_max_delay -from [get_ports { tms } ] 20
set_max_delay -from [get_ports { tdi } ] 20
set_max_delay -from [get_ports { trst_n } ] 20
set_false_path -from [get_ports { trst_n }]

# ==============================================================================
# Methodology helpers (generic)
# ==============================================================================

# Example additional false-paths or drive/slew controls can go here.
# For now we rely on:
#   - false path on sys_rst_n
#   - reasonable defaults on other I/Os

# ==============================================================================
# End of AXKU5 CVA6 constraints
# ==============================================================================
