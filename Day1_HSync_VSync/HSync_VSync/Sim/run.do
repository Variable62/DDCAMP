##
quit -sim
vlib work

#--------------------------------#
#--      Compile Source        --#
#--------------------------------#
vcom -work work ../Source/VGAGenerator.vhd

#--------------------------------#
#--     Compile Test Bench     --#
#--------------------------------#
vcom -work work ../Testbench/TbVGAGenerator.vhd

vsim -t 100ps -novopt work.TbVGAGenerator
view wave

do wave.do

view structure
view signals

run 100 us	

