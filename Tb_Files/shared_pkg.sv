package shared_pkg;
	
	bit test_finished;

	int correct_count_wr_ack, error_count_wr_ack,
		correct_count_full, error_count_full,
		correct_count_empty, error_count_empty,
		correct_count_almostfull, error_count_almostfull,
		correct_count_almostempty, error_count_almostempty,
		correct_count_overflow, error_count_overflow,
		correct_count_underflow, error_count_underflow,
		correct_count_dout, error_count_dout;

endpackage