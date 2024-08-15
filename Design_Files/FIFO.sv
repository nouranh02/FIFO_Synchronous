////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////Original Code/////////////////////////////////////////////////////////////

/*
module FIFO(data_in, wr_en, rd_en, clk, rst_n, full, empty, almostfull, almostempty, wr_ack, overflow, underflow, data_out);
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
input [FIFO_WIDTH-1:0] data_in;
input clk, rst_n, wr_en, rd_en;
output reg [FIFO_WIDTH-1:0] data_out;
output reg wr_ack, overflow;
output full, empty, almostfull, almostempty, underflow;
 
localparam max_fifo_addr = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		wr_ptr <= 0;
	end
	else if (wr_en && count < FIFO_DEPTH) begin
		mem[wr_ptr] <= data_in;
		wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end
	else begin 
		wr_ack <= 0; 
		if (full & wr_en)
			overflow <= 1;
		else
			overflow <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rd_ptr <= 0;
	end
	else if (rd_en && count != 0) begin
		data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({wr_en, rd_en} == 2'b10) && !full) 
			count <= count + 1;
		else if ( ({wr_en, rd_en} == 2'b01) && !empty)
			count <= count - 1;
	end
end

assign full = (count == FIFO_DEPTH)? 1 : 0;
assign empty = (count == 0)? 1 : 0;
assign underflow = (empty && rd_en)? 1 : 0; 
assign almostfull = (count == FIFO_DEPTH-2)? 1 : 0; 
assign almostempty = (count == 1)? 1 : 0;

endmodule
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////Edited Code/////////////////////////////////////////////////////////////

module FIFO(FIFO_if.DUT fd);

localparam max_fifo_addr = $clog2(fd.FIFO_DEPTH);

logic [fd.FIFO_WIDTH-1:0] mem [fd.FIFO_DEPTH-1:0];

bit [max_fifo_addr-1:0] wr_ptr, rd_ptr;
bit [max_fifo_addr:0] count;

always @(posedge fd.clk or negedge fd.rst_n) begin
	if (!fd.rst_n) begin
		wr_ptr <= 0;
		fd.overflow <= 0;
		fd.wr_ack <= 0;
	end
	else begin
		//wr_en high and FIFO not full - or - wr_en and rd_en are high (read and write in parallel)
		if ( (fd.wr_en && (count < (fd.FIFO_DEPTH)) ) || (fd.wr_en && fd.rd_en /*&& (count == (fd.FIFO_DEPTH))*/) ) begin
			mem[wr_ptr] <= fd.data_in;
			fd.wr_ack <= 1;
			wr_ptr <= wr_ptr + 1;
			fd.overflow <= 0;
		end
		else begin 
			fd.wr_ack <= 0;
			//else branch: FIFO is full or wr_en inactive
			if (/*fd.full & */fd.wr_en)
				fd.overflow <= 1;
			else
				fd.overflow <= 0;
		end

		if (!fd.rd_en) fd.data_out <= 0;
	end
end

always @(posedge fd.clk or negedge fd.rst_n) begin
	if (!fd.rst_n) begin
		rd_ptr <= 0;
		fd.underflow <= 0;
		fd.data_out <= 0;
	end
	//rd_en high and FIFO not empty - or - rd_en and wr_en are high (read and write in parallel)
	else if (fd.rd_en && count != 0  || (fd.wr_en && fd.rd_en/* && (count == 0)*/) ) begin
		//if FIFO is empty: wr_en and rd_en are active (read and write in parallel)
		if((fd.wr_en /*&& fd.rd_en*/ && (count == 0))) fd.data_out <= fd.data_in;
		else fd.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		fd.underflow <= 0;
	end
	else begin
		if(fd.empty && fd.rd_en)
			fd.underflow <= 1;
		else
			fd.underflow <= 0;

		fd.data_out <= 0;
	end
end

always @(posedge fd.clk or negedge fd.rst_n) begin
	if (!fd.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({fd.wr_en, fd.rd_en} == 2'b10) && !fd.full) 
			count <= count + 1;
		if ( ({fd.wr_en, fd.rd_en} == 2'b01) && !fd.empty)
			count <= count - 1;
	end
end

assign fd.full = (count == fd.FIFO_DEPTH)? 1 : 0;
assign fd.empty = (count == 0)? 1 : 0;
assign fd.almostfull = (count == fd.FIFO_DEPTH-1)? 1 : 0; 
assign fd.almostempty = (count == 1)? 1 : 0;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


`ifdef SIM

	/*Assertions Plan:
	Check position and pointers in all cases (to ensure a correct state of fifo)
		- Reset Signal (relevant Outputs (~full, empty))

		- Write Enabled (check if data is written in FIFO, wr_ack)
		- Write Enabled when FIFO is full (overflow, ~wr_ack, non-destructive to FIFO)
		- Write Disabled (~wr_ack, no write operation is done in FIFO)

		- Read Enabled (check output data if it's the one written in FIFO)
		- Read Enabled when FIFO is empty (underflow, no output data, non-destructive to FIFO)
		- Read Disabled (no output data)

		- Check almostfull then full
		- Check almostempty then empty
	*/


	//Checks rst_n Functionality
	property reset_asserted;
		@(posedge fd.clk)

		!fd.rst_n |=> ~(fd.data_out) && ~(wr_ptr || rd_ptr || count) && fd.empty && ~fd.full && ~(fd.overflow || fd.underflow);
	endproperty


	//Checks wr_en Functionality
	property wr_enabled;
		bit [max_fifo_addr-1:0] wr_ptr_exp = 0;
		@(posedge fd.clk) disable iff(!fd.rst_n || (count == 8) || fd.rd_en)

		((fd.wr_en), wr_ptr_exp = wr_ptr + 1) |=> fd.wr_ack && (mem[$past(wr_ptr)] == $past(fd.data_in)) && (wr_ptr == wr_ptr_exp) && (count == ($past(count) + 1));
	endproperty

	property wr_enabled_full;
		@(posedge fd.clk) disable iff(!fd.rst_n || fd.rd_en)

		(fd.wr_en) && (fd.full) |=> (fd.overflow) && ~(fd.wr_ack) && $stable(mem) && $stable(wr_ptr) && $stable(count);
	endproperty

	property wr_disabled;
		@(posedge fd.clk) disable iff(!fd.rst_n)

		!(fd.wr_en) |=> ~(fd.wr_ack) && $stable(mem);
	endproperty


	//Checks rd_en Functionality
	property rd_enabled;
		bit [max_fifo_addr-1:0] rd_ptr_exp = 0;
		@(posedge fd.clk) disable iff(!fd.rst_n || (count == 0) || fd.wr_en)

		((fd.rd_en), rd_ptr_exp = rd_ptr + 1) |=> (fd.data_out == mem[$past(rd_ptr)]) && (rd_ptr == rd_ptr_exp);
	endproperty

	property rd_enabled_empty;
		@(posedge fd.clk) disable iff(!fd.rst_n || fd.wr_en)

		(fd.rd_en) && (fd.empty) |=> (fd.underflow) && ~(fd.data_out) && $stable(mem) && $stable(rd_ptr);
	endproperty

	property rd_disabled;
		@(posedge fd.clk) disable iff(!fd.rst_n)

		~(fd.rd_en) |=> ~(fd.data_out) && $stable(rd_ptr);
	endproperty


	//Checking Outputs Values
	property FIFO_almostfull;
		@(posedge fd.clk) disable iff(!fd.rst_n)

		(count == (fd.FIFO_DEPTH - 1)) |-> (fd.almostfull);
	endproperty
	
	property FIFO_full;
		@(posedge fd.clk) disable iff(!fd.rst_n)

		(count >= fd.FIFO_DEPTH) |-> (fd.full);
	endproperty

	property FIFO_almostempty;
		@(posedge fd.clk) disable iff(!fd.rst_n)

		(count == 1) |-> (fd.almostempty);
	endproperty
	
	property FIFO_empty;
		@(posedge fd.clk) disable iff(!fd.rst_n)

		(count == 0) |-> (fd.empty);
	endproperty


	assertion_reset_asserted:		assert property(reset_asserted);
	cover_reset_asserted:	  		cover property(reset_asserted);

	assertion_wr_enabled:			assert property(wr_enabled);
	cover_wr_enabled:	  			cover property(wr_enabled);

	assertion_wr_enabled_full:		assert property(wr_enabled_full);
	cover_wr_enabled_full:	  		cover property(wr_enabled_full);

	assertion_wr_disabled:			assert property(wr_disabled);
	cover_wr_disabled:	  			cover property(wr_disabled);

	assertion_rd_enabled:			assert property(rd_enabled);
	cover_rd_enabled:	  			cover property(rd_enabled);

	assertion_rd_enabled_empty:		assert property(rd_enabled_empty);
	cover_rd_enabled_empty:	  		cover property(rd_enabled_empty);

	assertion_rd_disabled:			assert property(rd_disabled);
	cover_rd_disabled:	  			cover property(rd_disabled);

	assertion_FIFO_almostfull:		assert property(FIFO_almostfull);
	cover_FIFO_almostfull:	  		cover property(FIFO_almostfull);

	assertion_FIFO_full:			assert property(FIFO_full);
	cover_FIFO_full:	  			cover property(FIFO_full);

	assertion_FIFO_almostempty:		assert property(FIFO_almostempty);
	cover_FIFO_almostempty:	  		cover property(FIFO_almostempty);

	assertion_FIFO_empty:			assert property(FIFO_empty);
	cover_FIFO_empty:	  			cover property(FIFO_empty);

`endif

endmodule