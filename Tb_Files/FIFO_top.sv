module FIFO_top;
	bit clk;

	//clock generation
	initial begin
    	forever #1 clk = ~clk;
  	end

  	FIFO_if F_if (clk);

  	FIFO FIFO_DUT (F_if);
  	FIFO_tb FIFO_TEST (F_if);
  	FIFO_monitor FIFO_MON (F_if);

endmodule