o<probe_z_inspection> sub
(Probe in x positive or negative direction and set 0)

(PRINT, begin probe_z probe)
(PRINT, _first_position_to_probe is #<_first_position_to_probe>)
(PRINT, _measuring_wcs is #<_measuring_wcs>)
(PRINT, _z_wcs_offset is #<_z_wcs_offset>)

#<_first_starting_position> = #5422
(PRINT, _first_starting_position is #<_first_starting_position>)

G90 (set to absolute mode)

(fast probe)
F#<_probe_rough_feed_per_min>
G38.2 Z#<_first_position_to_probe>
(PRINT, first touch successful)

(first retract)
G91 (set to incremental mode)
F#<_probe_rough_feed_per_min>
o100 if [#<_metric> EQ 1]  
	o110 if [#<_first_position_to_probe> GT #<_first_starting_position>]
		G38.6 Z-.1
	o110 else
		G38.6 Z.1
	o110 endif
	o100 else
	o120 if [#<_first_position_to_probe> GT #<_first_starting_position>]
		G38.6 Z-.05
	o120 else
		G38.6 Z.05
	o120 endif
o100 endif

G90 (set to absolute mode)

(slow probe)
F#<_probe_fine_feed_per_min>
G38.2 Z#<_first_position_to_probe>
(PRINT, second touch successful)

#<_first_z_touch> = #5422
(PRINT, _first_z_touch is #<_first_z_touch>)

O901 if [#<_dont_change_WCS> NE 1] (If don't change, set back to starting value)
	G10 L20 P#<_measuring_wcs> Z#<_z_wcs_offset>
O901 endif

(second retract)
G91 (set to incremental mode)
F#<_probe_rough_feed_per_min>
o130 if [#<_metric> EQ 1]  
	o140 if [#<_first_position_to_probe> GT #<_first_starting_position>]
	G38.6 Z-.1
	o140 else
	G38.6 Z.1
	o140 endif
o130 else
	o150 if [#<_first_position_to_probe> GT #<_first_starting_position>]
	G38.6 Z-.05
	o150 else
	G38.6 Z.05
	o150 endif
o130 endif

G90 (set to absolute mode)

O900 if [#<_printResults> EQ 1] (Skip results logging if not enabled)


	(Z Location Math)
	#<expectedZ> = #<_z_wcs_offset>
	#<actualZ> = #<_first_z_touch>
	#<errorZ> = [#<actualZ> - #<expectedZ>]


	(LOGAPPEND,RESULTS.TXT)

	(LOG,POSN Z#<expectedZ>   ACTUAL #<actualZ>   DEV #<errorZ>)

	(LOGCLOSE)
	
O900 endif (end of results logging)

(PRINT, end probe_z probe)
o<probe_z_inspection> endsub

