module router_reg(clock, resetn, pkt_valid, data_in, fifo_full, rst_int_reg, detect_add, ld_state, laf_state, full_state, lfd_state, parity_done, low_pkt_valid, err, dout);
 
 // Input ports declaration
 input clock, resetn, pkt_valid, fifo_full, rst_int_reg, detect_add, ld_state, laf_state, full_state, lfd_state;
 input [7:0] data_in;
 
 // Output ports declaration
 output reg parity_done, low_pkt_valid, err;
 output reg [7:0] dout;
 
 // Internal registers declaration
 reg [7:0] header_byte;
 reg [7:0] fifo_full_state_byte;
 reg [7:0] packet_parity;
 reg [7:0] internal_parity;
 
 // Header_byte logic
 always@(posedge clock) begin
  if(!resetn)
   header_byte <= 8'b0000_0000;
  else if(detect_add && pkt_valid && data_in != 8'b0000_0011)
   header_byte <= data_in;
 end
 
 // Fifo_full_state_byte logic
 always@(posedge clock) begin
  if(!resetn)
   fifo_full_state_byte <= 8'b0000_0000;
  else if (ld_state && fifo_full)
   fifo_full_state_byte <= data_in;
 end
 
 // dout logic
 always@(posedge clock) begin
  if(!resetn)
   dout <= 8'b0000_0000;
  else if(lfd_state)
   dout <= header_byte;
  else if(ld_state && !fifo_full)
   dout <= data_in;
  else if(laf_state)
   dout <= fifo_full_state_byte;
 end
 
 // low_pkt_valid logic
 always@(posedge clock) begin
  if(!resetn)
   low_pkt_valid <= 1'b0;
  else if(rst_int_reg)
   low_pkt_valid <= 1'b0;
  else if(ld_state && ~pkt_valid)
   low_pkt_valid <=1'b1;
 end
 
 // Internal parity logic
 always@(posedge clock) begin
  if(!resetn)
   internal_parity <= 8'b0000_0000;
  else if(detect_add)
   internal_parity <= 8'b0000_0000;
  else if(lfd_state)
   internal_parity <= internal_parity ^ header_byte;
  else if(ld_state && pkt_valid && !full_state)
   internal_parity <= internal_parity ^ data_in;
 end
 
 // Packet parity and parity_done logic
 always@(posedge clock) begin
  if(!resetn) begin
   packet_parity <= 8'b0000_0000;
   parity_done <= 1'b0;
  end else if(detect_add) begin
   packet_parity <= 8'b0000_0000;
   parity_done <= 1'b0;
  end else if((ld_state && !pkt_valid && !fifo_full) || (laf_state && low_pkt_valid && ~parity_done)) begin
   packet_parity <= data_in;
   parity_done <= 1'b1;
  end
 end
 
 // Error logic
 always@(posedge clock) begin
  if(!resetn)
   err <= 1'b0;
  else begin
   if(parity_done) begin
    if(internal_parity == packet_parity)
     err <= 1'b0;
    else
     err <= 1'b1;
   end
   else
    err <= 1'b0;
  end
 end
endmodule
