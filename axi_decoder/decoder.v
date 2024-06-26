module lpc_decoder(
			input wire ACLK,
			input wire ARESET_N,
			input wire[79:0] TDATA,
			input wire TVALID,
			output wire TREADY,
			input wire EN,
			input wire TUSER,
			input wire TLAST,

			output wire[15:0] OUT_DECODED,
			output wire OUT_VALID,
			input wire OUT_READY,
			output wire OUT_LAST,
			output wire OUT_USER
		);
	localparam RECEIVE_STATE=3'b000;
	localparam SYNDROME_STATE=3'b001;
	localparam CORRECTION_STATE=3'b010;
	localparam APPLY_STATE=3'b011;
	localparam TRANSMIT_STATE=3'b100;

	reg[79:0] data_reg, data_nxt;
	reg ready_reg, ready_nxt;
	reg valid_reg, valid_nxt;
	reg[3:0] state_reg, state_nxt;
	reg[7:0] ph_reg, ph_nxt;
	reg[7:0] pv_reg, pv_nxt;
	reg[3:0] cnt_reg, cnt_nxt;
	reg [3:0] out_last_reg, out_last_nxt;
	reg [3:0] out_user_reg, out_user_nxt;

	reg[3:0] idx;
	reg[4:0] err_pos_row_reg, err_pos_row_nxt;
	reg[4:0] err_pos_col_reg, err_pos_col_nxt;

	always@(posedge ACLK or negedge ARESET_N)begin
		if(~ARESET_N)begin
			data_reg<=0;
			ready_reg<=1;
			valid_reg<=0;
			state_reg<=RECEIVE_STATE;
			pv_reg<=0;
			ph_reg<=0;
			err_pos_row_reg<=8;
			err_pos_col_reg<=8;
			cnt_reg<=0;
			out_last_reg<=0;
			out_user_reg<=0;

		end else begin
			data_reg<=data_nxt;
			ready_reg<=ready_nxt;
			valid_reg<=valid_nxt;
			state_reg<=state_nxt;
			pv_reg<=pv_nxt;
			ph_reg<=ph_nxt;
			err_pos_row_reg<=err_pos_row_nxt;
			err_pos_col_reg<=err_pos_col_nxt;
			cnt_reg<=cnt_nxt;
			out_last_reg<=out_last_nxt;
			out_user_reg<=out_user_nxt;
		
		end
	end
	always@(*)begin
		data_nxt=data_reg;
		ready_nxt=ready_reg;
		valid_nxt=valid_reg;
		state_nxt=state_reg;
		pv_nxt=pv_reg;
		ph_nxt=ph_reg;
		err_pos_row_nxt=err_pos_row_reg;
		err_pos_col_nxt=err_pos_col_reg;
		cnt_nxt=cnt_reg;
		out_last_nxt=out_last_reg;
		out_user_nxt=out_user_reg;

		case(state_reg)
			RECEIVE_STATE: begin
				if(TREADY&TVALID)begin
					data_nxt=TDATA;
					out_last_nxt={TLAST, 3'b0};
					out_user_nxt={3'b0, TUSER};
					ready_nxt=0;
					valid_nxt=0;
					pv_nxt=0;
					ph_nxt=0;
					err_pos_col_nxt=8;
					err_pos_row_nxt=8;
					if(EN)begin
						state_nxt=SYNDROME_STATE;
					end else begin
						state_nxt=TRANSMIT_STATE;
						valid_nxt=1;
					end
				end
			end
			SYNDROME_STATE: begin
				for(idx=0; idx<8; idx=idx+1)begin
					pv_nxt[idx]=^data_reg[8*idx+:8];
				end
				ph_nxt[0]=data_reg[0]^data_reg[8]^data_reg[16]^data_reg[24]^data_reg[32]^data_reg[40]^data_reg[48]^data_reg[56];
				ph_nxt[1]=data_reg[1]^data_reg[9]^data_reg[17]^data_reg[25]^data_reg[33]^data_reg[41]^data_reg[49]^data_reg[57];
				ph_nxt[2]=data_reg[2]^data_reg[10]^data_reg[18]^data_reg[26]^data_reg[34]^data_reg[42]^data_reg[50]^data_reg[58];
				ph_nxt[3]=data_reg[3]^data_reg[11]^data_reg[19]^data_reg[27]^data_reg[35]^data_reg[43]^data_reg[51]^data_reg[59];
				ph_nxt[4]=data_reg[4]^data_reg[12]^data_reg[20]^data_reg[28]^data_reg[36]^data_reg[44]^data_reg[52]^data_reg[60];
				ph_nxt[5]=data_reg[5]^data_reg[13]^data_reg[21]^data_reg[29]^data_reg[37]^data_reg[45]^data_reg[53]^data_reg[61];
				ph_nxt[6]=data_reg[6]^data_reg[14]^data_reg[22]^data_reg[30]^data_reg[38]^data_reg[46]^data_reg[54]^data_reg[62];
				ph_nxt[7]=data_reg[7]^data_reg[15]^data_reg[23]^data_reg[31]^data_reg[39]^data_reg[47]^data_reg[55]^data_reg[63];

				ready_nxt=0;
				valid_nxt=0;
				state_nxt=CORRECTION_STATE;
				err_pos_col_nxt=8;
				err_pos_row_nxt=8;
				
			end
			CORRECTION_STATE: begin
				//data_nxt={ph_reg,pv_reg};
				ready_nxt=0;
				valid_nxt=0;
				for(idx=0; idx<8; idx=idx+1)begin
					if(pv_reg[idx]!=data_reg[64+idx])begin
						err_pos_row_nxt=idx;
					end
						
				end
				for(idx=0; idx<8; idx=idx+1)begin
					if(ph_reg[idx]!=data_reg[72+idx])begin
						err_pos_col_nxt=idx;
					end
						
				end
				state_nxt=APPLY_STATE;
			end
			APPLY_STATE: 	begin
				if(err_pos_col_reg!=8 && err_pos_row_reg!=8)begin
					data_nxt[err_pos_row_reg*8+err_pos_col_reg]= ~data_reg[err_pos_row_reg*8+err_pos_col_reg];
				end
				valid_nxt=1;
				state_nxt=TRANSMIT_STATE;
			end
			TRANSMIT_STATE: begin
				if(OUT_VALID&OUT_READY)begin
					if(cnt_reg==3)begin
						valid_nxt=0;
						ready_nxt=1;
						cnt_nxt=0;
						state_nxt=RECEIVE_STATE;
						err_pos_row_nxt=8;
						err_pos_col_nxt=8;
						ph_nxt=0;
						pv_nxt=0;
						data_nxt=0;
						out_last_nxt=0;
					end else begin
						valid_nxt=1;
						ready_nxt=0;
						cnt_nxt=cnt_reg+1;
						state_nxt=TRANSMIT_STATE;
						data_nxt=data_reg>>16;
						out_last_nxt=out_last_reg>>1;
						out_user_nxt=out_user_reg>>1;
					end
				end
			end
		endcase
	end

assign TREADY=ready_reg;
assign OUT_VALID=valid_reg;
assign OUT_DECODED= {data_reg[7:0],data_reg[15:8]};
assign OUT_LAST = out_last_reg[0];
assign OUT_USER = out_user_reg[0];
endmodule
