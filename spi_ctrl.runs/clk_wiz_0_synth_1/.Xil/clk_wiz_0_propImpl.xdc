set_property SRC_FILE_INFO {cfile:c:/Users/hikaru/readout/pcb_gb/fpga/rhea/spi_ctrl/spi_ctrl.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc rfile:../../../spi_ctrl.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc id:1 order:EARLY scoped_inst:U0} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:56 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1_p]] 0.05
