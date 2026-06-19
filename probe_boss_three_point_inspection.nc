o<probe_boss_three_point_inspection> sub

(PRINT, begin probe_boss_three_point)
(PRINT, _first_vector is #<_first_vector>)
(PRINT, _second_vector is #<_second_vector>)
(PRINT, _third_vector is #<_third_vector>)
(PRINT, _diameter_to_probe is #<_diameter_to_probe>)
(PRINT, _diameter_to_position is #<_diameter_to_position)
(PRINT, _measuring_wcs is #<_measuring_wcs>)
(PRINT, _x_wcs_offset is #<_x_wcs_offset>)
(PRINT, _y_wcs_offset is #<_y_wcs_offset>)

#1 = #5420 (current relative X position)
#2 = #5421 (current relative Y position)
#3 = #5422 (current relative Z position)
#4 = #5220 (current active wcs)
#<_radius_to_position> = [#<_diameter_to_position> / 2]
#<_radius_to_probe> = [#<_diameter_to_probe> / 2]
#<first_position_x> = [#1 + [#<_radius_to_position> * COS[#<_first_vector>]]]
#<first_position_y> = [#2 + [#<_radius_to_position> * SIN[#<_first_vector>]]]
#<first_probe_x> = [#1 + [#<_radius_to_probe> * COS[#<_first_vector>]]]
#<first_probe_y> = [#2 + [#<_radius_to_probe> * SIN[#<_first_vector>]]]
#<second_position_x> = [#1 + [#<_radius_to_position> * COS[#<_second_vector>]]]
#<second_position_y> = [#2 + [#<_radius_to_position> * SIN[#<_second_vector>]]]
#<second_probe_x> = [#1 + [#<_radius_to_probe> * COS[#<_second_vector>]]]
#<second_probe_y> = [#2 + [#<_radius_to_probe> * SIN[#<_second_vector>]]]
#<third_position_x> = [#1 + [#<_radius_to_position> * COS[#<_third_vector>]]]
#<third_position_y> = [#2 + [#<_radius_to_position> * SIN[#<_third_vector>]]]
#<third_probe_x> = [#1 + [#<_radius_to_probe> * COS[#<_third_vector>]]]
#<third_probe_y> = [#2 + [#<_radius_to_probe> * SIN[#<_third_vector>]]]


(PRINT, # 1 is #1)
(PRINT, # 2 is #2)
(PRINT, # 3 is #3)
(PRINT, # 4 is #4)

o1 if [#<_diameter_to_position> LE #<_diameter_to_probe>]
	(PRINT, diameter to position = #<_diameter_to_position>)
	(PRINT, diameter to probe = #<_diameter_to_probe>)
	(DEBUG, diameter to position = #<_diameter_to_position>)
	(DEBUG, diameter to probe = #<_diameter_to_probe>)
	(ABORT, diameter to position is less than or equal to diameter to probe in probe_boss_three_point routine)
o1 endif

G90 (set absolute mode)

(first vector position)
G1 X#<first_position_x> Y#<first_position_y> F#<_probe_rapid_feed_per_min>
G1 Z#<_first_position_to_probe> F#<_probe_rough_feed_per_min>

(PRINT, probing first vector)
(fast probe)
G38.2 X#<first_probe_x> Y#<first_probe_y>
(PRINT, first first_vector touch successful)

(first retract)
G38.6 X#<first_position_x> Y#<first_position_y>

(slow probe)
F#<_probe_fine_feed_per_min>
G38.2 X#<first_probe_x> Y#<first_probe_y>
(PRINT, first_vector touch finished)

#<_first_vector_x_location> = #5420
#<_first_vector_y_location> = #5421
(PRINT, _first_vector_x_location is #<_first_vector_x_location>)
(PRINT, _first_vector_x_location is #<_first_vector_x_location>)

(retract from first touch point)
G38.6 X#<first_position_x> Y#<first_position_y> F#<_probe_rapid_feed_per_min>
G1 Z#3 (retract to original Z position)

(return to start position)
G1 X#1 Y#2 (retract to original XY position)

(PRINT, probing second vector)
(second vector position)
G1 X#<second_position_x> Y#<second_position_y> F#<_probe_rapid_feed_per_min>
G1 Z#<_first_position_to_probe>

(fast probe)
F#<_probe_rough_feed_per_min>
G38.2 X#<second_probe_x> Y#<second_probe_y>
(PRINT, first second_vector touch successful)

(second retract)
G38.6 X#<second_position_x> Y#<second_position_y>

(slow probe)
F#<_probe_fine_feed_per_min>
G38.2 X#<second_probe_x> Y#<second_probe_y>
(PRINT, second_vector touch finished)

#<_second_vector_x_location> = #5420
#<_second_vector_y_location> = #5421
(PRINT, _second_vector_x_location is #<_second_vector_x_location>)
(PRINT, _second_vector_y_location is #<_second_vector_y_location>)

(retract from second touch point)
G38.6 X#<second_position_x> Y#<second_position_y> F#<_probe_rapid_feed_per_min>
G1 Z#3 (retract to original Z position)

(return to start position)
G1 X#1 Y#2 (retract to original XY position)

(PRINT, probing third vector)
(third vector position)
G1 X#<third_position_x> Y#<third_position_y> F#<_probe_rapid_feed_per_min>
G1 Z#<_first_position_to_probe>
(fast probe)
F#<_probe_rough_feed_per_min>
G38.2 X#<third_probe_x> Y#<third_probe_y>
(PRINT, first third_vector touch successful)

(third retract)
G38.6 X#<third_position_x> Y#<third_position_y>

(slow probe)
F#<_probe_fine_feed_per_min>
G38.2 X#<third_probe_x> Y#<third_probe_y>
(PRINT, second third_vector touch successful)

#<_third_vector_x_location> = #5420
#<_third_vector_y_location> = #5421
(PRINT, _third_vector_x_location is #<_third_vector_x_location>)
(PRINT, _third_vector_y_location is #<_third_vector_y_location>)

(retract from third touch point)
G38.6 X#<third_position_x> Y#<third_position_y> F#<_probe_rapid_feed_per_min>
G1 Z#3 (retract to original Z position)

(return to start position)
G1 X#1 Y#2 (retract to original XY position)

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


	(Size Math)

	(Calculate the radius for each point)
	#<_radius_1> = [[ SQRT[ [ #<_x_center> - #<_first_vector_x_location> ]  * [ #<_x_center> - #<_first_vector_x_location> ]  + [ #<_y_center> - #<_first_vector_y_location> ]  * [ #<_y_center> - #<_first_vector_y_location> ] ] ] - #5410/2]
	#<_radius_2> = [[ SQRT[ [ #<_x_center> - #<_second_vector_x_location> ] * [ #<_x_center> - #<_second_vector_x_location> ] + [ #<_y_center> - #<_second_vector_y_location> ] * [ #<_y_center> - #<_second_vector_y_location> ] ] ] - #5410/2]
	#<_radius_3> = [[ SQRT[ [ #<_x_center> - #<_third_vector_x_location> ]  * [ #<_x_center> - #<_third_vector_x_location> ]  + [ #<_y_center> - #<_third_vector_y_location> ]  * [ #<_y_center> - #<_third_vector_y_location> ] ] ] - #5410/2]

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

	(LOG,SIZE D#<expectedSize>   ACTUAL #<actualSize>   DEV #<errorSize>)
	(LOG,POSN X#<expectedX>   ACTUAL #<actualX>   DEV #<errorX>)
	(LOG,POSN Y#<expectedY>   ACTUAL #<actualY>   DEV #<errorY>)

	(LOGCLOSE)
	
O900 endif (end of results logging)




(PRINT, end probe_boss_three_point)
o<probe_boss_three_point_inspection> endsub

