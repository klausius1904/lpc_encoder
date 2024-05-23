`include "encoder.v"
`include "axi_slave_s.v"
`include "axi_master_s.v"

module axis_conv_encoder(
	input wire ACLK,
	input wire ARESET_N,
	
	input wire S_TVALID,
	output wire S_TREADY,
	input wire[15:0] S_TDATA,
	input wire S_TLAST,

	output wire M_TVALID,
	input wire M_TREADY,
	output wire[80:0] M_TDATA,
	output wire M_TLAST

);
	wire READY;
	wire VALID;
	wire LAST;	
	wire [15:0]SAMPLE;
	wire[2:0] COUNT;

	wire OUT_VALID;
	wire OUT_LAST;
	wire [80:0] OUT_CODED;
	wire OUT_READY;

	
	slave_axi_s_interface slave(	.ACLK(ACLK),
					.ARESET_N(ARESET_N),
					.TVALID(S_TVALID),
					.TDATA(S_TDATA),
					.TLAST(S_TLAST),
					.TREADY(S_TREADY),
					.TKEEP(1'b0),
					
					.READY(READY),
					.VALID(VALID),
					.LAST(LAST),
					.SAMPLE(SAMPLE),
					.COUNT(COUNT)

				);
	lpc_encoder encoder 	     (	.ACLK(ACLK),
					.ARESET_N(ARESET_N),
					.IN_VALID(VALID),
					.COUNT(COUNT),
					.T_LAST(LAST),
					.READY(READY),
					.IN_SOURCE(SAMPLE),
					
					.OUT_VALID(OUT_VALID),
					.OUT_LAST(LAST),
					.OUT_CODED(OUT_CODED),
					.T_READY(OUT_READY)
					);
				
	master_axi_s_interface master(
					.ACLK(ACLK),
					.ARESET_N(ARESET_N),
					.TVALID(M_TVALID),
					.TREADY(M_TREADY),
					.TDATA(M_TDATA),
					.TLAST(M_TLAST),
					
					.SAMPLE(OUT_CODED),
					.VALID_SAMPLE(OUT_VALID)
					);
	
endmodule
