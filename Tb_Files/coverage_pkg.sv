package coverage_pkg;
import transaction_pkg::*;

	class FIFO_coverage;

		FIFO_transaction F_cvg_txn = new();

		function void sample_data(FIFO_transaction f_tcov);
			F_cvg_txn = f_tcov;
			FIFO_cg.sample();
		endfunction

		covergroup FIFO_cg;
			cross_full: 		cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.full;
			cross_empty: 		cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.empty;
			cross_almost_full: 	cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.almostfull;
			cross_almost_empty: cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.almostempty;
			cross_overflow: 	cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.overflow;
			cross_underflow:	cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.underflow;
			cross_ack: 			cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.wr_ack;		
		endgroup

		function new;
			FIFO_cg = new();
		endfunction

	endclass

endpackage