class dest_agent_config extends uvm_object;

	`uvm_object_utils(dest_agent_config) //Factory Registration

	//virtual interface handle declaration
	virtual router_if vif;

	//Data Member
	uvm_active_passive_enum is_active = UVM_ACTIVE;

	//Methods
	extern function new(string name = "dest_agent_config");

endclass

//-------------Constructor "new"-------------

function dest_agent_config::new(string name = "dest_agent_config");
	super.new(name);
endfunction
