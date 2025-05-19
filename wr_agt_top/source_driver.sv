class source_driver extends uvm_driver#(source_xtn);
	`uvm_component_utils(source_driver) // Factory Registration

	virtual router_if.DRV_MP vif;
	source_agent_config scfg;
	//Methods
	extern function new(string name = "source_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(source_xtn xtn);
endclass

//------------------------Constructor "new"---------------------------
function source_driver::new(string name = "source_driver", uvm_component parent);
	super.new(name,parent);
endfunction


//------------------------Build Phase()---------------------------
function void source_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the agent config for retrieving virtual interface
	if(!uvm_config_db#(source_agent_config)::get(get_parent(),"","source_agent_config",scfg))
		`uvm_fatal("SOURCE_DRIVER","Couldn't get AGENT CONFIG from UVM_CONFIG_DB... Did u set it right???")
endfunction


//------------------------Connect Phase()---------------------------
function void source_driver::connect_phase(uvm_phase phase);
	vif = scfg.vif; //Assign the agent config's virtual interface handle to driver's virtual interface handle
endfunction


//------------------------Run Phase()---------------------------
task source_driver::run_phase(uvm_phase phase);
	//Reset logic
	@(vif.drv_cb);
	vif.drv_cb.resetn <= 1'b0;
	@(vif.drv_cb);
	vif.drv_cb.resetn <= 1'b1;

	forever begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);
		seq_item_port.item_done();
		$display("------------------------------------------------------------------------");
		$display("Data Driven from Source Driver...");
		$display("------------------------------------------------------------------------");
		req.print();
	end
endtask


//------------------------send_to_dut()---------------------------
task source_driver::send_to_dut(source_xtn xtn);
	
	@(vif.drv_cb)
	wait(~vif.drv_cb.busy);

	vif.drv_cb.pkt_valid <= 1'b1;
	vif.drv_cb.data_in <= xtn.header;
	@(vif.drv_cb);
	
	foreach(xtn.payload[i]) 
             begin
		wait(~vif.drv_cb.busy);
		vif.drv_cb.data_in <= xtn.payload[i];
		@(vif.drv_cb);
	end
	
	wait(~vif.drv_cb.busy);
	vif.drv_cb.pkt_valid <= 1'b0;
	vif.drv_cb.data_in <= xtn.parity;
	
endtask
