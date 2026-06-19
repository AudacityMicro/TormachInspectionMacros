o<probe_xy_corner_inspection> sub
(Probe in x positive or negative direction and set 0)

(PRINT, begin probe_xy_corner probe, probing X first)
(PRINT, _first_position_to_probe is #<_first_position_to_probe>)
(PRINT, _second_position_to_probe is #<_second_position_to_probe>)
(PRINT, _second_x_position is #<_second_x_position>)
(PRINT, _second_y_position is #<_second_y_position>)
(PRINT, _second_z_position is #<_second_z_position>)
(PRINT, _z_clearance_position is #<_z_clearance_position>)
(PRINT, _measuring_wcs is #<_measuring_wcs>)
(PRINT, _x_wcs_offset is #<_x_wcs_offset>)

#<_first_starting_position> = #5420

(PRINT, _first_starting_position is #<_first_starting_position>)

G90 (set to absolute mode)

#3 = #5220 (current active wcs)
(PRINT, # 3 is #3)

(fast probe)
F#<_probe_rough_feed_per_min>
G38.2 X#<_first_position_to_probe>
(PRINT, first touch successful)

(first retract)
G91 (set to incremental mode)
F#<_probe_rough_feed_per_min>
o100 if [#<_first_position_to_probe> GT #<_first_starting_position>]
	G38.6 X[[#5410/2]*-1]
	o100 else
	G38.6 X[#5410/2]
o100 endif

G90 (set to absolute mode)

(slow probe)
F#<_probe_fine_feed_per_min>
G38.2 X#<_first_position_to_probe>
(PRINT, second touch successful)

#<_first_x_touch> = #5420
(PRINT, _first_x_touch is #<_first_x_touch>)

G54.1 P#<_measuring_wcs>

o160 if [#<_first_position_to_probe> GT #<_first_starting_position>]
		#<actualX> = [#<_first_x_touch> + [#5410/2]]

		O901 if [#<_dont_change_WCS> NE 1] (If don't change, set back to starting value)
			G10 L20 P#5220 X#<actualX>
		O901 endif
    	
		
    o160 else
		#<actualX> = [#<_first_x_touch> - [#5410/2]]

		O902 if [#<_dont_change_WCS> NE 1] (If don't change, set back to starting value)
			G10 L20 P#5220 X#<actualX>
		O902 endif

o160 endif

(second retract)
G91 (set to incremental mode)
F#<_probe_rough_feed_per_min>
o110 if [#<_first_position_to_probe> GT #<_first_starting_position>]
	G38.6 X[[#5410/2]*-1]
	o110 else
	G38.6 X[#5410/2]
o110 endif

G90 (set to absolute mode)

(PRINT, probing of x complete, begin probing of y)
G54.1 P#3
G1 Z#<_z_clearance_position> F#<_probe_rapid_feed_per_min> (rapid move to Z clearance height)
G1 X#<_second_x_position> Y#<_second_y_position>
G1 Z#<_second_z_position> F#<_probe_rough_feed_per_min>

#<_second_starting_position> = #5421

(PRINT, _second_starting_position is #<_second_starting_position>)

(fast probe)
F#<_probe_rough_feed_per_min>
G38.2 Y#<_second_position_to_probe>
(PRINT, first touch successful)

(first retract)
G91 (set to incremental mode)
F#<_probe_rough_feed_per_min>
o200 if [#<_second_position_to_probe> GT #<_second_starting_position>]
	G38.6 Y[[#5410/2]*-1]
	o200 else
	G38.6 Y[#5410/2]
o200 endif

G90 (set to absolute mode)

(slow probe)
F#<_probe_fine_feed_per_min>
G38.2 Y#<_second_position_to_probe>
(PRINT, second touch successful)

#<_second_y_touch> = #5421
(PRINT, _second_y_touch is #<_second_y_touch>)

G54.1 P#<_measuring_wcs>


o260 if [#<_second_position_to_probe> GT #<_second_starting_position>]
		#<actualY> = [#<_second_y_touch> + [#5410/2]]

		O903 if [#<_dont_change_WCS> NE 1] (If don't change, set back to starting value)
			G10 L20 P#5220 Y#<actualY>
		O903 endif		
		
    o260 else
		#<actualY> = [#<_second_y_touch> - [#5410/2]]

		O904 if [#<_dont_change_WCS> NE 1] (If don't change, set back to starting value)
    		G10 L20 P#5220 Y#<actualY>
		O904 endif		

o260 endif




(second retract)
G91 (set to incremental mode)
F#<_probe_rough_feed_per_min>
o210 if [#<_second_position_to_probe> GT #<_second_starting_position>]
	G38.6 Y[[#5410/2]*-1]
	o210 else
	G38.6 Y[#5410/2]
o210 endif

G90 (set to absolute mode)



O900 if [#<_printResults> EQ 1] (Skip results logging if not enabled)


	(X Location Math)
	#<expectedX> = #<_x_wcs_offset>
	(#<actualX> is calculated above)
	#<errorX> = [#<actualX> - #<expectedX>]

	(Y Location Math)
	#<expectedY> = #<_y_wcs_offset>
	(#<actualY> is calculated above)
	#<errorY> = [#<actualY> - #<expectedY>]

	(LOGAPPEND,RESULTS.TXT)

	(LOG,POSN X#<expectedX>   ACTUAL #<actualX>   DEV #<errorX>)
	(LOG,POSN Y#<expectedY>   ACTUAL #<actualY>   DEV #<errorY>)

	(LOGCLOSE)
	
O900 endif (end of results logging)

(PRINT, end probe_xy_outer_corner probe)
o<probe_xy_corner_inspection> endsub

M02 (end program)
