module FIFO_tb(FIFO_if.TEST ft);

import transaction_pkg::*;
import shared_pkg::*;

	parameter TESTS = 10000;

	FIFO_transaction f_txn = new();

	initial begin

		//Assert Reset - Initial State
		assert_reset;



		/*TEST 0: 	- Checks (rst_n) Functionality
					- Randomization (of all inputs) is done Under No Constraints
		*/
		stimulus_gen_reset;



		//Deassert Reset
		deassert_reset;




		/*TEST 1:	- Checks when wr_en is high and rd_en is low
					- Write Operations are done until the FIFO is full
		*/
		stimulus_gen1;


		

		/*TEST 2:	- Checks when rd_en is high and wr_en is low
					- Read Operations are done until the FIFO is empty
		*/
		stimulus_gen2;




		/*TEST 3:	- Checks when both wr_en and rd_en are high
					- Write and Read Operations are done in parallel
					- Write Operations stop when FIFO is full
					- Read Operations stop when FIFO is empty
		*/
		stimulus_gen3;




		/*TEST 4:	- Checks whole operation when all inputs are randomized
		*/
		stimulus_gen4;

		

		test_finished = 1;
	end


	task assert_reset;
		ft.rst_n = 0;
		f_txn.constraint_mode(0);
		@(negedge ft.clk);
	endtask

	task stimulus_gen_reset;
		for(int i=0; i<TESTS; i++) begin
			assert(f_txn.randomize());
			ft.wr_en 	= f_txn.wr_en;
			ft.rd_en 	= f_txn.rd_en;
			ft.data_in	= f_txn.data_in;

			@(negedge ft.clk);
		end
	endtask

	task deassert_reset;
		ft.rst_n = 1;
		f_txn.constraint_mode(1);
		@(negedge ft.clk);
	endtask




	task stimulus_gen1;
		ft.wr_en = 1; ft.rd_en = 0;
		for(int i=0; i<TESTS/4; i++) begin
			assert(f_txn.randomize());
			ft.rst_n 	= f_txn.rst_n;
			ft.data_in 	= f_txn.data_in;
			@(negedge ft.clk);
		end
	endtask


	task stimulus_gen2;
		ft.wr_en = 0; ft.rd_en = 1;
		for(int i=0; i<TESTS/4; i++) begin
			assert(f_txn.randomize());
			ft.rst_n 	= f_txn.rst_n;
			ft.data_in 	= f_txn.data_in;
			@(negedge ft.clk);
		end
	endtask


	task stimulus_gen3;
		ft.wr_en = 1; ft.rd_en = 1;
		for(int i=0; i<TESTS/4; i++) begin
			assert(f_txn.randomize());
			ft.rst_n 	= f_txn.rst_n;
			ft.data_in 	= f_txn.data_in;
			@(negedge ft.clk);
		end
	endtask


	task stimulus_gen4;
		for(int i=0; i<TESTS; i++) begin
			assert(f_txn.randomize());
			ft.rst_n 	= f_txn.rst_n;
			ft.wr_en	= f_txn.wr_en;
			ft.rd_en	= f_txn.rd_en;
			ft.data_in 	= f_txn.data_in;
			@(negedge ft.clk);
		end
	endtask

endmodule