##
quit -sim
vlib work

#--------------------------------#
#--      Compile Source        --#
#--------------------------------#
vcom -work work ../source/Par2Ser.vhd

#--------------------------------#
#--     Compile Test Bench     --#
#--------------------------------#
vcom -work work ../Testbench/TbPar2Ser.vhd

vsim -t 100ps -novopt work.TbPar2Ser
view wave

#add wave *
do wave.do


view structure
view signals

run 100 us	

