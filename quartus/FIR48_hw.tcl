# TCL File Generated by Component Editor 16.0
# Wed May 24 17:10:27 CEST 2017
# DO NOT MODIFY


# 
# FIR48 "FIR48" v1.0
# Corentin Ferry 2017.05.24.17:10:27
# 
# 

# 
# request TCL package from ACDS 16.0
# 
package require -exact qsys 16.0


# 
# module FIR48
# 
set_module_property DESCRIPTION ""
set_module_property NAME FIR48
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR "Corentin Ferry"
set_module_property DISPLAY_NAME FIR48
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL dsp_toplevel
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file channel_counter.vhd VHDL PATH ../hdl/channel_counter.vhd
add_fileset_file dma.vhd VHDL PATH ../hdl/dma.vhd
add_fileset_file dsp_toplevel.vhd VHDL PATH ../hdl/dsp_toplevel.vhd TOP_LEVEL_FILE
add_fileset_file dsp_utils.vhd VHDL PATH ../hdl/dsp_utils.vhd
add_fileset_file dspcore.vhd VHDL PATH ../hdl/dspcore.vhd
add_fileset_file fifo.vhd VHDL PATH ../hdl/fifo.vhd
add_fileset_file mult_block.vhd VHDL PATH ../hdl/mult_block.vhd
add_fileset_file mult_to_state.vhd VHDL PATH ../hdl/mult_to_state.vhd
add_fileset_file slave.vhd VHDL PATH ../hdl/slave.vhd
add_fileset_file state_holder.vhd VHDL PATH ../hdl/state_holder.vhd
add_fileset_file state_to_mult.vhd VHDL PATH ../hdl/state_to_mult.vhd


# 
# parameters
# 
add_parameter NUM_MULTIPLIERS INTEGER 128
set_parameter_property NUM_MULTIPLIERS DEFAULT_VALUE 128
set_parameter_property NUM_MULTIPLIERS DISPLAY_NAME NUM_MULTIPLIERS
set_parameter_property NUM_MULTIPLIERS TYPE INTEGER
set_parameter_property NUM_MULTIPLIERS UNITS None
set_parameter_property NUM_MULTIPLIERS HDL_PARAMETER true
add_parameter FIFO_LENGTH INTEGER 100
set_parameter_property FIFO_LENGTH DEFAULT_VALUE 100
set_parameter_property FIFO_LENGTH DISPLAY_NAME FIFO_LENGTH
set_parameter_property FIFO_LENGTH TYPE INTEGER
set_parameter_property FIFO_LENGTH UNITS None
set_parameter_property FIFO_LENGTH HDL_PARAMETER true


# 
# display items
# 


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset_n reset_n Input 1


# 
# connection point sl
# 
add_interface sl avalon end
set_interface_property sl addressUnits WORDS
set_interface_property sl associatedClock clock
set_interface_property sl associatedReset reset
set_interface_property sl bitsPerSymbol 8
set_interface_property sl burstOnBurstBoundariesOnly false
set_interface_property sl burstcountUnits WORDS
set_interface_property sl explicitAddressSpan 0
set_interface_property sl holdTime 0
set_interface_property sl linewrapBursts false
set_interface_property sl maximumPendingReadTransactions 0
set_interface_property sl maximumPendingWriteTransactions 0
set_interface_property sl readLatency 0
set_interface_property sl readWaitTime 1
set_interface_property sl setupTime 0
set_interface_property sl timingUnits Cycles
set_interface_property sl writeWaitTime 0
set_interface_property sl ENABLED true
set_interface_property sl EXPORT_OF ""
set_interface_property sl PORT_NAME_MAP ""
set_interface_property sl CMSIS_SVD_VARIABLES ""
set_interface_property sl SVD_ADDRESS_GROUP ""

add_interface_port sl sl_address address Input 8
add_interface_port sl sl_waitrequest waitrequest Output 1
add_interface_port sl sl_read read Input 1
add_interface_port sl sl_write write Input 1
add_interface_port sl sl_data_out readdata Output 32
add_interface_port sl sl_data_in writedata Input 32
set_interface_assignment sl embeddedsw.configuration.isFlash 0
set_interface_assignment sl embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment sl embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment sl embeddedsw.configuration.isPrintableDevice 0


# 
# connection point avalon_master
# 
add_interface avalon_master avalon start
set_interface_property avalon_master addressUnits SYMBOLS
set_interface_property avalon_master associatedClock clock
set_interface_property avalon_master associatedReset reset
set_interface_property avalon_master bitsPerSymbol 8
set_interface_property avalon_master burstOnBurstBoundariesOnly false
set_interface_property avalon_master burstcountUnits WORDS
set_interface_property avalon_master doStreamReads false
set_interface_property avalon_master doStreamWrites false
set_interface_property avalon_master holdTime 0
set_interface_property avalon_master linewrapBursts false
set_interface_property avalon_master maximumPendingReadTransactions 0
set_interface_property avalon_master maximumPendingWriteTransactions 0
set_interface_property avalon_master readLatency 0
set_interface_property avalon_master readWaitTime 1
set_interface_property avalon_master setupTime 0
set_interface_property avalon_master timingUnits Cycles
set_interface_property avalon_master writeWaitTime 0
set_interface_property avalon_master ENABLED true
set_interface_property avalon_master EXPORT_OF ""
set_interface_property avalon_master PORT_NAME_MAP ""
set_interface_property avalon_master CMSIS_SVD_VARIABLES ""
set_interface_property avalon_master SVD_ADDRESS_GROUP ""

add_interface_port avalon_master ma_address address Output 32
add_interface_port avalon_master ma_read read Output 1
add_interface_port avalon_master ma_write write Output 1
add_interface_port avalon_master ma_burstcount burstcount Output 16
add_interface_port avalon_master ma_writedata writedata Output 32
add_interface_port avalon_master ma_waitrequest waitrequest Input 1
add_interface_port avalon_master ma_readdata readdata Input 32
add_interface_port avalon_master ma_readdatavalid readdatavalid Input 1


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clock clk Input 1

