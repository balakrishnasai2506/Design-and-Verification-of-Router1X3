class env_config extends uvm_object;

	`uvm_object_utils(env_config) //Factory Registration

	//Source and Destination Agent Configuration Class Handles Declaration
	source_agent_config src_agt_cfg[];
	dest_agent_config dst_agt_cfg[];

	//Data Members
	int no_of_src_agt, no_of_dst_agt;
	bit has_virtual_sequencer = 1;
	bit has_scoreboard = 1;
	int no_of_duts;

	//Methods
	extern function new(string name = "env_config");

endclass

//---------------------Constructor "new"---------------------------

function env_config::new(string name = "env_config");
	super.new(name);
endfunction
