class source_seqs extends uvm_sequence#(source_xtn);
	`uvm_object_utils(source_seqs) //Factory Registration

	//Methods
	extern function new(string name = "source_seqs");
endclass


//--------------------------Constructor "new"-----------------------------
function source_seqs::new(string name = "source_seqs");
	super.new(name);
endfunction


//------------------------------------------------------------------------------------------------------------------

//----------------------------Small Packet------------------------------
class small_packet extends source_seqs;
	`uvm_object_utils(small_packet)
	bit [1:0] addr; //helps in getting  the destination address from test
	
	//Methods
	extern function new(string name = "small_packet");
	extern task body();
endclass


//---------------------Constructor "new"--------------------------
function small_packet::new(string name = "small_packet");
	super.new(name);
endfunction


//----------------------Body()-----------------------------------
task small_packet::body();
//	repeat(5) begin
		req = source_xtn::type_id::create("req"); //Create an object for transaction class
		//Get the addr from uvm_config_db
		if(!uvm_config_db#(bit[1:0])::get(null, get_full_name(), "addr", addr))
			`uvm_fatal("SMALL_PACKET","Couldn't get the addr from uvm_config_db... Did u set it right???")
		start_item(req);
		assert(req.randomize() with 	{
					header [1:0] == addr;
				        header [7:2] inside {[1:20]};
						});
		`uvm_info("SMALL_PACKET_SEQUENCE",$sformatf("printing from sequence \n %s", req.sprint()),UVM_HIGH)
		finish_item(req);
//	end
endtask

//------------------------------------------------------------------------------------------------------------------


//----------------------------Medium Packet------------------------------
class medium_packet extends source_seqs;
	`uvm_object_utils(medium_packet)
	bit [1:0] addr; //helps in getting  the destination address from test
	
	//Methods
	extern function new(string name = "medium_packet");
	extern task body();
endclass


//---------------------Constructor "new"--------------------------
function medium_packet::new(string name = "medium_packet");
	super.new(name);
endfunction


//----------------------Body()-----------------------------------
task medium_packet::body();
//	repeat(5) begin
		req = source_xtn::type_id::create("req"); //Create an object for transaction class
		//Get the addr from uvm_config_db
		if(!uvm_config_db#(bit[1:0])::get(null, get_full_name(), "addr", addr))
			`uvm_fatal("MEDIUM_PACKET","Couldn't get the addr from uvm_config_db... Did u set it right???")
		start_item(req);
		assert(req.randomize() with 	{
					header [1:0] == addr;
					header [7:2] inside {[21:40]};
						});
		`uvm_info("MEDIUM_PACKET_SEQUENCE",$sformatf("printing from sequence \n %s", req.sprint()),UVM_HIGH)
		finish_item(req);
//	end
endtask



//------------------------------------------------------------------------------------------------------------------

//----------------------------Large Packet------------------------------
class large_packet extends source_seqs;
	`uvm_object_utils(large_packet)
	bit [1:0] addr; //helps in getting  the destination address from test
	
	//Methods
	extern function new(string name = "large_packet");
	extern task body();
endclass


//---------------------Constructor "new"--------------------------
function large_packet::new(string name = "large_packet");
	super.new(name);
endfunction


//----------------------Body()-----------------------------------
task large_packet::body();
//	repeat(5) begin
		req = source_xtn::type_id::create("req"); //Create an object for transaction class
		//Get the addr from uvm_config_db
		if(!uvm_config_db#(bit[1:0])::get(null, get_full_name(), "addr", addr))
			`uvm_fatal("LARGE_PACKET","Couldn't get the addr from uvm_config_db... Did u set it right???")
		start_item(req);
		assert(req.randomize() with 	{
					header [1:0] == addr; 
					header [7:2] inside {[41:63]};
						});
		`uvm_info("LARGE_PACKET_SEQUENCE",$sformatf("printing from sequence \n %s", req.sprint()),UVM_HIGH)
		finish_item(req);
//	end
endtask

//----------------------------Error Packet------------------------------
class error_packet extends source_seqs;
        `uvm_object_utils(error_packet)
        bit [1:0] addr; //helps in getting  the destination address from test

        //Methods
        extern function new(string name = "error_packet");
        extern task body();
endclass


//---------------------Constructor "new"--------------------------
function error_packet::new(string name = "error_packet");
        super.new(name);
endfunction


//----------------------Body()-----------------------------------
task error_packet::body();
                req = source_xtn::type_id::create("req"); //Create an object for transaction class
                //Get the addr from uvm_config_db
                if(!uvm_config_db#(bit[1:0])::get(null, get_full_name(), "addr", addr))
                        `uvm_fatal("ERROR_PACKET","Couldn't get the addr from uvm_config_db... Did u set it right???")
                start_item(req);
                assert(req.randomize() with     {
                                        header [1:0] == addr;
                                        header [7:2] dist {[1:20] := 1, [21:40] := 1, [41:63] := 1};
					payload[0] == header ^ (1 << $urandom_range(0,7)) ^ (^header);
                                                });
                `uvm_info("ERROR_PACKET_SEQUENCE",$sformatf("printing from sequence \n %s", req.sprint()),UVM_HIGH)
                finish_item(req);
endtask

