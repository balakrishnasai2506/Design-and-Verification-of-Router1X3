class source_sequencer extends uvm_sequencer#(source_xtn);
	`uvm_component_utils(source_sequencer) // Factory Registration

	//Methods
	extern function new(string name = "source_sequencer", uvm_component parent);
endclass

//----------------------------Constructor "new"--------------------------------
function source_sequencer::new(string name = "source_sequencer", uvm_component parent);
	super.new(name, parent);
endfunction

