##
quit -sim
vlib work

#--------------------------------#
#--      Compile Source        --#
#--------------------------------#
vcom -work work ../source/Ser2Par.vhd

#--------------------------------#
#--     Compile Test Bench     --#
#--------------------------------#
vcom -work work ../Testbench/TbSer2Par.vhd

vsim -t 100ps -novopt work.TbSer2Par
view wave

#add wave *
do wave.do


view structure
view signals

run 10 ms	

