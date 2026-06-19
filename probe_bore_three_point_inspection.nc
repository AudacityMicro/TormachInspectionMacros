o<probe_bore_three_point_inspection> sub

(PRINT, begin probe_bore_three_point)
(PRINT, _first_vector is #<_first_vector>)
(PRINT, _second_vector is #<_second_vector>)
(PRINT, _third_vector is #<_third_vector>)
(PRINT, _diameter_to_probe is #<_diameter_to_probe>)
(PRINT, _measuring_wcs is #<_measuring_wcs>)
(PRINT, _x_wcs_offset is #<_x_wcs_offset>)
(PRINT, _y_wcs_offset is #<_y_wcs_offset>)

#1 = #5420 (current relative X position)
#2 = #5421 (current relative Y position)
#4 = #5220 (current active wcs)
#<probe_retract_distance> = [#5410/2]
#<first_vector_x_target> = [#1 + [#<_diameter_to_probe> * COS[#<_first_vector>]]]
#<first_vector_y_target> = [#2 + [#<_diameter_to_probe> * SIN[#<_first_vector>]]]
#<second_vector_x_target> = [#1 + [#<_diameter_to_probe> * COS[#<_second_vector>]]]
#<second_vector_y_target> = [#2 + [#<_diameter_to_probe> * SIN[#<_second_vector>]]]
#<third_vector_x_target> = [#1 + [#<_diameter_to_probe> * COS[#<_third_vector>]]]
#<third_vector_y_target> = [#2 + [#<_diameter_to_probe> * SIN[#<_third_vector>]]]
(PRINT, # 1 is #1)
(PRINT, # 2 is #2)
(PRINT, # 4 is #4)

G90 (set absolute mode)

(PRINT, probing first vector)
(fast probe)
F#<_probe_rough_feed_per_min>
G38.2 X#<first_vector_x_target> Y#<first_vector_y_target>
(PRINT, first first_vector touch successful)

(first retract)
G91 (set incremental mode)
G38.6 X[[#<probe_retract_distance> * COS[#<_first_vector>]] * -1] Y[[#<probe_retract_distance> * SIN[#<_first_vector>]] * -1]
G90 (set absolute mode)

(slow probe)
F#<_probe_fine_feed_per_min>
G38.2 X#<first_vector_x_target> Y#<first_vector_y_target>
(PRINT, second first_vector touch successful)

#<_first_vector_x_location> = #5420
#<_first_vector_y_location> = #5421
(PRINT, _first_vector_x_location is #<_first_vector_x_location>)
(PRINT, _first_vector_y_location is #<_first_vector_y_location>)

(retract from first touch point)
G91
G38.6 X[[#<probe_retract_distance> * COS[#<_first_vector>]] * -1] Y[[#<probe_retract_distance> * SIN[#<_first_vector>]] * -1] F#<_probe_rapid_feed_per_min>
G90
G1 X#1 Y#2 F#<_probe_rapid_feed_per_min>

(PRINT, probing second vector)
(fast probe)
F#<_probe_rough_feed_per_min>
G38.2 X#<second_vector_x_target> Y#<second_vector_y_target>
(PRINT, first second_vector touch successful)

(second retract)
G91 (set incremental mode)
G38.6 X[[#<probe_retract_distance> * COS[#<_second_vector>]] * -1] Y[[#<probe_retract_distance> * SIN[#<_second_vector>]] * -1]
G90 (set absolute mode)

(slow probe)
F#<_probe_fine_feed_per_min>
G38.2 X#<second_vector_x_target> Y#<second_vector_y_target>
(PRINT, second second_vector touch successful)

#<_second_vector_x_location> = #5420
#<_second_vector_y_location> = #5421
(PRINT, _second_vector_x_location is #<_second_vector_x_location>)
(PRINT, _second_vector_y_location is #<_second_vector_y_location>)

(retract from second touch point)
G91
G38.6 X[[#<probe_retract_distance> * COS[#<_second_vector>]] * -1] Y[[#<probe_retract_distance> * SIN[#<_second_vector>]] * -1] F#<_probe_rapid_feed_per_min>
G90
G1 X#1 Y#2 F#<_probe_rapid_feed_per_min>

(PRINT, probing third vector)
(fast probe)
F#<_probe_rough_feed_per_min>
G38.2 X#<third_vector_x_target> Y#<third_vector_y_target>
(PRINT, first third_vector touch successful)

(third retract)
G91 (set incremental mode)
G38.6 X[[#<probe_retract_distance> * COS[#<_third_vector>]] * -1] Y[[#<probe_retract_distance> * SIN[#<_third_vector>]] * -1]
G90 (set absolute mode)

(slow probe)
F#<_probe_fine_feed_per_min>
G38.2 X#<third_vector_x_target> Y#<third_vector_y_target>
(PRINT, second third_vector touch successful)

#<_third_vector_x_location> = #5420
#<_third_vector_y_location> = #5421
(PRINT, _third_vector_x_location is #<_third_vector_x_location>)
(PRINT, _third_vector_y_location is #<_third_vector_y_location>)

(retract from third touch point)
G91
G38.6 X[[#<probe_retract_distance> * COS[#<_third_vector>]] * -1] Y[[#<probe_retract_distance> * SIN[#<_third_vector>]] * -1] F#<_probe_rapid_feed_per_min>
G90
G1 X#1 Y#2 F#<_probe_rapid_feed_per_min>

(PRINT, probing of points finished, start of calculations)

(First perpendicular bisector)
#<variable> = [[#<_second_vector_x_location> + #<_first_vector_x_location>] / 2]
#<variable2> = [[#<_second_vector_y_location> + #<_first_vector_y_location>] / 2]
#<variable3> = [#<_second_vector_x_location> - #<_first_vector_x_location>]
#<variable4> = [[#<_second_vector_y_location> - #<_first_vector_y_location>] * -1]

(Second perpendicular bisector)
#<variable5> = [[#<_third_vector_x_location> + #<_second_vector_x_location>] / 2]
#<variable6> = [[#<_third_vector_y_location> + #<_second_vector_y_location>] / 2]
#<variable7> = [#<_third_vector_x_location> - #<_second_vector_x_location>]
#<variable8> = [[#<_third_vector_y_location> - #<_second_vector_y_location>] * -1]

(Find x center)
#<_x_center_mid1> = [#<variable2> * #<variable4> * #<variable8> + #<variable5> * #<variable4> *#<variable7> - #<variable> * #<variable3> * #<variable8> - #<variable6> * #<variable4> * #<variable8>]
#<_x_center_mid2> = [#<variable4> * #<variable7> - #<variable3> * #<variable8>]
#<_x_center> = [#<_x_center_mid1> / #<_x_center_mid2>]
(PRINT, _x_center is #<_x_center>)

(Find y center)
#<_y_center> = [[#<_x_center> - #<variable>] * #<variable3> / #<variable4> + #<variable2>]
(PRINT, _y_center is #<_y_center>)

(move to center)
G1 X#<_x_center> Y#<_y_center> F#<_probe_rough_feed_per_min>
G54.1 P#<_measuring_wcs>

O901 if [#<_dont_change_WCS> NE 1] (If don't change, set back to starting value)
	G10 L20 P#5220 X#<_x_wcs_offset> Y#<_y_wcs_offset>
O901 endif

G54.1 P#4

O900 if [#<_printResults> EQ 1] (Skip results logging if not enabled)

	#<_featureNumber> = FIX[[#<_featureNumber> + 1]] (Feature number should iterate every probing routine, and be set to 0 at the beginning of the program.)
	#<_componentNumber> = FIX[[#<_componentNumber> + 1]] (Component number should iterate every program)

	(Size Math)

	(Calculate the radius for each point)
	#<_radius_1> = [[ SQRT[ [ #<_x_center> - #<_first_vector_x_location> ]  * [ #<_x_center> - #<_first_vector_x_location> ]  + [ #<_y_center> - #<_first_vector_y_location> ]  * [ #<_y_center> - #<_first_vector_y_location> ] ] ] + #5410/2]
	#<_radius_2> = [[ SQRT[ [ #<_x_center> - #<_second_vector_x_location> ] * [ #<_x_center> - #<_second_vector_x_location> ] + [ #<_y_center> - #<_second_vector_y_location> ] * [ #<_y_center> - #<_second_vector_y_location> ] ] ] + #5410/2]
	#<_radius_3> = [[ SQRT[ [ #<_x_center> - #<_third_vector_x_location> ]  * [ #<_x_center> - #<_third_vector_x_location> ]  + [ #<_y_center> - #<_third_vector_y_location> ]  * [ #<_y_center> - #<_third_vector_y_location> ] ] ] + #5410/2]

	(Compute the averaged radius and diameter)
	#<_average_radius> = [ [#<_radius_1> + #<_radius_2> + #<_radius_3> ] / 3 ]
	#<_average_diameter> = [ 2 * #<_average_radius> ]

	(Compute the max error (max deviation from average radius))
	(not currently implemented in fusion inspection report)
	#<_error_1> = [ ABS[ #<_radius_1> - #<_average_radius> ] ]
	#<_error_2> = [ ABS[ #<_radius_2> - #<_average_radius> ] ]
	#<_error_3> = [ ABS[ #<_radius_3> - #<_average_radius> ] ]
	

	#<expectedSize> = #<_FeatureLength>
	#<actualSize> = #<_average_diameter>
	#<errorSize> = [#<actualSize> - #<expectedSize>]

	(X Location Math)
	#<expectedX> = #1
	#<actualX> = #<_x_center>
	#<errorX> = [ #<actualX> - #<expectedX>]

	(Y Location Math)
	#<expectedY> = #2
	#<actualY> = #<_y_center>
	#<errorY> = [ #<actualY> - #<expectedY>]

	(LOGAPPEND,RESULTS.TXT)

	(LOG,-------------------------------------------------------------------)
	(LOG,   COMPONENT NO #<_componentNumber>                    FEATURE NO #<_featureNumber>)
	(LOG,-------------------------------------------------------------------)
	(LOG,SIZE D#<expectedSize>   ACTUAL #<actualSize>   DEV #<errorSize>)
	(LOG,POSN X#<expectedX>   ACTUAL #<actualX>   DEV #<errorX>)
	(LOG,POSN Y#<expectedY>   ACTUAL #<actualY>   DEV #<errorY>)

	(LOGCLOSE)
	
O900 endif (end of results logging)



(PRINT, end probe_bore_three_point)
o<probe_bore_three_point_inspection> endsub
