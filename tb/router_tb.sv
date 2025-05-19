class router_tb extends uvm_env;
	`uvm_component_utils(router_tb) //Factory Registration

	//Declare low level TB Component handles such as agt tops
	source_agent_top sagt_top;
	dest_agent_top dagt_top;

	//Declare handle for env_cfg
	env_config e_cfg;
	
	//Declare handle for virtual sequencer
	virtual_sequencer vseqr;

	//Declare dynamic handle for scoreboard
	router_scoreboard sb[];

	//Standard UVM Methods
	extern function new(string name = "router_tb", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass


//-----------------------------Constructor "new"--------------------------------
function router_tb::new(string name = "router_tb", uvm_component parent);
	super.new(name,parent);
endfunction


//-----------------------------Build Phase--------------------------------
function void router_tb::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(env_config)::get(this,"*","env_config",e_cfg))
		`uvm_fatal("ROUTER_TB","Could not get env_config from uvm_config_db... did u set it?")

	//Create objects for both source and destination agt tops
	begin
		sagt_top = source_agent_top::type_id::create("sagt_top",this);
	end

	begin
		dagt_top = dest_agent_top::type_id::create("dagt_top",this);
	end

	//Create object for virtual sequencer
	if(e_cfg.has_virtual_sequencer)
		vseqr = virtual_sequencer::type_id::create("vseqr",this);

	if(e_cfg.has_scoreboard) begin
		sb = new[e_cfg.no_of_duts];
	
		foreach(sb[i])
			sb[i] = router_scoreboard::type_id::create($sformatf("sb[%0d]",i), this);
	end
endfunction


//--------------------------Connect Phase()-----------------------------
function void router_tb::connect_phase(uvm_phase phase);
	//Connect the sub sequencers in virtual sequencer to the physical src and dst sequencers
	if(e_cfg.has_virtual_sequencer) begin
		begin
			for(int i = 0; i< e_cfg.no_of_src_agt; i++)
				vseqr.src_seqr[i] = sagt_top.src_agnth[i].s_seqrh;
		end

		begin
			for(int i = 0; i< e_cfg.no_of_dst_agt; i++)
				vseqr.dst_seqr[i] = dagt_top.dst_agnth[i].d_seqrh;
		end
	end

	//Connect scoreboard to monitor here...
	if(e_cfg.has_scoreboard) begin
		//Source
		sagt_top.src_agnth[0].s_monh.ap.connect(sb[0].fifo_src.analysis_export);

		//Destination
		dagt_top.dst_agnth[0].d_monh.ap.connect(sb[0].fifo_dst[0].analysis_export);
		dagt_top.dst_agnth[1].d_monh.ap.connect(sb[0].fifo_dst[1].analysis_export);
		dagt_top.dst_agnth[2].d_monh.ap.connect(sb[0].fifo_dst[2].analysis_export);
	end
	
endfunction
