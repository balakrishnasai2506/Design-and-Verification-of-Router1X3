interface router_if(input bit clock);
	logic [7:0] data_in, data_out;
	logic resetn,pkt_valid, valid_out, error, busy, read_enb;

	//Source Driver Clocking Block
	clocking drv_cb@(posedge clock);
		default input #1 output #1;
		output data_in, resetn, pkt_valid;
		input busy, error;
	endclocking

	//Source Monitor Clocking Block
	clocking mon_cb@(posedge clock);
		default input #1 output #1;
		input data_in, resetn, pkt_valid, busy,error;
	endclocking

	//Destination Driver Clocking Block
	clocking ddrv_cb@(posedge clock);
		default input #1 output #1;
		output read_enb;
		input valid_out;
	endclocking

	//Destination Monitor Clocking Block
	clocking dmon_cb@(posedge clock);
		default input #1 output #1;
		input read_enb, valid_out, data_out;
	endclocking

	//MODPORTS
	modport DRV_MP(clocking drv_cb);
	modport MON_MP(clocking mon_cb);
	modport DDRV_MP(clocking ddrv_cb);
	modport DMON_MP(clocking dmon_cb);

endinterface

