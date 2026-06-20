o<probe_x_boss_inspection> sub
(Probe in x positive or negative direction and set 0)

(PRINT, begin probe_x_boss)
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

#1 = #5420 (current relative X position)
#2 = #5421 (current relative Y position)
#3 = #5422 (current relative Z position)
#4 = #5220 (current active wcs)
(PRINT, # 1 is #1)
(PRINT, # 2 is #2)
(PRINT, # 3 is #3)
(PRINT, # 4 is #4)

(fast probe)
F#<_probe_rough_feed_per_min>
G38.2 X#<_first_position_to_probe>
(PRINT, first x touch successful)

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
(PRINT, second x touch successful)

#<_first_x_touch> = #5061
(PRINT, _first_x_touch is #<_first_x_touch>)

(second retract)
G91 (set to incremental mode)
F#<_probe_rough_feed_per_min>
o110 if [#<_first_position_to_probe> GT #<_first_starting_position>]
	G38.6 X[[#5410/2]*-1]
	o110 else
	G38.6 X[#5410/2]
o110 endif

G90 (set to absolute mode)

G1 Z#<_z_clearance_position> F#<_probe_rapid_feed_per_min>

(second X position)
G1 X#<_second_x_position> Y#<_second_y_position>
G1 Z#<_second_z_position> F#<_probe_rough_feed_per_min>

#<_second_starting_position> = #5420

(PRINT, _second_starting_position is #<_second_starting_position>)

(fast probe)
F#<_probe_rough_feed_per_min>
G38.2 X#<_second_position_to_probe>
(PRINT, first x touch successful)

(first retract)
G91 (set to incremental mode)
F#<_probe_rough_feed_per_min>
o200 if [#<_second_position_to_probe> GT #<_second_starting_position>]
	G38.6 X[[#5410/2]*-1]
	o200 else
	G38.6 X[#5410/2]
o200 endif

G90 (set to absolute mode)

(slow probe)
F#<_probe_fine_feed_per_min>
G38.2 X#<_second_position_to_probe>
(PRINT, second x touch successful)

#<_second_x_touch> = #5061
(PRINT, _second_x_touch is #<_second_x_touch>)

(X finished retract)
G91 (set to incremental mode)
F#<_probe_rough_feed_per_min>
o210 if [#<_second_position_to_probe> GT #<_second_starting_position>]
	G38.6 X[[#5410/2]*-1]
	o210 else
	G38.6 X[#5410/2]
o210 endif

G90 (set to absolute mode)

G1 Z#<_z_clearance_position> F#<_probe_rapid_feed_per_min>

(PRINT, centering x)
#<_x_center> = [[#<_first_x_touch> + #<_second_x_touch>] / 2]
(PRINT, _x_center is #<_x_center>)
G1 X#<_x_center>
G54.1 P#<_measuring_wcs>

O901 if [#<_dont_change_WCS> NE 1] (If don't change, set back to starting value)
	G10 L20 P#5220 X#<_x_wcs_offset>
O901 endif

G54.1 P#4


O900 if [#<_printResults> EQ 1] (Skip results logging if not enabled)


	(Size Math)
	#<expectedSize> = #<_FeatureLength>
	#<actualSize> = [ABS[[#<_first_x_touch>-#<_second_x_touch>]]-#5410]
	#<errorSize> = [#<actualSize> - #<expectedSize>]

	(X Location Math)
	#<expectedX> = [[#<_first_position_to_probe> + #<_second_position_to_probe>] / 2]
	#<actualX> = #<_x_center>
	#<errorX> = [#<actualX> - #<expectedX>]

	(Y Location Math)
	#<expectedY> = #<_second_y_position>

	(LOGAPPEND,RESULTS.TXT)

	(LOG,SIZE D#<expectedSize>   ACTUAL #<actualSize>   DEV #<errorSize>)
	(LOG,POSN X#<expectedX>   ACTUAL #<actualX>   DEV #<errorX>)
	(LOG,POSN Y#<expectedY>   ACTUAL NaN   DEV NaN)

	(LOGCLOSE)
	
O900 endif (end of results logging)



(PRINT, end probe_x_boss)
o<probe_x_boss_inspection> endsub
