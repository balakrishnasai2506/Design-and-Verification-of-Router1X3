module router_sync(detect_add, data_in, write_enb_reg, clock, resetn, read_enb_0, read_enb_1, read_enb_2, empty_0, empty_1, empty_2, full_0, full_1, full_2, write_enb, fifo_full, vld_out_0, vld_out_1, vld_out_2, soft_reset_0, soft_reset_1, soft_reset_2);

 // Input ports
 input detect_add, clock, resetn, write_enb_reg, read_enb_0, read_enb_1, read_enb_2, empty_0, empty_1, empty_2, full_0, full_1, full_2;
 input [1:0]data_in;
 
 // Output ports
 output reg fifo_full;
 output vld_out_0, vld_out_1, vld_out_2;
 output reg soft_reset_0, soft_reset_1, soft_reset_2;
 output reg [2:0]write_enb;
 
 // internal registers
 reg [1:0]fifo_addr;
 reg [4:0]count_0_sft_rst, count_1_sft_rst, count_2_sft_rst;
 
 // Logic for capturing address
 always@(posedge clock) begin
  if(!resetn)
   fifo_addr <= 2'b0;
  else if(detect_add)
   fifo_addr <= data_in;
 end
 
 // Logic for write enable
 always@(*) begin
  if(!write_enb_reg)
   write_enb <= 3'b0;
  else begin
   case(fifo_addr)
    2'b00 : write_enb <= 3'b001;
    2'b01 : write_enb <= 3'b010;
    2'b10 : write_enb <= 3'b100;
    default : write_enb <= 3'b0;
   endcase
  end
 end
 
 // Logic for fifo_full
 always@(*) begin
  case(fifo_addr)
   2'b00 : fifo_full = full_0;
   2'b01 : fifo_full = full_1;
   2'b10 : fifo_full = full_2;
   default : fifo_full = 1'b0;
  endcase
 end
 
 // Logic for Valid signals
 assign vld_out_0 = !empty_0;
 assign vld_out_1 = !empty_1;
 assign vld_out_2 = !empty_2;
 
 // Logic for soft_reset_0 for FIFO-0
 always@(posedge clock) begin
  if(!resetn) begin
   soft_reset_0 <= 1'b0;
   count_0_sft_rst <= 5'd1;
  end
  else if(!vld_out_0) begin
   soft_reset_0 <= 1'b0;
   count_0_sft_rst <= 5'd1;
  end
  else if(read_enb_0) begin
   soft_reset_0 <= 1'b0;
   count_0_sft_rst <= 5'd1;
  end
  else if(count_0_sft_rst == 5'd30) begin
   soft_reset_0 <= 1'b1;
   count_0_sft_rst <= 5'd1;
  end
  else begin
   soft_reset_0 <= 1'b0;
   count_0_sft_rst <= count_0_sft_rst + 5'd1;
  end
 end
 
 // Logic for soft_reset_1 for FIFO-1
 always@(posedge clock) begin
  if(!resetn) begin
   soft_reset_1 <= 1'b0;
   count_1_sft_rst <= 5'd1;
  end
  else if(!vld_out_1) begin
   soft_reset_1 <= 1'b0;
   count_1_sft_rst <= 5'd1;
  end
  else if(read_enb_1) begin
   soft_reset_1 <= 1'b0;
   count_1_sft_rst <= 5'd1;
  end
  else if(count_1_sft_rst == 5'd30) begin
   soft_reset_1 <= 1'b1;
   count_1_sft_rst <= 5'd1;
  end
  else begin
   soft_reset_1 <= 1'b0;
   count_1_sft_rst <= count_1_sft_rst + 5'd1;
  end
 end
 
 // Logic for soft_reset_2 for FIFO-2
 always@(posedge clock) begin
  if(!resetn) begin
   soft_reset_2 <= 1'b0;
   count_2_sft_rst <= 5'd1;
  end
  else if(!vld_out_2) begin
   soft_reset_2 <= 1'b0;
   count_2_sft_rst <= 5'd1;
  end
  else if(read_enb_2) begin
   soft_reset_2 <= 1'b0;
   count_2_sft_rst <= 5'd1;
  end
  else if(count_2_sft_rst == 5'd30) begin
   soft_reset_2 <= 1'b1;
   count_2_sft_rst <= 5'd1;
  end
  else begin
   soft_reset_2 <= 1'b0;
   count_2_sft_rst <= count_2_sft_rst + 5'd1;
  end
 end
endmodule
