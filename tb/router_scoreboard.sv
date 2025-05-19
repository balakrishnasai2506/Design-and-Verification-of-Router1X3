class router_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(router_scoreboard)

	//Declare TLM Analysis FIFOs for getting the data
	uvm_tlm_analysis_fifo#(source_xtn) fifo_src;
	uvm_tlm_analysis_fifo#(dest_xtn) fifo_dst[]; //As we have 3 destinations... We'll have 3 monitors
	
	//Declare handles for src and dst_xtn for storing the fifo data
	source_xtn src_data;
	dest_xtn dest_data;

	//Declare handles of src and dst xtn for coverage
	source_xtn src_cov_data;
	dest_xtn dst_cov_data;

	//Declare handle for env_config for getting the no_of_agt value for allotting the size for fifo
	env_config e_cfg;

	//Some int type variables for keeping a count of checks
	int data_verified;

	//UVM Methods
	extern function new(string name = "router_scoreboard", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern function void check_data(dest_xtn xtn);
	extern function void report_phase(uvm_phase phase);

	//Define Covergroups for both SRC and DST
	covergroup router_fcov1;
		option.per_instance = 1;
		ADDR: coverpoint  src_cov_data.header[1:0] {
								bins dest1 = {2'b00};
								bins dest2 = {2'b01};
								bins dest3 = {2'b10};
							  }


		PAYLOAD: coverpoint src_cov_data.header[7:2] {
								bins small_pkt = {[1:20]};
								bins medium_pkt = {[21:40]};
								bins large_pkt = {[41:63]};
							     }


		ERROR: coverpoint src_cov_data.error {
							bins bad_pkt = {1};
							bins good_pkt = {0};
						   }


		ADDR_X_PAYLOAD_X_ERROR: cross ADDR, PAYLOAD, ERROR;

	endgroup


        covergroup router_fcov2;
                option.per_instance = 1;
                ADDR: coverpoint  dst_cov_data.header[1:0] {
                                                                bins dest1 = {2'b00};
                                                                bins dest2 = {2'b01};
                                                                bins dest3 = {2'b10};
                                                          }


                PAYLOAD: coverpoint dst_cov_data.header[7:2] {
                                                                bins small_pkt = {[1:20]};
                                                                bins medium_pkt = {[21:40]};
                                                                bins large_pkt = {[41:63]};
                                                             }

		ADDR_X_PAYLOAD: cross ADDR, PAYLOAD;
	endgroup

endclass


//-----------------------------Constructor "new"-----------------------------------
function router_scoreboard::new(string name = "router_scoreboard", uvm_component parent);
	super.new(name, parent);

	router_fcov1 = new;
	router_fcov2 = new;
endfunction


//-----------------------------Build Phase()-----------------------------------
function void router_scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(env_config)::get(this,"","env_config",e_cfg))
		`uvm_fatal("SCOREBOARD","Couldn't get ENV_CONFIG from uvm_config_db... Did you set it right???")

	fifo_src = new("fifo_src", this);
	fifo_dst = new[e_cfg.no_of_dst_agt];

	foreach(fifo_dst[i]) begin
		fifo_dst[i] = new($sformatf("fifo_dst[%0d]",i), this);
	end
endfunction



//-----------------------------Run Phase()--------------------------------
task router_scoreboard::run_phase(uvm_phase phase);
	fork begin
		forever begin
			fifo_src.get(src_data);
			`uvm_info("SOURCE SB","SOURCE DATA",UVM_LOW)
			src_data.print;
			src_cov_data = src_data;
			router_fcov1.sample();
		end
	end

	begin
		forever begin
			wait(src_data != null);

			fork begin
				fifo_dst[0].get(dest_data);
				`uvm_info("DESTINATION SB[0]", "DEST DATA", UVM_LOW)
				dest_data.print;
				check_data(dest_data);
				dst_cov_data = dest_data;
				router_fcov2.sample();
			end
			
			begin
				fifo_dst[1].get(dest_data);
				`uvm_info("DESTINATION SB[1]", "DEST DATA", UVM_LOW)
				dest_data.print;
				check_data(dest_data);
				dst_cov_data = dest_data;
				router_fcov2.sample();
			end


			begin
				fifo_dst[2].get(dest_data);
				`uvm_info("DESTINATION SB[2]", "DEST DATA", UVM_LOW)
				dest_data.print;
				check_data(dest_data);
				dst_cov_data = dest_data;
				router_fcov2.sample();
			end
			join_any
			disable fork;
		end
	end
	join
endtask


//-----------------------------Check Data()-----------------------------------
function void router_scoreboard::check_data(dest_xtn xtn);
	if(src_data.header == xtn.header)
		`uvm_info("SB","HEADER MATCHED!",UVM_MEDIUM)
	else
		`uvm_error("SB","HEADER MISMATCHED :-(")



	if(src_data.payload == xtn.payload)
		`uvm_info("SB","PAYLOAD MATCHED!",UVM_MEDIUM)
	else
		`uvm_error("SB","PAYLOAD MISMATCHED :-(")



	if(src_data.parity == xtn.parity)
		`uvm_info("SB","PARITY MATCHED!",UVM_MEDIUM)
	else
		`uvm_error("SB","PARITY MISMATCHED :-(")

	data_verified++;

endfunction


//-----------------------------Report Phase()-----------------------------------
function void router_scoreboard::report_phase(uvm_phase phase);
	`uvm_info(get_type_name(), $sformatf("SCOREBOARD REPORT:\n DATA VERIFIED = %0d\n", data_verified), UVM_LOW)
endfunction
