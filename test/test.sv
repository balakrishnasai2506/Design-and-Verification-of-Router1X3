class router_test extends uvm_test;

	`uvm_component_utils(router_test) //Factory Registration

	//Declare Agent and Env config handles(Agent Cfgs as dynamic as the destination has 3 agents)
	source_agent_config s_cfg[];
	dest_agent_config d_cfg[];
	env_config e_cfg;

	//Declare router_env handle
	router_tb env;

	int no_of_wagts = 1; //Source agent
	int no_of_ragts = 3; //Destination agents

	int has_sagt = 1;
	int has_dagt = 1;
	int no_of_duts = 1;

	//Methods
	extern function new(string name = "router_test",uvm_component parent);
	extern function void config_router();
	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
endclass


//-------------------------------Constructor "new"--------------------------------------
function router_test::new(string name = "router_test",uvm_component parent);
	super.new(name,parent);
endfunction


//-------------------------------config_router() method--------------------------------------
function void router_test::config_router();
	if(has_sagt) begin
		s_cfg = new[no_of_wagts];
		foreach(s_cfg[i]) begin
			s_cfg[i] = source_agent_config::type_id::create($sformatf("s_cfg[%d]",i));
			if(!uvm_config_db#(virtual router_if)::get(this, "", "vif", s_cfg[i].vif))
				`uvm_fatal("VIF_CONG AT SOURCE","cannot get() interface from uvm_config_db, did you set it right?");
		$display("-----------------------%p",s_cfg[i]);
			s_cfg[i].is_active = UVM_ACTIVE;
				e_cfg.src_agt_cfg[i] = s_cfg[i];
		end
	end

	
	if(has_dagt) begin
                d_cfg = new[no_of_ragts];
                foreach(d_cfg[i]) begin
                        d_cfg[i] = dest_agent_config::type_id::create($sformatf("d_cfg[%d]",i));
                        if(!uvm_config_db#(virtual router_if)::get(this,"",$sformatf("vif_%0d",i),d_cfg[i].vif))
                                `uvm_fatal("VIF_CONG AT DESTINATION END","cannot get() interface from uvm_config_db, did you set it right?");
                $display("-----------------------%p",d_cfg[i]);
                        d_cfg[i].is_active = UVM_ACTIVE;
                                e_cfg.dst_agt_cfg[i] = d_cfg[i];
                end
        end

	e_cfg.no_of_src_agt = no_of_wagts;
	e_cfg.no_of_dst_agt = no_of_ragts;
	e_cfg.no_of_duts = no_of_duts;
endfunction


//-------------------------------build_phase() method--------------------------------------
function void router_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Create object for env config class
	e_cfg = env_config::type_id::create("e_cfg");
	
	//Check whether env_cfg contains src &dst_agt_cfgs and create objects for those classes
	if(has_sagt)
		e_cfg.src_agt_cfg = new[no_of_wagts];

	if(has_dagt)
		e_cfg.dst_agt_cfg = new[no_of_ragts];

	config_router(); // Call config_router() method to get the virtual interfaces for respective agent cfgs

	uvm_config_db#(env_config)::set(this,"*","env_config",e_cfg); //Setting env_cfg into uvm_config_db

	env = router_tb::type_id::create("env",this);

endfunction
		

//-------------------------------end_of_elaboration_phase()--------------------------------------
function void router_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
	uvm_top.print_topology();
endfunction



//------------------------------------Small packet test------------------------------------------------
class small_packet_test extends router_test;
	`uvm_component_utils(small_packet_test) //Factory Registration
	bit [1:0] addr;
	//small_vseq seq1;
	small_packet seq1;
	normal_sequence seq1h;

	//Methods
	extern function new(string name = "small_packet_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass


//--------------------------------Constructor "new"----------------------------------------
function small_packet_test::new(string name = "small_packet_test", uvm_component parent);
	super.new(name, parent);
endfunction


//--------------------------------Build Phase()--------------------------------------------
function void small_packet_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction


//--------------------------------Run Phase()--------------------------------------------
task small_packet_test::run_phase(uvm_phase phase);
	
	phase.raise_objection(this);
	repeat(10) begin
		//Create object for seq1 using "create" method
		seq1 = small_packet::type_id::create("seq1");
		//seq1 = small_vseq::type_id::create("seq1");
		seq1h = normal_sequence::type_id::create("seq1h");
		addr = $urandom_range(0,2); // Address value can be anything between 0,1,2
		uvm_config_db#(bit [1:0])::set(this, "*", "addr", addr); //Set the address value into uvm_config_db so that we can retrieve in the sequence class

		phase.raise_objection(this);
		fork
			seq1.start(env.sagt_top.src_agnth[0].s_seqrh);
			//seq1.start(env.vseqr);
			seq1h.start(env.dagt_top.dst_agnth[addr].d_seqrh);
		join
		phase.drop_objection(this);
	end
	phase.drop_objection(this);
endtask


//------------------------------------Medium packet test------------------------------------------------
class medium_packet_test extends router_test;
	`uvm_component_utils(medium_packet_test) //Factory Registration
	bit [1:0] addr;
	medium_packet seq2;
	normal_sequence seq2h;

	//Methods
	extern function new(string name = "medium_packet_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass


//--------------------------------Constructor "new"----------------------------------------
function medium_packet_test::new(string name = "medium_packet_test", uvm_component parent);
	super.new(name, parent);
endfunction


//--------------------------------Build Phase()--------------------------------------------
function void medium_packet_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction


//--------------------------------Run Phase()--------------------------------------------
task medium_packet_test::run_phase(uvm_phase phase);
	
	phase.raise_objection(this);
	repeat(10) begin
		//Create object for seq2 using "create" method
		seq2 = medium_packet::type_id::create("seq2");
		seq2h = normal_sequence::type_id::create("seq2h");	
		addr = $urandom_range(0,2); // Address value can be anything between 0,1,2
		uvm_config_db#(bit [1:0])::set(this, "*", "addr", addr); //Set the address value into uvm_config_db so that we can retrieve in the sequence class

		phase.raise_objection(this);
		fork
			seq2.start(env.sagt_top.src_agnth[0].s_seqrh);
			seq2h.start(env.dagt_top.dst_agnth[addr].d_seqrh);
		join
		phase.drop_objection(this);
	end
	phase.drop_objection(this);
endtask


//------------------------------------Large packet test------------------------------------------------
class large_packet_test extends router_test;
	`uvm_component_utils(large_packet_test) //Factory Registration
	bit [1:0] addr;
	large_packet seq3;
	normal_sequence seq3h;

	//Methods
	extern function new(string name = "large_packet_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass


//--------------------------------Constructor "new"----------------------------------------
function large_packet_test::new(string name = "large_packet_test", uvm_component parent);
	super.new(name, parent);
endfunction


//--------------------------------Build Phase()--------------------------------------------
function void large_packet_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction


//--------------------------------Run Phase()--------------------------------------------
task large_packet_test::run_phase(uvm_phase phase);

	phase.raise_objection(this);
	repeat(10) begin
		//Create object for seq3 using "create" method
		seq3 = large_packet::type_id::create("seq3");
		seq3h = normal_sequence::type_id::create("seq3h");
		addr = $urandom_range(0,2); // Address value can be anything between 0,1,2
		uvm_config_db#(bit [1:0])::set(this, "*", "addr", addr); //Set the address value into uvm_config_db so that we can retrieve in the sequence class
	
		phase.raise_objection(this);
		fork
			seq3.start(env.sagt_top.src_agnth[0].s_seqrh);
			seq3h.start(env.dagt_top.dst_agnth[addr].d_seqrh);
		join
		phase.drop_objection(this);
	end
	phase.drop_objection(this);
endtask

//------------------------------------Error packet test------------------------------------------------
class error_packet_test extends router_test;
	`uvm_component_utils(error_packet_test) //Factory Registration
	bit [1:0] addr;
	error_packet seq4;
	normal_sequence seq4h;

	//Methods
	extern function new(string name = "error_packet_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass


//--------------------------------Constructor "new"----------------------------------------
function error_packet_test::new(string name = "error_packet_test", uvm_component parent);
	super.new(name, parent);
endfunction


//--------------------------------Build Phase()--------------------------------------------
function void error_packet_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction


//--------------------------------Run Phase()--------------------------------------------
task error_packet_test::run_phase(uvm_phase phase);

	phase.raise_objection(this);
	repeat(10) begin
		//Create object for seq3 using "create" method
		seq4 = error_packet::type_id::create("seq4");
		seq4h = normal_sequence::type_id::create("seq4h");
		addr = $urandom_range(0,2); // Address value can be anything between 0,1,2
		uvm_config_db#(bit [1:0])::set(this, "*", "addr", addr); //Set the address value into uvm_config_db so that we can retrieve in the sequence class
	
		phase.raise_objection(this);
		fork
			seq4.start(env.sagt_top.src_agnth[0].s_seqrh);
			seq4h.start(env.dagt_top.dst_agnth[addr].d_seqrh);
		join
		phase.drop_objection(this);
	end
	phase.drop_objection(this);
endtask

