module lpc_encoder
(
	input wire ACLK,
	input wire ARESET_N,
	input wire[15:0] TDATA,
	input wire TVALID,
	input wire TLAST,
	input wire TUSER,
	output wire TREADY,
	
	
	output wire OUT_VALID,
	output wire OUT_LAST,
	output wire [79:0] OUT_DATA,
	input wire OUT_READY
	
	

);
	reg[7:0] src_reg[7:0], src_nxt[7:0];
	reg[7:0] pv_reg, pv_nxt;
	reg[7:0] ph_reg, ph_nxt;
	reg[2:0] cnt_reg, cnt_nxt;
	reg[79:0] encoded_reg, encoded_nxt;

	reg ready_reg, ready_nxt;
	reg out_valid_reg, out_valid_nxt;
	reg[4:0] last_reg, last_nxt;

	reg [3:0] idx;

	always@(posedge ACLK or negedge ARESET_N)begin
		if(~ARESET_N)begin
			for(idx=0; idx<8; idx=idx+1)begin
				src_reg[idx]<=0;
			end
			pv_reg<=0;
			ph_reg<=0;
			cnt_reg<=0;
			encoded_reg<=0;
			ready_reg<=1;
			out_valid_reg<=0;
			last_reg<=0;
			
		end
		else begin
			for(idx=0; idx<8; idx=idx+1)begin
				src_reg[idx]<=src_nxt[idx];
			end
			pv_reg<=pv_nxt;
			ph_reg<=ph_nxt;
			cnt_reg<=cnt_nxt;
			encoded_reg<=encoded_nxt;
			ready_reg<=ready_nxt;
			out_valid_reg<=out_valid_nxt;
			last_reg<=last_nxt;
		end
	end
	
	always@(*)begin
		for(idx=0; idx<8; idx=idx+1)begin
			src_nxt[idx]=src_reg[idx];
		end
		pv_nxt=pv_reg;
		ph_nxt=ph_reg;
		cnt_nxt=cnt_reg;
		encoded_nxt=encoded_reg;
		ready_nxt=ready_reg;
		out_valid_nxt=out_valid_reg;
		last_nxt=last_reg;
		
		if(TVALID&TREADY)begin
			if(TUSER)begin
				src_nxt[0]=TDATA[15:8];
				src_nxt[1]=TDATA[7:0];
				pv_nxt[0]=^TDATA[15:8];
				pv_nxt[1]=^TDATA[7:0];
				for(idx=0; idx<8; idx=idx+1)begin
				ph_nxt[idx]=TDATA[idx]^TDATA[idx+8];
				end
				cnt_nxt=1;	
				encoded_nxt=0;
				ready_nxt=1;
				out_valid_nxt=0;
				last_nxt[0]=TLAST;
			end
			else begin
				src_nxt[2*cnt_reg]=TDATA[15:8];
				src_nxt[2*cnt_reg+1]=TDATA[7:0];
				pv_nxt[2*cnt_reg]=^TDATA[15:8];
				pv_nxt[2*cnt_reg+1]=^TDATA[7:0];	
				last_nxt[cnt_reg]=TLAST;
				for(idx=0; idx<8; idx=idx+1)begin
					ph_nxt[idx]=ph_reg[idx]^TDATA[idx]^TDATA[idx+8];
				end
				
				if(cnt_reg==3)begin
					ready_nxt=0;
					out_valid_nxt=0;
					
				end
				cnt_nxt=cnt_reg+1;				
			end
		end
		if(cnt_reg==4)begin
			out_valid_nxt=1;
			ready_nxt=0;
			encoded_nxt={ph_reg,pv_reg,src_reg[7],src_reg[6],src_reg[5],src_reg[4],src_reg[3],src_reg[2],src_reg[1],src_reg[0]};
		end

		if(OUT_VALID&OUT_READY)begin
			cnt_nxt=0;	
			ready_nxt=1;
			for(idx=0; idx<8; idx=idx+1)begin
				src_nxt[idx]=0;
			end
			pv_nxt=0;
			ph_nxt=0;
			encoded_nxt=0;
			out_valid_nxt=0;
			last_nxt=0;
		end
	end
assign TREADY=ready_reg;
assign OUT_VALID=out_valid_reg;
assign OUT_DATA=encoded_reg;
assign OUT_LAST=|last_reg;
endmodule

