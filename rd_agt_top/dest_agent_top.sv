class dest_agent_top extends uvm_env;
	`uvm_component_utils(dest_agent_top) //Factory Registration

	//Declare Write Agent handle
	dest_agent dst_agnth[];

	//Declare a handle for env_config
	env_config e_cfg;

	//Standard Methods
	extern function new(string name = "dest_agent_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
endclass


//---------------------------------Constructor "new"-------------------------------------
function dest_agent_top::new(string name = "dest_agent_top", uvm_component parent);
	super.new(name,parent);
endfunction


//---------------------------------Build Phase-------------------------------------
function void dest_agent_top::build_phase(uvm_phase phase);
	super.build_phase(phase);

	//Get the env_config from uvm_config_db
	if(!uvm_config_db #(env_config)::get(this,"*","env_config",e_cfg))
		`uvm_fatal(get_type_name(),"Could not get ENV_CONFIG.... Did u set it???")

	dst_agnth = new[e_cfg.no_of_dst_agt]; //Alloting memory to agent
	
	//Creating the object for dest_agt and setting the dest_agt_cfg into dest_agt
	foreach(dst_agnth[i]) begin
		dst_agnth[i] = dest_agent::type_id::create($sformatf("dst_agnth[%0d]",i),this);
		uvm_config_db #(dest_agent_config)::set(this,$sformatf("dst_agnth[%0d]",i),"dest_agent_config",e_cfg.dst_agt_cfg[i]);
	end
endfunction

