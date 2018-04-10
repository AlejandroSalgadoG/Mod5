globals [ population farmer_color bandit_color soldier_color]

breed [ farmers farmer ]
breed [ bandits bandit ]
breed [ soldiers soldier ]

breed [ houses house ]
breed [ farms farm ]
breed[ cityhalls cityhall ]

patches-own [ danger ]

farmers-own [ energy load my_house my_farm my_cityhall destination vision_range max_energy]
soldiers-own [ energy load my_house my_cityhall destination vision_range max_energy]
bandits-own [ energy load my_house destination vision_range max_energy]

houses-own [ inventory ]
cityhalls-own [ inventory ]

to setup
  ca
  reset-ticks

  set population (farmers_num + bandits_num + soldiers_num)

  set farmer_color blue
  set bandit_color orange
  set soldier_color green

  ask patches[
   set danger black
  ]

  create-cityhalls cityhalls_num [
    setxy random-xcor random-ycor
    set shape "house colonial"
    set inventory 10

    set color grey
  ]

  create-farms farms_num [
    setxy random-xcor random-ycor
    set shape "cow"

    set color brown
  ]

  create-houses population [
    setxy random-xcor random-ycor
    set shape "house"
    set inventory 2
  ]

  create-farmers farmers_num [
    set max_energy farmers_energy
    set color farmer_color
    ;set shape "person farmer"

    set energy farmers_energy
    set vision_range 4
    set load 0

    let house_id (who - population)
    set my_house house house_id
    ask my_house [set color farmer_color]
    move-to my_house

    set my_farm closest farms
    set my_cityhall closest cityhalls

    set destination my_farm
  ]

  create-bandits bandits_num [
    set max_energy bandits_energy
    set color bandit_color

    set energy bandits_energy
    set vision_range 4
    set load 0

    let house_id (who - population)
    set my_house house house_id
    ask my_house [ set color bandit_color ]
    move-to my_house

    set destination closest farmers
  ]

  create-soldiers soldiers_num [
    set max_energy soldiers_energy
    set color soldier_color

    set energy soldiers_energy
    set vision_range 4

    let house_id (who - population)
    set my_house house house_id
    ask my_house [set color soldier_color]
    move-to my_house

    set my_cityhall closest cityhalls

    set destination closest bandits
  ]
end

to go
  tick

  ask cityhalls[
    set label inventory
  ]
  ask houses [
    set label inventory
  ]
  ask farmers [
    set label load

    if destination = my_cityhall and i_am_on my_cityhall[ pay_taxes ]
    if destination = my_farm and i_am_on my_farm [ work ]
    if destination = my_house and i_am_on my_house [ rest_f ]

    move_towards destination
    decrement_energy
  ]

  ask bandits [
    set label load

    move_away_from closest soldiers

    ifelse i_am_on my_house [ rest_b ] [ assault ]

    decrement_energy
  ]

  ask soldiers [
    set label load

    move_towards destination

    ifelse i_am_on my_cityhall [ rest_s ] [ seize ]

    decrement_energy
  ]

  ifelse see_danger_zones [ ask patches [ set pcolor danger ]] [ ask patches [set pcolor black] ]
end

to move_away_from [ threat ]
  ifelse threat != nobody and distance threat <= vision_range[
    face threat
    rt 180
    fd distance_to_move
  ][move_towards destination]
end

to-report i_am_on [place]
  report member? place turtles-here
end

to-report distance_to_move
  report 1;(energy / max_energy) / 2 + 0.5
end

to move_towards [place]
  if place != nobody and not i_am_on place [
    face place
    fd min (list distance_to_move (distance place) )
  ]
end

to assault
  let victim one-of farmers-here
  let bandit_load load
  if victim != nobody [
    let loot 0
    ask victim[
      set loot min (list load (bandits_max_load - bandit_load))
      set load (load - loot)
    ]
    if loot != 0 [ ask patch-here [ increment_danger ] ]
    set load (load + loot)
  ]
  set destination closest (farmers with [load != 0])
  if energy = 0 or load > bandits_max_load [ set destination my_house ]
end

to increment_danger
  set danger scale-color red (min (list (danger + 1) 15)) 0 30
end

to seize
  let criminal one-of bandits-here
  let soldier_load load
  if criminal != nobody [
    let loot 0
    ask criminal[
      set loot min (list load (soldiers_max_load - soldier_load))
      set load (load + loot)
      become_farmer
    ]
    set load (load + loot)
  ]

  ifelse energy = 0 or load > soldiers_max_load [ set destination my_cityhall ] [ set destination closest bandits ]
end

to work
  set load farmers_max_load
  set destination my_cityhall
end

to rest_in [place]
  let my_energy energy
  let old_energy energy
  let my_load load
  let mmax_energy max_energy
  ask place [
      set inventory inventory + my_load

      if inventory > 0 [
          set my_energy min (list mmax_energy (inventory * energy_from_food))
          set inventory inventory - (my_energy - old_energy) / energy_from_food
      ]
  ]

  set energy my_energy
  set load 0
end

to rest_f
  rest_in my_house

  set destination my_farm
  if energy = 0 [
    ifelse random-float 1 < government_support [ become_soldier ] [ become_bandit ]
  ]
end

to rest_b
  rest_in my_house

  set destination closest farmers
  if energy = 0 [ become_farmer ]
end

to rest_s
  rest_in my_cityhall

  set destination closest bandits
  if energy = 0 [ become_farmer ]
end

to become_bandit
  set color bandit_color
  set breed bandits
  set energy bandits_energy + 1

  ask my_house [ set color bandit_color ]

  set destination my_house
end

to become_soldier
  set color soldier_color
  set breed soldiers
  set energy soldiers_energy + 1

  ask my_house [ set color soldier_color ]

  move-to my_cityhall
end

to become_farmer
  set color farmer_color
  set breed farmers
  set energy farmers_energy + 1

  ask my_house [ set color farmer_color ]
  set my_farm closest_from_home farms
  set my_cityhall closest_from_home cityhalls

  set destination my_house
end

to pay_taxes
  let my_load load

  ask my_cityhall [ set inventory inventory + min (list my_load tax_rate) ]

  set load load - min (list load tax_rate)
  set destination my_house
end

to-report closest [ agents ]
  report min-one-of agents [distance myself]
end

to-report closest_from_home [ agents ]
  let my_home my_house
  report min-one-of agents [distance my_home]
end

to decrement_energy
  ifelse energy > 0 [ set energy energy - 1 ][ set load max (list (load - 1 / energy_from_food) 0)]
end
@#$#@#$#@
GRAPHICS-WINDOW
671
32
1403
765
-1
-1
21.94
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
40
40
105
73
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
217
40
280
73
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
132
40
195
73
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
35
101
207
134
farmers_num
farmers_num
0
50
20.0
1
1
NIL
HORIZONTAL

SLIDER
36
153
208
186
bandits_num
bandits_num
0
50
7.0
1
1
NIL
HORIZONTAL

SLIDER
229
100
401
133
farmers_energy
farmers_energy
0
100
40.0
1
1
NIL
HORIZONTAL

SLIDER
230
152
402
185
bandits_energy
bandits_energy
0
100
34.0
1
1
NIL
HORIZONTAL

SLIDER
422
100
594
133
farmers_max_load
farmers_max_load
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
421
153
593
186
bandits_max_load
bandits_max_load
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
229
253
401
286
energy_from_food
energy_from_food
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
421
254
593
287
tax_rate
tax_rate
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
38
204
210
237
soldiers_num
soldiers_num
0
50
0.0
1
1
NIL
HORIZONTAL

SLIDER
230
205
402
238
soldiers_energy
soldiers_energy
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
35
304
207
337
cityhalls_num
cityhalls_num
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
228
305
400
338
farms_num
farms_num
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
35
254
208
287
government_support
government_support
0
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
422
204
594
237
soldiers_max_load
soldiers_max_load
0
100
30.0
1
1
NIL
HORIZONTAL

SWITCH
421
304
594
337
see_danger_zones
see_danger_zones
0
1
-1000

PLOT
58
471
559
736
Population vs Time
Time
Population
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"farmers" 1.0 0 -13345367 true "" "plot count farmers"
"soldiers" 1.0 0 -15575016 true "" "plot count soldiers"
"bandits" 1.0 0 -2674135 true "" "plot count bandits"

MONITOR
87
404
185
449
Farmers wealth 
sum [ inventory ] of houses with [ color = farmer_color]
2
1
11

MONITOR
260
402
357
447
Bandits wealth
sum [ inventory ] of houses with [ color = bandit_color]
2
1
11

MONITOR
430
403
525
448
Soldiers wealth
sum [ inventory ] of cityhalls
2
1
11

@#$#@#$#@
## Generalities

This model is the representation of a simplified society in which three types
of building define the infractucture necessary for the interactions that occurs
between the three social groups. In this model the
economy is based on a single type of resource which represents all commodities,
this resources are produced by farmers in the first type of building named
farms, this buildings are assume as an infite source of income. This
resources are also used as currency to pay taxes in the second type of
building, named city hall, this building reseprent the government
institutions and store the supplys that are used to sustain soldiers,
which are in charge of seeking for the well being of the farmers by
keeping bandit population at bay. The last building type, named houses,
are used by farmers and bandits to store the spare resources that they
earn either by gathering them in a farm, in the case of farmers, or
stealing, in the case of bandits.

### Purpose

The purpose of the model is to analyse how delincuency affects the normal
development of a socity, from the effect that has in the workforce and how
reactions, like incrementing the public force angets, emerge as responce to
protect citizens from criminality.

### Entities and state variables
Entities

*  Farms: Provides an endless source of the necessary resources for the
population to subsist with.

*  Houses: Serves as an storage for the spare resources an indivial has
after using a portion of those to meet its needs. If a given individual
does not carry enought resources to refill its energy, they can use the
ones they have previously stored in their house.

*  City Hall: It stores the resources that farmers pay as taxes and also
the ones soldiers seize from bandits. Soldiers can use the funds in the
city hall to sustain themselves.

*  Farmers: They gather resources from farms and pay a certain amount of
those resources in the city hall as a way of paying soldiers for their
protection.

*  Bandits: Steal resources from farmers to sustain themselves while
trying to avoid soldiers.

*  Soldiers: Pursue bandits in order to reintegrate them into society as
farmers and recover the funds they have stolen.

State variables

The common atributes farmers, bandits and soldiers have are:

*  Energy: This serves as a way of telling of how much time an agent
have before it needs to eat and thus return to its home or in the case or
soldiers, city hall.

*  Load: It reprecents the quantity of resources a given agent is
carrying with itself at the moment.

*  Destination: This is the current destination a given agent seeks to
move towards to. In the case of farmers this can be their house, farm or
city hall. In the case of bandits this can be a possible farmer to rob or
their house. And finally it can be a nearby bandit or their city hall in
the case of soldiers.

Houses and City Halls share a common atribute named inventory which
is the amount of resources it is storing at the moment.

### Process overview and scheduling

Our procesess is divided in three parts, one for each social group. If the
agent is a farmer it will cycle through their assigned farm, city hall and
house. If the agent is a bandit will cycle trough, chasing after farmers trying
to assault them and going home. In the case of soldiers they loop over chasing
after bandits and going to their city hall. Finally on each tick all agents
will lose 1 unit of energy.

## Design concepts

### Basic principles

In this model it is supposed that the population is constant over time.  All
agents want to collect resources, each one in a different way depending on its
occupation. Also it is considered that there is a finite amount of weight and
energy that each individual can have. The spupply of resources available on
farms and the amount of resources that can be stored in a building is taken
as infinite. Finally each person has their own house.

### Emergence

There are many emergence behaviour in the model like the agglomeration of
agents in some parts of the map as a consequence of various farmers being
assigned to the same workplace. This attracts bandits thus incrementing the
criminality nearby this places and therefore making soldiers to appear in this
zones. Also the appearrance of sectors with a high dencity of bandits living in
it due to the remoteness that some places have from farms or city halls, making
the living as a farmer unsustainable.

### Adaptation

In the model agents adapt to their current situation if the conditions does not
provides enough resources to supply for a living by means of changing their
ocupation. It is important to notice that the social groups that an agent can
switch to depends on the occupation that they are currently performing.

### Objectives

The objective of an agent varies depending on their current occupation. Farmers
try to collect as much resources as they can by working their respective farms.
Bandits try to steal as much resources from farmers as they can, trying not to
be captured by soldiers. Finally soldiers seek to decreace the amount of
bandits in the society.

### Learning

Learning capabilities of agents are not taken into account in this model.

### Prediction

Prediction procedures are not taken into account as part of the agent's
behaviour in this model.

### Sensing

In this model bandits can know which farmers are currently carrying any resources
with themselves, they also search for nearby soldiers in order to be ready to
run away. In the case of soldiers they can know the position of the closest
bandit, so that they can chase after it. Also all agents are aware of the
location of the necessary buildings to carry out their occupation.

### Interaction

The model exhibit two types of interactions, one passive between members of the
social groups and the buildings, and the other one active between human agents
only. In the first case houses and city halls are used by active agents to
store their spare resources and farms are used by farmers to get the resources
they need for living. In the second case there are interactions between
bandits and the farmers they are going to steal from, and between soldiers and
the bandtis they are seeking to convert.

### Stochasticity

This model is present a stochastic behaviour due to the random initialization of
buildings and the introduction of a fix probability to determine the change of
occupation in the case of farmers to simulate the government support they have.

### Collectives

The model is define in terms of three major groups, farmers that represent
the productive class, bandits which represents the delinquency and soldiers
that represent control of the government in the society. The dynamic of the
system is define in terms of the interactions of these three groups.

### Observation

The variables that are necessary to know the current state of the system are
the population of each social group. The violence indicator, which is defined
in terms of the number of crimes committed in a specific location of the map.
Finally the capital that each group is currently possesing, which describes the
economical force and hence the success that the group has achived.

## Details

### Initialization

The model has 14 paramerters, the first nine correspond to the population,
energy and max load of each social group. Also there are two parameters in
charge of setting the amount of city halls and farms that the simulation will
have. Another parameter is the energy from food, that defines the amount of
energy recovered by each unit of resource. There is another parameter name tax
rate that establishes the tax fee that farmers have to pay in the city halls.
Finally the government support parameter is used as the probability that a
farmer has to choose to become a bandit or a soldier when the choise arrises.

At the begining of the simulation the position of all agents is chosen randomly
and all the parameters described above are used to determine the execution of
the simulation.

### Input

There is no input data used in the model.

### Submodels

*  Move: Is executed on each tick by all human agents, which
will make them move to their current destination and lose 1 unit of energy.
If they have no energy they will start consuming the resources they are
carrying at the moment to supply their lack of energy.

*  Rest: Is executed when an agent gets to
their resting place (houses in the case of bandits and farmers, and city
halls for soldiers) they will consume as much of the resources they
have at their disposal to refill their energy. Any remaining resources will
be stored in their resting place for later use. On the other hand, if they
do not have enough resources to do so, they will execute the
switch-occupation submodel.

*  Switch-occupation: This one is executed in a different way
depending on the agent occupation. In the case of farmers it will dicide if
the new occupation is to became a soldier or a bandit depending on the
government support. For both bandits and soldiers it will cause them to
switch occupation into farmers.

*  Work: This submodel is unique for farmers. When it is
executed they will extract resources from the farm they are currently in.
The amount of resources extracted will be equal to the max load they are
able to carry. Finally they will set their destination to the city hall to
pay-taxes.

*  Pay-taxes: This is also present only in farmers.
They will pay as much resources of the tax rate parameter as they can. If
they have less than the amount required they will give up all they
have. Whatever the amount of resources they are able to give, will be stored
in the city hall to pay for soldiers expenses. Lastly they will change
their destination to home in order to rest.

*  Assault: Only bandits are allowed to execute this submodel.
They will set their destination to the nearest farmer with non-zero load to
steal all of their belongings. In the case that there is a nearby soldier
they will prioritice moving away from them to avoid being caught. They
will continue to do so until either their energy hits zero or they get to the
maximum amount of load they are able to carry, and later set their detination
to their home in order to call the rest submodel.

*  Seize: Finally, this submodel is responsible to make
soldiers set their destination to the nearest bandit, if they get close
enought, they will make them execute the switch-occupation submodel. All
the resources bandits carry when they get caught are then seized by the
soldier. They will chase after bandits until either their energy hits zero
or they meet their maximum load, after which they will change their
destination to the city hall to rest.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house colonial
false
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

person lumberjack
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -2674135 true false 60 196 90 211 114 155 120 196 180 196 187 158 210 211 240 196 195 91 165 91 150 106 150 135 135 91 105 91
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -6459832 true false 174 90 181 90 180 195 165 195
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -6459832 true false 126 90 119 90 120 195 135 195
Rectangle -6459832 true false 45 180 255 195
Polygon -16777216 true false 255 165 255 195 240 225 255 240 285 240 300 225 285 195 285 165
Line -16777216 false 135 165 165 165
Line -16777216 false 135 135 165 135
Line -16777216 false 90 135 120 135
Line -16777216 false 105 120 120 120
Line -16777216 false 180 120 195 120
Line -16777216 false 180 135 210 135
Line -16777216 false 90 150 105 165
Line -16777216 false 225 165 210 180
Line -16777216 false 75 165 90 180
Line -16777216 false 210 150 195 165
Line -16777216 false 180 105 210 180
Line -16777216 false 120 105 90 180
Line -16777216 false 150 135 150 165
Polygon -2674135 true false 100 30 104 44 189 24 185 10 173 10 166 1 138 -1 111 3 109 28

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
