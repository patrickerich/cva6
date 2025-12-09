VIVADO ?= vivado
VIVADOFLAGS ?= -nojournal -mode batch -source scripts/prologue.tcl

work-dir := work-fpga
bit := $(work-dir)/ariane_xilinx.bit
mcs := $(work-dir)/ariane_xilinx.mcs
ip-dir := xilinx

# Common Xilinx IPs used on all boards
ips_common := xlnx_axi_clock_converter.xci  \
              xlnx_axi_dwidth_converter.xci \
              xlnx_axi_dwidth_converter_dm_master.xci \
              xlnx_axi_dwidth_converter_dm_slave.xci \
              xlnx_axi_quad_spi.xci         \
              xlnx_axi_gpio.xci             \
              xlnx_clk_gen.xci              \
	      xlnx_dpti_clk.xci

# MIG 7-series is only valid on 7-series parts, not on AXKU5 (UltraScale+).
# For BOARD=axku5 we use BRAM-backed DRAM and skip xlnx_mig_7_ddr3 entirely.
ifeq ($(BOARD),axku5)
  ips := $(ips_common)
else
  ips := $(ips_common) xlnx_mig_7_ddr3.xci
endif

ips := $(addprefix $(work-dir)/, $(ips))
ips-target := $(join $(addsuffix /ip/, $(addprefix $(ip-dir)/, $(basename $(ips)))), $(ips))

all: $(mcs)

# Generate mcs from bitstream
$(mcs): $(bit)
	$(VIVADO) $(VIVADOFLAGS) -source scripts/write_cfgmem.tcl -tclargs $@ $^

# Rebuild the bitstream whenever IPs or the build scripts change, so that
# properties like BITSTREAM.CONFIG.SPI_BUSWIDTH (set in run.tcl) are correctly
# reflected in the generated .bit file.
$(bit): $(ips) scripts/run.tcl scripts/prologue.tcl
	mkdir -p $(work-dir)
	$(VIVADO) $(VIVADOFLAGS) -source scripts/run.tcl
	cp ariane.runs/impl_1/ariane_xilinx* ./$(work-dir)

$(ips): %.xci :
	mkdir -p $(work-dir)
	@echo Generating $(@F)
	@cd $(ip-dir)/$(basename $(@F)) && make clean && make
	@cp $(ip-dir)/$(basename $(@F))/$(basename $(@F)).srcs/sources_1/ip/$(basename $(@F))/$(@F) $@

mcs: $(mcs)

program:
	$(VIVADO) $(VIVADOFLAGS) -source scripts/program.tcl

clean:
	rm -rf *.log *.jou *.str *.mif *.xpr $(work-dir) ariane.cache ariane.hw ariane.ip_user_files scripts/vivado*

.PHONY:
	clean
