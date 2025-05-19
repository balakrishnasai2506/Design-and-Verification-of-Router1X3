class source_xtn extends uvm_sequence_item;
	`uvm_object_utils(source_xtn) //Factory Registration

	//Data Members
	bit resetn, error, busy, pkt_valid;
	rand bit [7:0] header, payload[];
	bit [7:0] parity;

	//Constraints
	constraint valid_addr{header [1:0] != 3;}
	constraint valid_data{header [7:2] != 0;}
	constraint valid_depth{payload.size == header [7:2];}

	//Methods
	extern function new(string name = "source_xtn");
	extern function void do_print(uvm_printer printer);
	extern function void post_randomize();
endclass


//----------------------Constructor "new"---------------------------
function source_xtn::new(string name = "source_xtn");
	super.new(name);
endfunction


//----------------------do_print()---------------------------
function void source_xtn::do_print(uvm_printer printer);
	super.do_print(printer);
	
	//Print the variables
			//  "string"		"bitstream_value"	"size"		"radix for printing"
	printer.print_field("header",		this.header,		8,		UVM_HEX);
	foreach(payload[i]) 
	printer.print_field($sformatf("payload[%0d]",i),		this.payload[i],		8,		UVM_HEX);
	
	printer.print_field("parity",		parity,		8,		UVM_HEX);
	printer.print_field("error",		this.error,		1,		UVM_BIN);
endfunction


//----------------------post_randomize()---------------------------
function void source_xtn::post_randomize();
	parity = 0 ^ header;
	
	foreach(payload[i])
		parity = payload[i] ^ parity;
endfunction
