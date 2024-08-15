import transaction_pkg::*;
import coverage_pkg::*;
import scoreboard_pkg::*;
import shared_pkg::*;


module FIFO_monitor(FIFO_if.MON fm);
	FIFO_transaction f_txn   = new();
	FIFO_coverage 	 f_cov   = new();
	FIFO_scoreboard  f_score = new();

	FIFO_transaction f_tcov  = new();

	initial begin
		forever begin
			fork
				//Transaction for Checker
				begin
					@(edge fm.clk);
					//Inputs to DUT
					f_txn.rst_n = fm.rst_n;
					f_txn.wr_en = fm.wr_en;
					f_txn.rd_en = fm.rd_en;
					f_txn.data_in = fm.data_in;

					//Combinational Outputs of DUT
					if(!fm.rst_n) begin
						f_txn.wr_ack = fm.wr_ack;	
						f_txn.overflow = fm.overflow;
						f_txn.underflow = fm.underflow;
						f_txn.data_out = fm.data_out;
					end
					f_txn.full = fm.full;
					f_txn.empty = fm.empty;
					f_txn.almostfull = fm.almostfull;
					f_txn.almostempty = fm.almostempty;


					if(~fm.clk) begin
						//Sequential Outputs of DUT
						if(fm.rst_n) begin
							f_txn.wr_ack = fm.wr_ack;	
							f_txn.overflow = fm.overflow;
							f_txn.underflow = fm.underflow;
							f_txn.data_out = fm.data_out;
						end
					end

					if(~fm.clk) f_score.check_data(f_txn);
			

					if(shared_pkg::test_finished) begin
						$display("---------------------------------------------------------------------");
						$display("----------------Correct Count and Error Count Summary----------------");
						$display("---------------------------------------------------------------------");
						$display("wr_ack:	 	\t\tCorrect Count = %0d, 	Error Count = %0d", shared_pkg::correct_count_wr_ack, 		shared_pkg::error_count_wr_ack);
						$display("full: 		\t\tCorrect Count = %0d, 	Error Count = %0d", shared_pkg::correct_count_full, 	 	shared_pkg::error_count_full);
						$display("empty: 		\t\tCorrect Count = %0d, 	Error Count = %0d", shared_pkg::correct_count_empty, 	 	shared_pkg::error_count_empty);
						$display("almostfull: 	\t\t\tCorrect Count = %0d, 	Error Count = %0d", shared_pkg::correct_count_almostfull, 	shared_pkg::error_count_almostfull);
						$display("almostempty: 	\t\t\tCorrect Count = %0d, 	Error Count = %0d", shared_pkg::correct_count_almostempty, 	shared_pkg::error_count_almostempty);
						$display("overflow: 	\t\t\tCorrect Count = %0d, 	Error Count = %0d", shared_pkg::correct_count_overflow, 	shared_pkg::error_count_overflow);
						$display("underflow: 	\t\t\tCorrect Count = %0d, 	Error Count = %0d", shared_pkg::correct_count_underflow, 	shared_pkg::error_count_underflow);
						$display("data_out: 	\t\t\tCorrect Count = %0d, 	Error Count = %0d", shared_pkg::correct_count_dout, 		shared_pkg::error_count_dout);

						@(edge fm.clk); $stop;
					end
				end
				//Transaction for Covergroup
				begin
					@(edge fm.clk);
					f_tcov.rst_n = fm.rst_n;
					f_tcov.wr_en = fm.wr_en;
					f_tcov.rd_en = fm.rd_en;
					f_tcov.data_in = fm.data_in;

					f_tcov.wr_ack = fm.wr_ack;	
					f_tcov.overflow = fm.overflow;
					f_tcov.underflow = fm.underflow;
					f_tcov.data_out = fm.data_out;

					f_tcov.full = fm.full;
					f_tcov.empty = fm.empty;
					f_tcov.almostfull = fm.almostfull;
					f_tcov.almostempty = fm.almostempty;

					f_cov.sample_data(f_tcov);
				end
			join_any
		end
	end
endmodule