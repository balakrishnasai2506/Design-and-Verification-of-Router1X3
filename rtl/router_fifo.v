module router_fifo (clock, resetn, write_enb, soft_reset, read_enb, data_in, lfd_state, empty, data_out, full);
 input clock, resetn, write_enb, soft_reset, read_enb, lfd_state;
 input [7:0]data_in;
 output empty, full;
 output reg [7:0]data_out;
 reg [8:0] mem [15:0];
 reg [4:0]wr_ptr, rd_ptr;
 reg [5:0]count;
 reg lfd_state_s;
 integer i;
 
 // Delaying lfd_state by 1 clk cycle
 always@(posedge clock) begin
  if(!resetn)
   lfd_state_s <= 1'b0;
  else
   lfd_state_s <= lfd_state;
 end
 
 // FIFO down-counting logic for internal counter
 always@(posedge clock) begin
  if(!resetn)
   count <= 6'b0;
  else if(soft_reset)
   count <= 6'b0;
  else if(read_enb && !empty) begin
   if(mem[rd_ptr[3:0]] [8] == 1'b1)
    count <= mem[rd_ptr[3:0]] [7:2] + 1;
   else if(count != 0)
    count <= count - 1'b1;
   end
 end
 
 // Read logic
 always@(posedge clock) begin
  if(!resetn) begin
   data_out <= 8'b0;
rd_ptr <= 5'b0;
  end
  else if(soft_reset) begin
   data_out <= 8'bz;
rd_ptr <= 5'b0;
  end
  else if(read_enb && !empty) begin
   data_out <= mem[rd_ptr [3:0]][7:0];
   rd_ptr <= rd_ptr + 1'b1;
  end
 end
 
 // Write logic
 always@(posedge clock) begin
  if(!resetn) begin
   for(i=0;i<16;i=i+1)
mem[i] <= 0;
wr_ptr <= 0;
//rd_ptr <= 0;
  end
   //mem[wr_ptr[3:0]] <= 8'b0;
  else if(soft_reset) begin
   for(i=0;i<16;i=i+1)
mem[i] <= 0;
wr_ptr <= 0;
//rd_ptr <= 0;
  end
   //mem[wr_ptr[3:0]] <= 8'b0;
  else if(write_enb && !full) begin
   mem[wr_ptr[3:0]] <= {lfd_state_s, data_in};
wr_ptr <= wr_ptr + 1'b1;
  end
 end
 
/* // wr_ptr incrementing logic
 always@(posedge clock) begin
  if(!resetn)
   wr_ptr <= 5'b0;
  else if(soft_reset)
   wr_ptr <= 5'b0;
  else if(write_enb && !full)
   wr_ptr <= (wr_ptr + 1) % 16;
 end
 
 // rd_ptr incrementing logic
 always@(posedge clock) begin
  if(!resetn)
   rd_ptr <= 5'b0;
  else if(soft_reset)
   rd_ptr <= 5'b0;
  else if(read_enb && !empty)
   rd_ptr <= (rd_ptr + 1) % 16;
 end */
 
 assign empty = (wr_ptr == rd_ptr) ? 1'b1 : 1'b0;
 assign full = (wr_ptr == 5'b10000 && rd_ptr == 5'b00000);
endmodule
