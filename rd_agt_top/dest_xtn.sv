class dest_xtn extends uvm_sequence_item;
	`uvm_object_utils(dest_xtn) //Factory Registration

	bit [7:0] header, parity;
	bit [7:0] payload[];
	rand bit [5:0] delay;

	constraint valid_rd_enb {delay inside {[1:30]};}

	//Methods
	extern function new(string name = "dest_xtn");
	extern function void do_print(uvm_printer printer);
endclass


//--------------------------Constructor "new"---------------------------
function dest_xtn::new(string name = "dest_xtn");
	super.new(name);
endfunction


//--------------------------Do Print()---------------------------
function void dest_xtn::do_print(uvm_printer printer);
	super.do_print(printer);
	
	//Print the variables
			//  "string"		"bitstream_value"	"size"		"radix for printing"
	printer.print_field("header",		this.header,		8,		UVM_HEX);
	foreach(payload[i]) 
	printer.print_field($sformatf("payload[%0d]",i),		this.payload[i],		8,		UVM_HEX);
	
	printer.print_field("parity",		parity,		8,		UVM_HEX);
endfunction
