onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbpar2ser/TM
add wave -noupdate /tbpar2ser/TT
add wave -noupdate /tbpar2ser/RstB
add wave -noupdate /tbpar2ser/Clk
add wave -noupdate /tbpar2ser/ParLoad
add wave -noupdate -radix binary /tbpar2ser/ParDataIn
add wave -noupdate /tbpar2ser/SerEn
add wave -noupdate /tbpar2ser/SerOut
add wave -noupdate -radix binary /tbpar2ser/u_Par2Ser/rParData
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1099900 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 206
configure wave -valuecolwidth 60
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
WaveRestoreZoom {0 ps} {1418600 ps}
