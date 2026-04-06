##
quit -sim
vlib work

#--------------------------------#
#--      Compile Source        --#
#--------------------------------#
vcom -work work ../source/Counter.vhd

#--------------------------------#
#--     Compile Test Bench     --#
#--------------------------------#
vcom -work work ../Testbench/TbCounter.vhd

vsim -t 100ps -novopt work.TbCounter
view wave

do wave.do

view structure
view signals

run 100 us	

