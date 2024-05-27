`timescale 1ns/1ns

module decoder_tb;

reg ACLK;
reg ARESET_N;
reg [79:0]TDATA;
reg TVALID;
reg TUSER;
wire TREADY;
reg TLAST;

wire [15:0] OUT_DECODED;
wire OUT_VALID;
reg OUT_READY;
wire OUT_LAST;

integer data_file;
integer scan_file;
`define NULL 0

always #5 ACLK=~ACLK;

initial begin
	ACLK=0;
	ARESET_N=0;
	TDATA=0;
	TVALID=0;
	TLAST=0;
	OUT_READY=1;
 	#20 ARESET_N=1;


end

initial begin
	data_file=$fopen("data_out.txt", "r");
	if(data_file==`NULL)begin
		$finish;
	end
end

always@(posedge ACLK or negedge ARESET_N)begin
	if(ARESET_N && TREADY)begin
		scan_file=$fscanf(data_file,"%b\n", TDATA);
		if(!$feof(data_file))begin
			TVALID=1;
			
		end
		else begin
			TVALID=0;
		end
	end
end

lpc_decoder uut(
		.ACLK(ACLK),
		.ARESET_N(ARESET_N),
		.TDATA(TDATA),
		.TREADY(TREADY),
		.TVALID(TVALID),
		.TLAST(TLAST),
		.TUSER(TUSER),
		.OUT_DECODED(OUT_DECODED),
		.OUT_LAST(OUT_LAST),
		.OUT_READY(OUT_READY),
		.OUT_VALID(OUT_VALID)
		);
endmodule
