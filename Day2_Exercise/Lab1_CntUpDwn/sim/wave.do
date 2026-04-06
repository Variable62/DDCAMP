onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbcntupdwn/TM
add wave -noupdate /tbcntupdwn/TT
add wave -noupdate /tbcntupdwn/Clk
add wave -noupdate /tbcntupdwn/RstB
add wave -noupdate /tbcntupdwn/CntUpEn
add wave -noupdate /tbcntupdwn/CntDwnEn
add wave -noupdate -radix hexadecimal /tbcntupdwn/CntOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {914700 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 198
configure wave -valuecolwidth 40
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
WaveRestoreZoom {0 ps} {1408100 ps}
