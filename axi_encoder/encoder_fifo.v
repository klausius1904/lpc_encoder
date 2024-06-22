`include "encoder.v"
`include "fifo.v"
module encoder_fifo #(parameter DEPTH=8, DATA_WIDTH=8)(
	input wire ACLK,
	input wire ARESET_N,
	input wire [DATA_WIDTH-1:0] TDATA,
	input wire TVALID,
	output wire TREADY,
	input wire TUSER,
	input wire TLAST,
	
	input wire RD_EN,
	output wire [79:0] DATA_OUT,
	output wire LAST_OUT,
	output wire USER_OUT,
	output wire EMPTY
);
	wire[79:0] OUT_ENCODED;
	wire OUT_ENCODED_VALID;
	wire OUT_ENCODED_LAST;
	wire OUT_ENCODED_USER;
	
	wire OUT_DATA_READY, OUT_LAST_READY, OUT_USER_READY;
	wire EMPTY_DATA, EMPTY_LAST, EMPTY_USER;

	lpc_encoder encoder(
			.ACLK(ACLK),
			.ARESET_N(ARESET_N),
			.TDATA(TDATA),
			.TVALID(TVALID),
			.TREADY(TREADY),
			.TUSER(TUSER),
			.TLAST(TLAST),
			
			.OUT_DATA(OUT_ENCODED),
			.OUT_VALID(OUT_ENCODED_VALID),
			.OUT_READY(~OUT_DATA_READY&~OUT_LAST_READY&~OUT_USER_READY),
			.OUT_LAST(OUT_ENCODED_LAST),
			.OUT_USER(OUT_ENCODED_USER)
			);
	synchronous_fifo #(.DEPTH(DEPTH), .DATA_WIDTH(80)) fifo_data(
			.ACLK(ACLK),
			.ARESET_N(ARESET_N),
			.WR_EN(OUT_ENCODED_VALID),
			.RD_EN(RD_EN),
			.WR_DATA(OUT_ENCODED),
			.FIFO_FULL(OUT_DATA_READY),
			.FIFO_EMPTY(EMPTY_DATA),
			.RD_DATA(DATA_OUT)
			);

	synchronous_fifo #(.DEPTH(DEPTH), .DATA_WIDTH(1)) fifo_last(
			.ACLK(ACLK),
			.ARESET_N(ARESET_N),
			.WR_EN(OUT_ENCODED_VALID),
			.RD_EN(RD_EN),
			.WR_DATA(OUT_ENCODED_LAST),
			.FIFO_FULL(OUT_LAST_READY),
			.FIFO_EMPTY(EMPTY_LAST),
			.RD_DATA(LAST_OUT)
			);
	synchronous_fifo #(.DEPTH(DEPTH), .DATA_WIDTH(1)) fifo_user(
			.ACLK(ACLK),
			.ARESET_N(ARESET_N),
			.WR_EN(OUT_ENCODED_VALID),
			.RD_EN(RD_EN),
			.WR_DATA(OUT_ENCODED_USER),
			.FIFO_FULL(OUT_USER_READY),
			.FIFO_EMPTY(EMPTY_USER),
			.RD_DATA(USER_OUT)
			);


assign EMPTY= EMPTY_DATA | EMPTY_LAST | EMPTY_USER;
endmodule

