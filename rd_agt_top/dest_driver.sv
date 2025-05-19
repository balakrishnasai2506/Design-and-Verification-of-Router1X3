class dest_driver extends uvm_driver #(dest_xtn);
	`uvm_component_utils(dest_driver) // Factory Registration
	
	virtual router_if.DDRV_MP vif; //Declare a handle for virtual interface along with modport
	dest_agent_config dcfg;

	//Methods
	extern function new(string name = "dest_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(dest_xtn xtn);
endclass

//------------------------Constructor "new"---------------------------
function dest_driver::new(string name = "dest_driver", uvm_component parent);
	super.new(name,parent);
endfunction


//------------------------Build Phase()---------------------------
function void dest_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the agent conifg from uvm_config_db to retrieve and connect vif
	if(!uvm_config_db #(dest_agent_config)::get(get_parent(),"","dest_agent_config", dcfg))
		`uvm_fatal("DESTINATION_DRIVER","Couldn't get agent config from uvm_config_db.... Did you set it right???")
endfunction


//------------------------Connect Phase()---------------------------
function void dest_driver::connect_phase(uvm_phase phase);
	vif = dcfg.vif; // assign cfg's vif to drv's vif
endfunction


//------------------------Run Phase()---------------------------
task dest_driver::run_phase(uvm_phase phase);
	forever begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);
		seq_item_port.item_done();
	$display("------------------------------------------------------------------------");
	$display("Data Driver from the Destination Driver...");
	$display("------------------------------------------------------------------------");
		req.print();
	end	
endtask


//------------------------Send To DUT()---------------------------
task dest_driver::send_to_dut(dest_xtn xtn);
	wait(vif.ddrv_cb.valid_out);

	repeat(xtn.delay)
	@(vif.ddrv_cb);
	vif.ddrv_cb.read_enb <= 1'b1;

	@(vif.ddrv_cb);
	wait(~vif.ddrv_cb.valid_out);
	@(vif.ddrv_cb);
	vif.ddrv_cb.read_enb <= 1'b0;
endtask
