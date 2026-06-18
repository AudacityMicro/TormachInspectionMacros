o<probe_y_edge_inspection> sub
(Probe in x positive or negative direction and set 0)

(PRINT, begin probe_y_edge probe)
(PRINT, _first_position_to_probe is #<_first_position_to_probe>)
(PRINT, _measuring_wcs is #<_measuring_wcs>)
(PRINT, _y_wcs_offset is #<_y_wcs_offset>)

#<_first_starting_position> = #5421

(PRINT, _first_starting_position is #<_first_starting_position>)

G90 (set to absolute mode)

(fast probe)
F#<_probe_rough_feed_per_min>
G38.2 Y#<_first_position_to_probe>
(PRINT, first touch successful)

(first retract)
G91 (set to incremental mode)
F#<_probe_rough_feed_per_min>
o100 if [#<_first_position_to_probe> GT #<_first_starting_position>]
	G38.6 Y[[#5410/2]*-1]
	o100 else
	G38.6 Y[#5410/2]
o100 endif

G90 (set to absolute mode)

(slow probe)
F#<_probe_fine_feed_per_min>
G38.2 Y#<_first_position_to_probe>
#<_first_y_touch> = #5421

(PRINT, second touch successful)

G54.1 P#<_measuring_wcs>


o160 if [#<_first_position_to_probe> GT #<_first_starting_position>]
		#<actualY> = [#<_first_y_touch> + [#5410/2]]

		O901 if [#<_dont_change_WCS> NE 1] (If don't change, set back to starting value)
			G10 L20 P#5220 Y#<actualY>
		O901 endif

    	
		
    o160 else
		#<actualY> = [#<_first_y_touch> - [#5410/2]]

		O902 if [#<_dont_change_WCS> NE 1] (If don't change, set back to starting value)
			G10 L20 P#5220 Y#<actualY>
		O902 endif

o160 endif



(second retract)
G91 (set to incremental mode)
F#<_probe_rough_feed_per_min>
o110 if [#<_first_position_to_probe> GT #<_first_starting_position>]
	G38.6 Y[[#5410/2]*-1]
	o110 else
	G38.6 Y[#5410/2]
o110 endif

G90 (set to absolute mode)

O900 if [#<_printResults> EQ 1] (Skip results logging if not enabled)

	#<_featureNumber> = FIX[[#<_featureNumber> + 1]] (Feature number should iterate every probing routine, and be set to 0 at the beginning of the program.)
	#<_componentNumber> = FIX[[#<_componentNumber> + 1]] (Component number should iterate every program)

	(Y Location Math)
	#<expectedY> = #<_y_wcs_offset>
	(#<actualY> is calculated above)
	#<errorY> = [#<actualY> - #<expectedY>]

	(LOGAPPEND,RESULTS.TXT)

	(LOG,-------------------------------------------------------------------)
	(LOG,   COMPONENT NO #<_componentNumber>                    FEATURE NO #<_featureNumber>)
	(LOG,-------------------------------------------------------------------)
	(LOG,POSN Y#<expectedY>   ACTUAL #<actualY>   DEV #<errorY>)

	(LOGCLOSE)
	
O900 endif (end of results logging)

(PRINT, end probe_y_edge probe)
o<probe_y_edge_inspection> endsub

M02 (end program)

