class virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);
	`uvm_component_utils(virtual_sequencer) //Factory Registration

	//Declare dynamic handles for source and destination sequencers
	source_sequencer src_seqr[];
	dest_sequencer dst_seqr[];

	//Declare handle for env config
	env_config e_cfg;

	//Methods
	extern function new(string name = "virtual_sequencer", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
endclass


//-------------------------------Constructor "new"-----------------------------------
function virtual_sequencer::new(string name = "virtual_sequencer", uvm_component parent);
	super.new(name, parent);
endfunction


//-------------------------------Build Phase()-----------------------------------
function void virtual_sequencer::build_phase(uvm_phase phase);
	if(!uvm_config_db #(env_config)::get(this, "*","env_config", e_cfg))
		`uvm_fatal("VIRTUAL_SEQUENCER","COULDN'T GET ENV CONFIG FROM UVM_CONFIG_DB... DID YOU SET IT RIGHT????") 
			super.build_phase(phase);
	
	//Allot memory for the sequencers using env_cfg
	src_seqr = new[e_cfg.no_of_src_agt];
	dst_seqr = new[e_cfg.no_of_dst_agt];
endfunction
