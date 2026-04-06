##
quit -sim
vlib work

#--------------------------------#
#--      Compile Source        --#
#--------------------------------#
vcom -work work ../source/CntUpDwn.vhd

#--------------------------------#
#--     Compile Test Bench     --#
#--------------------------------#
vcom -work work ../Testbench/TbCntUpDwn.vhd

vsim -t 100ps -novopt work.TbCntUpDwn
view wave

do wave.do

view structure
view signals

run 100 us	

