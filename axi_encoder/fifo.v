module synchronous_fifo #(parameter DEPTH=128, parameter DATA_WIDTH=16)(
input wire ACLK,
input wire ARESET_N,
input wire RD_EN,
input wire WR_EN,
input wire [DATA_WIDTH-1:0] WR_DATA,
output wire [DATA_WIDTH-1:0] RD_DATA,
output wire FIFO_EMPTY,
output wire FIFO_FULL
);
	reg[DATA_WIDTH-1:0] data_reg, data_nxt;
	
	reg[$clog2(DEPTH)-1:0] rd_cnt_reg, rd_cnt_nxt;
	reg[$clog2(DEPTH)-1:0] wr_cnt_reg, wr_cnt_nxt;
	
	reg rd_flag_reg, rd_flag_nxt;
	reg wr_flag_reg, wr_flag_nxt;

	reg[DATA_WIDTH-1:0] fifo_reg[DEPTH-1:0], fifo_nxt[DEPTH-1:0];
	reg[19:0] idx;

	always@(posedge ACLK  or negedge ARESET_N)begin
		if(~ARESET_N)begin
			data_reg <=0;
			rd_cnt_reg <= 0;
			wr_cnt_reg <= 0;
			rd_flag_reg <= 0;
			wr_flag_reg <= 0;
			for(idx=0; idx<DEPTH; idx=idx+1)begin
				fifo_reg[idx]<=0;
			end
		end else begin
			data_reg <= data_nxt;
			rd_cnt_reg <= rd_cnt_nxt;
			wr_cnt_reg <= wr_cnt_nxt;
			rd_flag_reg <= rd_flag_nxt;
			wr_flag_reg <= wr_flag_nxt;
			for(idx=0; idx<DEPTH; idx=idx+1)begin
				fifo_reg[idx]<=fifo_nxt[idx];
			end
		end
	end

	always@(*)begin
		data_nxt = data_reg;
		rd_cnt_nxt=rd_cnt_reg;
		wr_cnt_nxt=wr_cnt_reg;
		rd_flag_nxt=rd_flag_reg;
		wr_flag_nxt=wr_flag_reg;
		for(idx=0; idx<DEPTH; idx=idx+1)begin
			fifo_nxt[idx]=fifo_reg[idx];
		end

		if(WR_EN && ~FIFO_FULL)begin
			fifo_nxt[wr_cnt_reg]= WR_DATA;
			if( &wr_cnt_reg==1)begin
				wr_cnt_nxt=0;
				wr_flag_nxt=~wr_flag_reg;
			end
			else begin
				wr_cnt_nxt= wr_cnt_reg+1;
			end
		end
		if(RD_EN &&~FIFO_EMPTY)begin
			data_nxt= fifo_reg[rd_cnt_reg];
			if( &rd_cnt_reg==1)begin
				rd_cnt_nxt=0;	
				rd_flag_nxt=~rd_flag_nxt;
			end
			else begin
				rd_cnt_nxt= rd_cnt_reg+1;
			end
			
		end
	end

assign RD_DATA = data_reg;
assign FIFO_EMPTY = (rd_cnt_reg == wr_cnt_reg) && (rd_flag_reg == wr_flag_reg);
assign FIFO_FULL =  (rd_cnt_reg == wr_cnt_reg) && (rd_flag_reg != wr_flag_reg);
endmodule

