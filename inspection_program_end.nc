o<inspection_program_end> sub

#<skip_washdown> = 0

M5 (stop spindle)
M9 (coolant off)
G90
G49 (cancel tool length compensation)
G53 G0 Z0 (fully retract Z in machine coordinates)

O90 if [#<_inspection_washdown_enabled> EQ 1]
	O95 if [#<_inspection_end_change_tool> EQ 1]
		O96 if [#<_inspection_end_tool_number> EQ 0]
			#<skip_washdown> = 1
		O96 endif
		O97 if [#<_inspection_end_tool_number> EQ 99]
			#<skip_washdown> = 1
		O97 endif
		O98 if [#<_inspection_end_tool_number> EQ 1000]
			#<skip_washdown> = 1
		O98 endif

		O99 if [#<skip_washdown> EQ 0]
			O100 if [#5400 NE #<_inspection_end_tool_number>]
				T#<_inspection_end_tool_number> G43 H#<_inspection_end_tool_number> M6
			O100 endif
			G49
			G53 G0 Z0 (retract again after the tool-change remap)
		O99 endif
	O95 endif

	O105 if [#5400 EQ 0]
		#<skip_washdown> = 1
	O105 endif
	O106 if [#5400 EQ 99]
		#<skip_washdown> = 1
	O106 endif
	O107 if [#5400 EQ 1000]
		#<skip_washdown> = 1
	O107 endif

	O115 if [#<skip_washdown> EQ 1]
		(MSG,WARNING: Cleaning cycle skipped because T0, T99, or T1000 is selected or loaded)
	O115 else
		o<inspection_washdown> call
	O115 endif
O90 endif

G53 G0 X#<_inspection_end_x> Y#<_inspection_end_y>

O120 if [#<_inspection_archive_results> EQ 1]
	M199 (archive completed inspection results)
O120 endif

o<inspection_program_end> endsub
