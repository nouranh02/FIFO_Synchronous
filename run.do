vlog shared_pkg.sv transaction_pkg.sv coverage_pkg.sv scoreboard_pkg.sv FIFO_top.sv FIFO_if.sv FIFO_tb.sv FIFO_monitor.sv FIFO.sv +define+SIM +cover
vsim -voptargs=+acc work.FIFO_top -classdebug -cover

add wave -position insertpoint sim:/FIFO_top/F_if/*
add wave -position insertpoint  \
sim:/FIFO_top/FIFO_DUT/mem \
sim:/FIFO_top/FIFO_DUT/wr_ptr \
sim:/FIFO_top/FIFO_DUT/rd_ptr \
sim:/FIFO_top/FIFO_DUT/count

add wave -position insertpoint  \
sim:/FIFO_top/FIFO_MON/f_txn \
sim:/FIFO_top/FIFO_MON/f_cov \
sim:/FIFO_top/FIFO_MON/f_score

add wave /FIFO_top/FIFO_DUT/assertion_reset_asserted /FIFO_top/FIFO_DUT/assertion_wr_enabled /FIFO_top/FIFO_DUT/assertion_wr_enabled_full /FIFO_top/FIFO_DUT/assertion_wr_disabled /FIFO_top/FIFO_DUT/assertion_rd_enabled /FIFO_top/FIFO_DUT/assertion_rd_enabled_empty /FIFO_top/FIFO_DUT/assertion_rd_disabled /FIFO_top/FIFO_DUT/assertion_FIFO_almostfull /FIFO_top/FIFO_DUT/assertion_FIFO_full /FIFO_top/FIFO_DUT/assertion_FIFO_almostempty /FIFO_top/FIFO_DUT/assertion_FIFO_empty

coverage save FIFO_top.ucdb -onexit

run -all