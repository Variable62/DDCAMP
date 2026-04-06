onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbser2par/TM
add wave -noupdate /tbser2par/TT
add wave -noupdate /tbser2par/RstB
add wave -noupdate /tbser2par/Clk
add wave -noupdate /tbser2par/SerDataIn
add wave -noupdate /tbser2par/SerEn
add wave -noupdate /tbser2par/ParDataOut
add wave -noupdate /tbser2par/ParValid
add wave -noupdate /tbser2par/u_Ser2Par/rParData
add wave -noupdate /tbser2par/u_Ser2Par/rCnt8
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {139800 ps} 0}
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
WaveRestoreZoom {0 ps} {1259500 ps}
