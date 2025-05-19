class source_agent_top extends uvm_env;
	`uvm_component_utils(source_agent_top) //Factory Registration

	//Declare Write Agent handle
	source_agent src_agnth[];

	//Declare a handle for env_config
	env_config e_cfg;

	//Standard Methods
	extern function new(string name = "source_agent_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
endclass


//---------------------------------Constructor "new"-------------------------------------
function source_agent_top::new(string name = "source_agent_top", uvm_component parent);
	super.new(name,parent);
endfunction


//---------------------------------Build Phase-------------------------------------
function void source_agent_top::build_phase(uvm_phase phase);
	super.build_phase(phase);

	//Get the env_config from uvm_config_db
	if(!uvm_config_db #(env_config)::get(this,"*","env_config",e_cfg))
		`uvm_fatal("SOURCE_AGENT","Could not get ENV_CONFIG.... Did u set it???")

	src_agnth = new[e_cfg.no_of_src_agt];

	foreach(src_agnth[i]) begin
		src_agnth[i] = source_agent::type_id::create($sformatf("src_agnth[%0d]",i),this);
		uvm_config_db #(source_agent_config)::set(this,$sformatf("src_agnth[%0d]",i),"source_agent_config",e_cfg.src_agt_cfg[i]);
	end
endfunction
