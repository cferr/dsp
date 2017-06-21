//scfifo ADD_RAM_OUTPUT_REGISTER="OFF" CBX_SINGLE_OUTPUT_FILE="ON" INTENDED_DEVICE_FAMILY=""Cyclone V"" LPM_NUMWORDS=8 LPM_SHOWAHEAD="OFF" LPM_TYPE="scfifo" LPM_WIDTH=0 LPM_WIDTHU=3 OVERFLOW_CHECKING="ON" UNDERFLOW_CHECKING="ON" USE_EAB="ON" clock data empty full q rdreq usedw wrreq
//VERSION_BEGIN 16.0 cbx_mgl 2016:04:20:19:36:45:SJ cbx_stratixii 2016:04:20:18:35:29:SJ cbx_util_mgl 2016:04:20:18:35:29:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
//  Your use of Altera Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Altera Program License 
//  Subscription Agreement, the Altera Quartus Prime License Agreement,
//  the Altera MegaCore Function License Agreement, or other 
//  applicable license agreement, including, without limitation, 
//  that your use is for the sole purpose of programming logic 
//  devices manufactured by Altera and sold by Altera or its 
//  authorized distributors.  Please refer to the applicable 
//  agreement for further details.



//synthesis_resources = scfifo 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  mgpup
	( 
	clock,
	data,
	empty,
	full,
	q,
	rdreq,
	usedw,
	wrreq) /* synthesis synthesis_clearbox=1 */;
	input   clock;
	input   data;
	output   empty;
	output   full;
	output   q;
	input   rdreq;
	output   [2:0]  usedw;
	input   wrreq;

	wire  wire_mgl_prim1_empty;
	wire  wire_mgl_prim1_full;
	wire  wire_mgl_prim1_q;
	wire  [2:0]   wire_mgl_prim1_usedw;

	scfifo   mgl_prim1
	( 
	.clock(clock),
	.data(data),
	.empty(wire_mgl_prim1_empty),
	.full(wire_mgl_prim1_full),
	.q(wire_mgl_prim1_q),
	.rdreq(rdreq),
	.usedw(wire_mgl_prim1_usedw),
	.wrreq(wrreq));
	defparam
		mgl_prim1.add_ram_output_register = "OFF",
		mgl_prim1.intended_device_family = ""Cyclone V"",
		mgl_prim1.lpm_numwords = 8,
		mgl_prim1.lpm_showahead = "OFF",
		mgl_prim1.lpm_type = "scfifo",
		mgl_prim1.lpm_width = 0,
		mgl_prim1.lpm_widthu = 3,
		mgl_prim1.overflow_checking = "ON",
		mgl_prim1.underflow_checking = "ON",
		mgl_prim1.use_eab = "ON";
	assign
		empty = wire_mgl_prim1_empty,
		full = wire_mgl_prim1_full,
		q = wire_mgl_prim1_q,
		usedw = wire_mgl_prim1_usedw;
endmodule //mgpup
//VALID FILE
