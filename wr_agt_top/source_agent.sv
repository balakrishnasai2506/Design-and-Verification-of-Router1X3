class source_agent extends uvm_agent;
	`uvm_component_utils(source_agent) //Factory Registration

	//Declare the handles for driver, monitor and sequencer
	source_driver s_drvh;
	source_monitor s_monh;
	source_sequencer s_seqrh;

	//Declare the handle for source_agent_config
	source_agent_config sagt_cfg;

	//Standard Methods
	extern function new(string name = "source_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass


//------------------------------Constructor "new"---------------------------------
function source_agent::new(string name = "source_agent", uvm_component parent);
	super.new(name,parent);
endfunction


//------------------------------Build Phase---------------------------------
function void source_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the agent config from uvm_config_db
	if(!uvm_config_db #(source_agent_config)::get(this,"","source_agent_config",sagt_cfg))
		`uvm_fatal("SOURCE AGENT","Could not get AGENT_CONFIG.... Did u set it???")

	//Create object for monitor
	s_monh = source_monitor::type_id::create("s_monh",this);

	//Create objects for driver and sequencer if is_active is UVM_ACTIVE
	if(sagt_cfg.is_active == UVM_ACTIVE) begin
		s_drvh = source_driver::type_id::create("s_drvh",this);
		s_seqrh = source_sequencer::type_id::create("s_seqrh",this);
	end

endfunction


//------------------------------Connect Phase---------------------------------
function void source_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	s_drvh.seq_item_port.connect(s_seqrh.seq_item_export);
endfunction
