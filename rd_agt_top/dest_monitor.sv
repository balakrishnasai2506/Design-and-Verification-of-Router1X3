class dest_monitor extends uvm_monitor;
	`uvm_component_utils(dest_monitor) // Factory Registration

	virtual router_if.DMON_MP vif;
	dest_agent_config dcfg;
	uvm_analysis_port #(dest_xtn) ap;
	//Methods
	extern function new(string name = "dest_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
endclass

//--------------------------Constructor "new"-----------------------------
function dest_monitor::new(string name = "dest_monitor", uvm_component parent);
	super.new(name, parent);
	ap = new("ap", this);
endfunction


//--------------------------Build Phase()-----------------------------
function void dest_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the agent config from uvm_config_db to retrieve vif
	if(!uvm_config_db #(dest_agent_config)::get(get_parent(),"","dest_agent_config",dcfg))
		`uvm_fatal("DESTINATION_MONITOR","Could not get agent config from uvm_config_db... Did you set it????")
endfunction


//--------------------------Connect Phase()-----------------------------
function void dest_monitor::connect_phase(uvm_phase phase);
	vif = dcfg.vif;
endfunction


//--------------------------Run Phase()-----------------------------
task dest_monitor::run_phase(uvm_phase phase);
	forever begin
		collect_data();
	end
endtask


//--------------------------Collect Data()-----------------------------
task dest_monitor::collect_data();
	//Declare a handle for transaction class
	dest_xtn data_sent;

	//Create object for the transaction class
	data_sent = dest_xtn::type_id::create("data_sent");

	wait(vif.dmon_cb.read_enb);

	@(vif.dmon_cb);

	data_sent.header = vif.dmon_cb.data_out;

	@(vif.dmon_cb);

	data_sent.payload = new[data_sent.header[7:2]];

	foreach(data_sent.payload[i]) begin
		data_sent.payload[i] = vif.dmon_cb.data_out;
		@(vif.dmon_cb);
	end

	data_sent.parity = vif.dmon_cb.data_out;
	$display("------------------------------------------------------------------------");
	$display("Data Collected from Destination Monitor.....");
	$display("------------------------------------------------------------------------");
	data_sent.print();

	repeat(2)
	@(vif.dmon_cb);

	ap.write(data_sent);
endtask
