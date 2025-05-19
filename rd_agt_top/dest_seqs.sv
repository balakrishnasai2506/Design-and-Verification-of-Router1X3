class dest_seqs extends uvm_sequence #(dest_xtn);
	`uvm_object_utils(dest_seqs) //Factory Registration

	//Methods
	extern function new(string name = "dest_seqs");
endclass


//--------------------------Constructor "new"---------------------------
function dest_seqs::new(string name = "dest_seqs");
	super.new(name);
endfunction



//--------------------------Normal Sequence---------------------------
class normal_sequence extends dest_seqs;
	`uvm_object_utils(normal_sequence) //Factory Registration

	//Methods
	extern function new(string name = "normal_sequence");
	extern task body();
endclass


//--------------------------Constructor "new"---------------------------
function normal_sequence::new(string name = "normal_sequence");
	super.new(name);
endfunction


//------------------------------Body()---------------------------------
task normal_sequence::body();
//	repeat(5) begin
		req = dest_xtn::type_id::create("req"); //Create an object for txn class

		start_item(req);
		assert(req.randomize() with {delay < 5'd30 ;});
		finish_item(req);
//	end
endtask


//--------------------------Delay Sequence---------------------------
class delay_sequence extends dest_seqs;
	`uvm_object_utils(delay_sequence) //Factory Registration

	//Methods
	extern function new(string name = "delay_sequence");
	extern task body();
endclass


//--------------------------Constructor "new"---------------------------
function delay_sequence::new(string name = "delay_sequence");
	super.new(name);
endfunction


//------------------------------Body()---------------------------------
task delay_sequence::body();
//	repeat(5) begin
		req = dest_xtn::type_id::create("req"); //Create an object for txn class

		start_item(req);
		assert(req.randomize() with {delay > 5'd30 ;});
		finish_item(req);
//	end
endtask
