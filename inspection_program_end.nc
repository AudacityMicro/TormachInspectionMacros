o<inspection_program_end> sub

M5 (stop spindle)
M9 (coolant off)
G90
G49 (cancel tool length compensation)
G53 G0 Z0 (fully retract Z in machine coordinates)

O90 if [#<_inspection_washdown_enabled> EQ 1]
	O100 if [#<_inspection_end_change_tool> EQ 1]
		O110 if [#5400 NE #<_inspection_end_tool_number>]
			T#<_inspection_end_tool_number> G43 H#<_inspection_end_tool_number> M6
		O110 endif
		G49
		G53 G0 Z0 (retract again after the tool-change remap)
	O100 endif

	o<inspection_washdown> call
O90 endif

G53 G0 X#<_inspection_end_x> Y#<_inspection_end_y>

O120 if [#<_inspection_archive_results> EQ 1]
	M199 (archive completed inspection results)
O120 endif

o<inspection_program_end> endsub
