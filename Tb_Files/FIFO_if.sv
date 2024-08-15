interface FIFO_if (clk);
	parameter FIFO_WIDTH = 16;
	parameter FIFO_DEPTH = 8;

	input bit clk;
	logic [FIFO_WIDTH-1:0] data_in, data_out;
	bit rst_n, wr_en, rd_en, wr_ack, overflow;
	bit full, empty, almostfull, almostempty, underflow;

	modport TEST (output rst_n, wr_en, rd_en, data_in,
					input clk, data_out, full, almostfull, empty, almostempty, overflow, underflow, wr_ack);

	modport DUT (output data_out, full, almostfull, empty, almostempty, overflow, underflow, wr_ack,
					input clk, rst_n, wr_en, rd_en, data_in);

	modport MON (input clk, rst_n, wr_en, rd_en, data_in, data_out, full, almostfull, empty, almostempty, overflow, underflow, wr_ack);
endinterface