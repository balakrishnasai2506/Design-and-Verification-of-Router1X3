class virtual_seqs extends uvm_sequence #(uvm_sequence_item);
	`uvm_object_utils(virtual_seqs) //Factory Registration

	//Declare handles for source_sequences
	small_packet small_xtns;
	medium_packet medium_xtns;
	large_packet large_xtns;

	//Declare handles for dest_sequences
	normal_sequence normal_xtns;
	delay_sequence delay_xtns;

	//Declare handles for source and dest sequencers
	source_sequencer src_seqr[];
	dest_sequencer dst_seqr[];
	
	//Declare handle for environment config
	env_config e_cfg;

	//Declare a handle for virtual sequencer
	virtual_sequencer v_seqr;

	//Methods
	extern function new(string name = "virtual_seqs");
	extern task body();
endclass


//-----------------------Constructor "new"------------------------------
function virtual_seqs::new(string name = "virtual_seqs");
	super.new(name);
endfunction


//-----------------------Body()------------------------------
task virtual_seqs::body();
	//Get the env_cfg from uvm_config_db
	if(!uvm_config_db#(env_config)::get(null,get_full_name(),"env_config", e_cfg))
		`uvm_fatal("VIRTUAL_SEQUENCE", "Couldn't get env_config from uvm_config_db.... Did you set it right???")

	//Allot memories to src and dst seqrs 
	src_seqr = new[e_cfg.no_of_src_agt];
	dst_seqr = new[e_cfg.no_of_dst_agt];

	//Persorm $cast for v_seqr and m_seqr
	assert($cast(v_seqr,m_sequencer)) else begin
		`uvm_error("BODY", "Error in $cast of virtual sequencer")
	end

	//Assign src and dst_seqrs to v_seqr's src and dst_seqrs
	foreach(src_seqr[i])
		src_seqr[i] = v_seqr.src_seqr[i];


	foreach(dst_seqr[i])
		dst_seqr[i] = v_seqr.dst_seqr[i];
endtask



//-------------------------------------------------------------------------------------
//-------------------------------Small Packet V_Seqs-----------------------------------
//-------------------------------------------------------------------------------------
class small_vseq extends virtual_seqs;
	`uvm_object_utils(small_vseq) //Factory Registration
	
	bit [1:0] addr;

	//Methods
	extern function new(string name = "small_vseq");
	extern task body();
endclass


//--------------------------Constructor "new"--------------------------------------
function small_vseq::new(string name = "small_vseq");
	super.new(name);
endfunction


//--------------------------Body()--------------------------------------
task small_vseq::body();
	super.body();
	//Create objects for for both src and dst sequences
	small_xtns = small_packet::type_id::create("small_xtns");
	normal_xtns = normal_sequence::type_id::create("normal_xtns");

	//Get the addr from uvm_config_db to know the destination the sequence needs to be deriven
	if(!uvm_config_db #(bit[1:0])::get(m_sequencer,"*", "addr", addr))
		`uvm_fatal("SMALL_VSEQ","CANNOT GET ADDR FROM UVM_CONFIG_DB.... DID YOU SET IT RIGHT???")

	fork
		small_xtns.start(src_seqr[0]);
		normal_xtns.start(dst_seqr[addr]);
	join
endtask


//-------------------------------------------------------------------------------------
//-------------------------------Medium Packet V_Seqs-----------------------------------
//-------------------------------------------------------------------------------------
class medium_vseq extends virtual_seqs;
	`uvm_object_utils(medium_vseq) //Factory Registration
	
	bit [1:0] addr;

	//Methods
	extern function new(string name = "medium_vseq");
	extern task body();
endclass


//--------------------------Constructor "new"--------------------------------------
function medium_vseq::new(string name = "medium_vseq");
	super.new(name);
endfunction


//--------------------------Body()--------------------------------------
task medium_vseq::body();
	super.body();
	//Create objects for for both src and dst sequences
	medium_xtns = medium_packet::type_id::create("medium_xtns");
	normal_xtns = normal_sequence::type_id::create("normal_xtns");

	//Get the addr from uvm_config_db to know the destination the sequence needs to be deriven
	if(!uvm_config_db #(bit[1:0])::get(m_sequencer,"*", "addr", addr))
		`uvm_fatal("MEDIUM_VSEQ","CANNOT GET ADDR FROM UVM_CONFIG_DB.... DID YOU SET IT RIGHT???")

	fork
		medium_xtns.start(src_seqr[0]);
		normal_xtns.start(dst_seqr[addr]);
	join
endtask


//-------------------------------------------------------------------------------------
//-------------------------------Large Packet V_Seqs-----------------------------------
//-------------------------------------------------------------------------------------
class large_vseq extends virtual_seqs;
	`uvm_object_utils(large_vseq) //Factory Registration
	
	bit [1:0] addr;

	//Methods
	extern function new(string name = "large_vseq");
	extern task body();
endclass


//--------------------------Constructor "new"--------------------------------------
function large_vseq::new(string name = "large_vseq");
	super.new(name);
endfunction


//--------------------------Body()--------------------------------------
task large_vseq::body();
	super.body();
	//Create objects for for both src and dst sequences
	large_xtns = large_packet::type_id::create("large_xtns");
	normal_xtns = normal_sequence::type_id::create("normal_xtns");

	//Get the addr from uvm_config_db to know the destination the sequence needs to be deriven
	if(!uvm_config_db #(bit[1:0])::get(m_sequencer,"*", "addr", addr))
		`uvm_fatal("LARGE_VSEQ","CANNOT GET ADDR FROM UVM_CONFIG_DB.... DID YOU SET IT RIGHT???")

	fork
		large_xtns.start(src_seqr[0]);
		normal_xtns.start(dst_seqr[addr]);
	join
endtask
