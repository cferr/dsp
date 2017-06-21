.PHONY: all clean

PROJECTFILES=$(wildcard ./*.qpf)
VHDL_DIR=.
VHDL_FILES=$(wildcard $(VHDL_DIR)/*.vhd)

ASM_FILES=$(PROJECTFILES:.qpf=.sof)
QSYS_FILES=$(wildcard ./*.qsys)
SOPCINFO=$(QSYS_FILES:.qsys=.sopcinfo)
QSYS_SYNTHESIS_TYPE=VHDL

# BSP_GEN=nios2-bsp-generate-files
QUARTUS_MAP=quartus_map
QUARTUS_FIT=quartus_fit
QUARTUS_ASM=quartus_asm
QUARTUS_PGM=quartus_pgm
QSYS_GENERATE=qsys-generate

HELP_FUN = \
         %help; \
         while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^(\w+)\s*:.*\#\#(?:@(\w+))?\s(.*)$$/ }; \
         print "usage: make [target]\n\n"; \
     for (keys %help) { \
         print "$$_:\n"; $$sep = " " x (20 - length($$_->[0])); \
         print "  $$_->[0]$$sep$$_->[1]\n" for @{$$help{$$_}}; \
         print "\n"; }

all: hardware

help: ##@Miscellaneous Show this help
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

hardware: $(ASM_FILES) ##@Options Generate the hardware support files

%.sof: %.qpf $(VHDL_FILES)
	$(QUARTUS_MAP) $<
	$(QUARTUS_FIT) $<
	$(QUARTUS_ASM) $<
	-mv $(@:.sof=time_limited.sof) $@ # In case some megafunction is not licensed

program: hardware ##@Options Program the FPGA with the generated .sof file
	$(QUARTUS_PGM) -c "`jtagconfig --enum  | head -n 1 | sed 's/1) //'`" -m jtag -o 'P;$(ASM_FILES)'

clean: ##@Miscellaneous Remove the generated files
	-rm -rf db/ incremental_db/ *.sta.summary *.sta.rpt \
	*.flow.rpt *.sof *.sld *.pof *.jdi \
	*.asm.rpt *.fit.rpt *.fit.summary *.fit.smsg \
	*.pin *.map.summary *.map.rpt *.map.smsg \
	output_files \
	.qsys_edit/ $(QSYS_FILES:.qsys=) $(SOPCINFO)
