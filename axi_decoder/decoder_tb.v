`timescale 1ns/1ns

module decoder_tb;

reg ACLK;
reg ARESET_N;
reg [79:0]TDATA;
reg TVALID;
reg TUSER;
wire TREADY;
reg TLAST;
reg EN;

wire [15:0] OUT_DECODED;
wire OUT_VALID;
reg OUT_READY;
wire OUT_LAST;

integer write_file;
integer data_file;
integer scan_file;
integer cnt_reg;
`define NULL 0

always #5 ACLK=~ACLK;

initial begin
	ACLK=0;
	ARESET_N=0;
	TDATA=0;
	TVALID=0;
	TLAST=0;
	TUSER=0;
	cnt_reg=0;
	EN=0;
	OUT_READY=1;
 	#20 ARESET_N=1;


end

initial begin
	write_file= $fopen("data_decoded.txt", "w");
	data_file=$fopen("data_out.txt", "r");

	if(write_file==`NULL)begin
		$finish;
	end
	if(data_file==`NULL)begin
		$finish;
	end
end

always@(posedge ACLK or negedge ARESET_N)begin
	if(ARESET_N && TREADY)begin
		scan_file=$fscanf(data_file,"%b\n", TDATA);
		if(!$feof(data_file))begin
			cnt_reg=cnt_reg+1;
			if(cnt_reg==1920)begin
				cnt_reg=0;
				TLAST=1;
			end else begin
				TLAST=0;
			end
			TVALID=1;
			
		end
		else begin
			$fclose(data_file);
			TVALID=0;
		end
	end
	if(OUT_READY&&OUT_VALID)begin
		$fwrite(write_file, "%b\n", OUT_DECODED);
		if(~TVALID)begin
			$fclose(data_file);
			$fclose(write_file);
			$finish;
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
		.OUT_VALID(OUT_VALID),
		.EN(EN)
		);
endmodule
