package scoreboard_pkg;
import transaction_pkg::*;
import shared_pkg::*;

	class FIFO_scoreboard;
		parameter FIFO_WIDTH = 16;

		logic wr_ack_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref, overflow_ref, underflow_ref;
		logic [FIFO_WIDTH-1:0] data_out_ref;

		logic [FIFO_WIDTH-1:0] mem_q[$];
		logic [3:0] mem_q_size, mem_size_aftr_wr, mem_size_aftr_rd;

		task check_data(FIFO_transaction f_txn);

			reference_model(f_txn, wr_ack_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref, overflow_ref, underflow_ref, data_out_ref);

			if(f_txn.wr_ack != wr_ack_ref) begin
				$display("ERROR: Output -wr_ack- equals %0b, but should equal %0b. \t\t--time: %0t", f_txn.wr_ack, wr_ack_ref, $time);
				error_count_wr_ack++;
			end
			else correct_count_wr_ack++;

			if(f_txn.full != full_ref) begin
				$display("ERROR: Output -full- equals %0b, but should equal %0b. \t\t--time: %0t", f_txn.full, full_ref, $time);
				error_count_full++;
			end
			else correct_count_full++;

			if(f_txn.empty != empty_ref) begin
				$display("ERROR: Output -empty- equals %0b, but should equal %0b. \t\t--time: %0t", f_txn.empty, empty_ref, $time);
				error_count_empty++;
			end
			else correct_count_empty++;

			if(f_txn.almostfull != almostfull_ref) begin
				$display("ERROR: Output -almostfull- equals %0b, but should equal %0b. \t\t--time: %0t", f_txn.almostfull, almostfull_ref, $time);
				error_count_almostfull++;
			end
			else correct_count_almostfull++;

			if(f_txn.almostempty != almostempty_ref) begin
				$display("ERROR: Output -almostempty- equals %0b, but should equal %0b. \t\t--time: %0t", f_txn.almostempty, almostempty_ref, $time);
				error_count_almostempty++;
			end
			else correct_count_almostempty++;

			if(f_txn.overflow != overflow_ref) begin
				$display("ERROR: Output -overflow- equals %0b, but should equal %0b. \t\t--time: %0t", f_txn.overflow, overflow_ref, $time);
				error_count_overflow++;
			end
			else correct_count_overflow++;

			if(f_txn.underflow != underflow_ref) begin
				$display("ERROR: Output -underflow- equals %0b, but should equal %0b. \t\t--time: %0t", f_txn.underflow, underflow_ref, $time);
				error_count_underflow++;
			end
			else correct_count_underflow++;

			if(f_txn.data_out != data_out_ref) begin
				$display("ERROR: Output -data_out- equals %0h, but should equal %0h. \t\t--time: %0t", f_txn.data_out, data_out_ref, $time);
				error_count_dout++;
			end
			else correct_count_dout++;
		endtask

		task reference_model(FIFO_transaction f_txn, output bit wr_ack_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref, overflow_ref, underflow_ref, logic [FIFO_WIDTH-1:0] data_out_ref);
			
			if(!f_txn.rst_n) begin
				mem_q.delete();
				data_out_ref = 0;
				overflow_ref = 0;
				underflow_ref = 0;
				wr_ack_ref = 0;
			end
			else begin
				mem_q_size = mem_q.size();
				fork
					//Write Operation
					begin
						if( (f_txn.wr_en && (mem_q.size() < f_txn.FIFO_DEPTH)) || (f_txn.wr_en && f_txn.rd_en && (mem_q.size() == (f_txn.FIFO_DEPTH))) ) begin
							mem_q.push_front(f_txn.data_in);
							wr_ack_ref = 1;
							mem_size_aftr_wr = mem_q.size();
						end
						else begin
							if(f_txn.wr_en) overflow_ref = 1;
							else overflow_ref = 0;
							wr_ack_ref = 0;
						end
						if(!f_txn.rd_en) data_out_ref = 0;
					end

					//Read Operation
					begin
						if( (f_txn.rd_en && (mem_q.size() != 0)) || (f_txn.wr_en && f_txn.rd_en && (mem_q.size() == 0)) ) begin
							data_out_ref = mem_q.pop_back();
							mem_size_aftr_rd = mem_q.size();
						end
						else begin
							if(f_txn.rd_en) underflow_ref = 1;
							else underflow_ref = 0;
							data_out_ref = 0;
						end
					end
				join
			end

			if(mem_q.size() == f_txn.FIFO_DEPTH) full_ref = 1;
			else full_ref = 0;

			if(mem_q.size() == (f_txn.FIFO_DEPTH - 1)) almostfull_ref = 1;
			else almostfull_ref = 0;

			if(mem_q.size() == 0) empty_ref = 1;
			else empty_ref = 0;

			if(mem_q.size() == 1) almostempty_ref = 1;
			else almostempty_ref = 0;

		endtask

	endclass
	
endpackage