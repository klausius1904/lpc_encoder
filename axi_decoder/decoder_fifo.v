`include "decoder.v"
`include "fifo.v"
module decoder_fifo #(parameter DEPTH=128, DATA_WIDTH=16, LAST_WIDTH=1)(
	input wire ACLK,
	input wire ARESET_N,
	input wire [79:0] TDATA,
	input wire TVALID,
	output wire TREADY,
	input wire TUSER,
	input wire TLAST,
	input wire EN,
	
	input wire RD_EN,
	output wire [DATA_WIDTH-1:0] DATA_OUT,
	output wire [LAST_WIDTH-1:0] LAST_OUT,
	output wire FIFO_EMPTY
);
	wire[DATA_WIDTH-1:0] OUT_DECODED;
	wire OUT_DECODED_VALID;
	wire[LAST_WIDTH-1:0] OUT_DECODED_LAST;
	wire OUT_DATA_READY, OUT_LAST_READY;
	

	wire DATA_EMPTY, LAST_EMPTY;
	lpc_decoder decoder(
			.ACLK(ACLK),
			.ARESET_N(ARESET_N),
			.TDATA(TDATA),
			.TVALID(TVALID),
			.TREADY(TREADY),
			.TUSER(TUSER),
			.TLAST(TLAST),
			.EN(EN),
			
			.OUT_DECODED(OUT_DECODED),
			.OUT_VALID(OUT_DECODED_VALID),
			.OUT_READY(~OUT_DATA_READY&~OUT_LAST_READY),
			.OUT_LAST(OUT_DECODED_LAST)
			);
	synchronous_fifo #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) fifo_data(
			.ACLK(ACLK),
			.ARESET_N(ARESET_N),
			.WR_EN(OUT_DECODED_VALID),
			.RD_EN(RD_EN),
			.WR_DATA(OUT_DECODED),
			.FIFO_FULL(OUT_DATA_READY),
			.FIFO_EMPTY(DATA_EMPTY),
			.RD_DATA(DATA_OUT)
			);

	synchronous_fifo #(.DEPTH(DEPTH), .DATA_WIDTH(LAST_WIDTH)) fifo_last(
			.ACLK(ACLK),
			.ARESET_N(ARESET_N),
			.WR_EN(OUT_DECODED_VALID),
			.RD_EN(RD_EN),
			.WR_DATA(OUT_DECODED_LAST),
			.FIFO_FULL(OUT_LAST_READY),
			.FIFO_EMPTY(LAST_EMPTY),
			.RD_DATA(LAST_OUT)
			);

assign FIFO_EMPTY=DATA_EMPTY|LAST_EMPTY;
endmodule

