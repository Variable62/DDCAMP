onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TbVGAGenerator/TM
add wave -noupdate /TbVGAGenerator/TT
add wave -noupdate /TbVGAGenerator/VGARstB
add wave -noupdate /TbVGAGenerator/VGAClk
add wave -noupdate /TbVGAGenerator/VGAClkB
add wave -noupdate /TbVGAGenerator/VGADe
add wave -noupdate /TbVGAGenerator/VGAHSync
add wave -noupdate /TbVGAGenerator/VGAVSync
add wave -noupdate /TbVGAGenerator/VGAData
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {904500 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 173
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1523600 ps}
