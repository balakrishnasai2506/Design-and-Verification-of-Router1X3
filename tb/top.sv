module top;
	//Import UVM and Local Packages
	import uvm_pkg::*;
	import router_pkg::*;

	//Generating Clock
	bit clk;
	always #5 clk = ~clk;

	//Instantiating Interfaces
	router_if rif(clk);
	router_if rif0(clk);
	router_if rif1(clk);
	router_if rif2(clk);

	//Instantiating DUT/RTL and passing interface instance as an argument
	/*module router_top(clock, resetn, read_enb_0, read_enb_1, read_enb_2, data_in, pkt_valid,
                  data_out_0, data_out_1, data_out_2, valid_out_0, valid_out_1, valid_out_2, error, busy
 	);*/
	router_top DUT(
			.clock(clk),
			.resetn(rif.resetn),
			.read_enb_0(rif0.read_enb),
			.read_enb_1(rif1.read_enb),
			.read_enb_2(rif2.read_enb),
			.data_in(rif.data_in),
			.pkt_valid(rif.pkt_valid),
			.data_out_0(rif0.data_out),
			.data_out_1(rif1.data_out),
			.data_out_2(rif2.data_out),
			.valid_out_0(rif0.valid_out),
			.valid_out_1(rif1.valid_out),
			.valid_out_2(rif2.valid_out),
			.error(rif.error),
			.busy(rif.busy)
		      );

	initial begin
		//Set the virtual interfaces as strings into uvm_config_db
		uvm_config_db#(virtual router_if)::set(null,"*","vif",rif);
		uvm_config_db#(virtual router_if)::set(null,"*","vif_0",rif0);
		uvm_config_db#(virtual router_if)::set(null,"*","vif_1",rif1);
		uvm_config_db#(virtual router_if)::set(null,"*","vif_2",rif2);

		//Call run_test()
		run_test();
	end

	//Assertions
	property stable_data;
		@(posedge clk) rif.busy |=> $stable(rif.data_in);
	endproperty

	property check_busy;
		@(posedge clk) $rose(rif.pkt_valid) |=> rif.busy;
	endproperty

	property check_valid; 
		@(posedge clk) $rose(rif.pkt_valid) |-> ##3 (rif0.valid_out | rif1.valid_out | rif2.valid_out);
	endproperty

	property check_rd0; 
		@(posedge clk) $rose(rif0.valid_out) |-> ##[1:29] rif0.read_enb;
	endproperty

	property check_rd1; 
		@(posedge clk) $rose(rif1.valid_out) |-> ##[1:29] rif1.read_enb;
	endproperty

	property check_rd2;
		@(posedge clk) $rose(rif2.valid_out) |-> ##[1:29] rif2.read_enb;
	endproperty

	property check_rd0_low; 
		@(posedge clk) $fell(rif0.valid_out) |=> $fell( rif0.read_enb);
	endproperty

	property check_rd1_low;
		@(posedge clk) $fell(rif1.valid_out) |=> $fell( rif1.read_enb);
	endproperty

	property check_rd2_low; 
		@(posedge clk) $fell(rif2.valid_out) |=> $fell( rif2.read_enb);
	endproperty

	C1 : assert property(stable_data)
		$display("ASSERTION SUCCESS - STABLE DATA");
		else
		$display("ASSERTION FAILED - STABLE DATA");

	C1_COV : cover property(stable_data);

	C2 : assert property(check_busy)
		$display("ASSERTION SUCCESS - CHECK BUSY");
		else
		$display("ASSERTION FAILED - CHECK BUSY");

	C2_COV : cover property(check_busy);

	C3 : assert property(check_valid)
		$display("ASSERTION SUCCESS - CHECK VALID");
		else
		$display("ASSERTION FAILED - CHECK VALID");

	C3_COV : cover property(check_valid);

endmodule
