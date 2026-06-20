o<inspection_washdown> sub

#<washdown_pass> = 0
#<washdown_direction> = 1
#<washdown_y_step> = 0

O100 if [#<_inspection_washdown_passes> GT 1]
	#<washdown_y_step> = [[#<_inspection_washdown_y_max> - #<_inspection_washdown_y_min>] / [#<_inspection_washdown_passes> - 1]]
O100 endif

G90
G49
G53 G0 Z0 (approach the washdown envelope at safe Z)
G53 G0 X#<_inspection_washdown_x_min> Y#<_inspection_washdown_y_min>
G53 G0 Z#<_inspection_washdown_z>
M8 (flood coolant on)

O110 while [#<washdown_pass> LT #<_inspection_washdown_passes>]
	O120 if [#<washdown_pass> GT 0]
		#<washdown_y> = [#<_inspection_washdown_y_min> + [#<washdown_pass> * #<washdown_y_step>]]
		G53 G1 Y#<washdown_y> F#<_inspection_washdown_feed>
	O120 endif

	O130 if [#<washdown_direction> EQ 1]
		G53 G1 X#<_inspection_washdown_x_max> F#<_inspection_washdown_feed>
	O130 else
		G53 G1 X#<_inspection_washdown_x_min> F#<_inspection_washdown_feed>
	O130 endif

	#<washdown_direction> = [1 - #<washdown_direction>]
	#<washdown_pass> = [#<washdown_pass> + 1]
O110 endwhile

M9 (flood coolant off)
G53 G0 Z0

o<inspection_washdown> endsub
