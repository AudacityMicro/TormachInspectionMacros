o<initialize_inspection> sub

O100 if [#<_printResults> EQ 1] (Skip everything if not in inspection mode)

    #<_featureNumber> = 0 (reset feature counter)
    #<_componentNumber> = 0 (reset component counter)
O100 endif



o<initialize_inspection> endsub
