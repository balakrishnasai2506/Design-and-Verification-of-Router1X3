class source_monitor extends uvm_monitor;
	`uvm_component_utils(source_monitor) // Factory Registration
	
	virtual router_if.MON_MP vif; //Declare virtual interface handle along with modport
	source_agent_config scfg; //Declare handle for source agent config class
	uvm_analysis_port #(source_xtn) ap; // Declare analysis port so that it can be connected to scoreboard in the future

	//Methods
	extern function new(string name = "source_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
endclass

//--------------------------Constructor "new"-----------------------------
function source_monitor::new(string name = "source_monitor", uvm_component parent);
	super.new(name, parent);
	ap = new("ap", this); //Create object for analysis_port
endfunction


//--------------------------Build Phase()-----------------------------
function void source_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the agent config class so that we can connect the monitor to dut via virtual interface
	if(!uvm_config_db #(source_agent_config)::get(get_parent(),"","source_agent_config",scfg))
		`uvm_fatal("SOURCE_MONITOR","Couldn't get agent config from uvm_config_db... Did you set it right???")
endfunction


//--------------------------Connect Phase()-----------------------------
function void source_monitor::connect_phase(uvm_phase phase);
	vif = scfg.vif; //Assign vif handle with scfg's vif
endfunction


//--------------------------Run Phase()-----------------------------
task source_monitor::run_phase(uvm_phase phase);
	forever begin
		collect_data();
	end
endtask


//--------------------------collect_data()-----------------------------
task source_monitor::collect_data();
	//Declare a handle for transaction class to store the sampled data
	source_xtn data_sent;
	
	//Create object for transaction class
	data_sent = source_xtn::type_id::create("data_sent");

	wait(vif.mon_cb.pkt_valid);
	wait(!vif.mon_cb.busy);

	data_sent.header = vif.mon_cb.data_in;
	@(vif.mon_cb);
	
	//Allot memory for payload as it is a dynamic array
	data_sent.payload = new[data_sent.header[7:2]];
	@(vif.mon_cb);

	foreach(data_sent.payload[i]) begin
		wait(!vif.mon_cb.busy);
		data_sent.payload[i] = vif.mon_cb.data_in;
		@(vif.mon_cb);
	end

	@(vif.mon_cb);
	wait(!vif.mon_cb.pkt_valid);
	data_sent.parity = vif.mon_cb.data_in;
	
	$display("------------------------------------------------------------------------");
	$display("Data Collected from Monitor.....");
	$display("------------------------------------------------------------------------");
	
	repeat(2)
	@(vif.mon_cb);

	data_sent.error = vif.mon_cb.error;
	`uvm_info("SOURCE_MONITOR",$sformatf("printing from monitor \n %s", data_sent.sprint()),UVM_LOW) 
	ap.write(data_sent); //Sending the sampled elements to SB using analysis port
endtask
