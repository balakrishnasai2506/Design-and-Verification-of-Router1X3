class dest_agent extends uvm_agent;
	`uvm_component_utils(dest_agent) //Factory Registration

	//Declare the handles for driver, monitor and sequencer
	dest_driver d_drvh;
	dest_monitor d_monh;
	dest_sequencer d_seqrh;

	//Declare the handle for dest_agent_config
	dest_agent_config dagt_cfg;

	//Standard Methods
	extern function new(string name = "dest_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass


//------------------------------Constructor "new"---------------------------------
function dest_agent::new(string name = "dest_agent", uvm_component parent);
	super.new(name,parent);
endfunction


//------------------------------Build Phase---------------------------------
function void dest_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the agent config from uvm_config_db
	if(!uvm_config_db #(dest_agent_config)::get(this,"","dest_agent_config",dagt_cfg))
		`uvm_fatal("DESTINATION AGENT","Could not get AGENT_CONFIG.... Did u set it???")

	//Create object for monitor
	d_monh = dest_monitor::type_id::create("d_monh",this);

	//Create objects for driver and sequencer if is_active is UVM_ACTIVE
	if(dagt_cfg.is_active == UVM_ACTIVE) begin
		d_drvh = dest_driver::type_id::create("d_drvh",this);
		d_seqrh = dest_sequencer::type_id::create("d_seqrh",this);
	end
endfunction


//------------------------------Connect Phase---------------------------------
function void dest_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	d_drvh.seq_item_port.connect(d_seqrh.seq_item_export);
endfunction
