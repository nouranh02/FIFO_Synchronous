package transaction_pkg;
	class FIFO_transaction;
		//Parameters
		parameter FIFO_WIDTH = 16;
		parameter FIFO_DEPTH = 8;

		//Inputs to DUT
		rand bit rst_n, wr_en, rd_en;
		rand logic [FIFO_WIDTH-1:0] data_in;

		//Outputs of DUT
		bit wr_ack, full, empty, almostfull, almostempty, overflow, underflow;
		logic [FIFO_WIDTH-1:0] data_out;

		//Constraints (wr_en, rd_en)
		int WR_EN_ON_DIST = 70;
		int RD_EN_ON_DIST = 30;

		constraint rst_c {
			rst_n 			dist {0:=5, 	1:=95};
		}

		constraint wr_en_c {
			wr_en 			dist {0:=(100 - WR_EN_ON_DIST), 	1:=WR_EN_ON_DIST};
		}

		constraint rd_en_c {
			rd_en 			dist {0:=(100 - RD_EN_ON_DIST), 	1:=RD_EN_ON_DIST};
		}

	endclass
endpackage