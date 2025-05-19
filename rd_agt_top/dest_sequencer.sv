class dest_sequencer extends uvm_sequencer #(dest_xtn);
	`uvm_component_utils(dest_sequencer) // Factory Registration

	//Methods
	extern function new(string name = "dest_sequencer", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
endclass

//----------------------------Constructor "new"--------------------------------
function dest_sequencer::new(string name = "dest_sequencer", uvm_component parent);
	super.new(name, parent);
endfunction

 
//----------------------------Build Phase-------------------------------------
function void dest_sequencer::build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("DEST_SEQUENCER", "Build phase executed.", UVM_LOW)
endfunction

