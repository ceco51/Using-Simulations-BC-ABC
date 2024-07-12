turtles-own [
  opinion ;between 0 and 1 (extremely against, extremely in favor a particular issue)
  eps ;bound of confidence ;it's heterogeneous in the population
  opinion-list ;list of the last max-pxcor opinions ;for visualization
]

to setup
  clear-all
  if seed? [random-seed 70] ;We used 70 as the seed for the Figures in the manuscript.
  ask patches [
    set pcolor white
  ]
  create-turtles number-of-agents
  ask turtles [
    set opinion random-float 1 ;random opinions between 0 and 1 (max. disagreemnt)
    set opinion-list (list opinion) ;initialize a list with the first value = initial opinion, opinion at t = 0
    setxy 0 (opinion * max-pycor) ;spread opinions on the y-axis at t = 0
    ]
  assign-epsilon
  reset-ticks
end

to go
  ask turtles [set opinion-list lput opinion opinion-list]
  ask turtles [update-opinion]
  ask turtles [set opinion-list replace-item (length opinion-list - 1) opinion-list opinion] ; update the opinion-list
  ask turtles [if (length opinion-list = max-pxcor + 1) [set opinion-list butfirst opinion-list]] ; cut oldest values for "rolling" opinion list
  ask turtles [random-change]
  if visualization? [draw-trajectories]
  tick
end

to assign-epsilon
  ask turtles [
    let x random-gamma alpha 1
    set eps (x / (x + random-gamma beta 1)) ; set eps a random number from distribution Beta(alpha,beta) (between 0 and 1)
    set eps min-eps + (eps * (max-eps - min-eps)) ; scale and shift eps to lie between min-eps and max-eps
    set color colorcode eps 0.5 ; see reporter colorcode
    ]
  update-plots
end

to update-opinion ;opinion updating procedure ;adjust opinion to mean of all in agents closer than eps
  set opinion aggregate (filter[opinion-others -> abs(opinion-others - opinion) < eps] [opinion] of turtles)
end

to random-change ;randomly reset opinion with probability mu
  if (random-float 1 < mu) [
    set opinion random-float 1
  ]
end

to draw-trajectories ;let turtles move with their opinion trajectories from left to right across the world drawing trajectories or coloring patches
  clear-drawing
  ask turtles [
    pen-up
    setxy 0 (item 0 opinion-list * max-pycor)
  ]
  ifelse (visualization = "Colored histogram over time")
  [ask turtles [pen-up]]
  [ask turtles [pen-down]] ;trajectories in Figure 4 of the Chapter
  let t-counter 1
  while [
    t-counter < (length ([opinion-list] of turtle 1))
  ]
  [
    ask turtles [setxy t-counter (item t-counter opinion-list * max-pycor)]
    ifelse (visualization = "Colored histogram over time")
    [ask patches with [pxcor = t-counter] [set pcolor colorcode ((count turtles-here) / number-of-agents) 0.2]]
    [ask patches [set pcolor white]]
    set t-counter t-counter + 1
  ]
end

;;;;; Reporters ;;;;;

to-report aggregate [opinions] ;set opinion to either mean or median of those in bounds of confidence
   if (aggregation-method = "mean") [report mean opinions]
   if (aggregation-method = "median") [report median opinions]
end

to-report colorcode [x max-x] ;report a color as "x=0 --> violet", "x=max-x --> red" on the color axis violet,blue,cyan,green,yellow,orange,red
  report __hsb-old (190 - 190 * (x / max-x)) 255 255
end

to-report opinion-distr
  report [opinion] of turtles
end

to-report mean-opinion
  report mean [opinion] of turtles
end

to-report median-opinion
  report median [opinion] of turtles
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copyright 2012 Jan Lorenz
; The original model was coded by Jan Lorenz. Please, see here: https://ccl.northwestern.edu/netlogo/models/community/bc
; We simplified the code to make it more streamlined for expository purposes in the "Using Simulations" chapter.
; The original model and code by Lorenz are more comprehensive than ours.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@#$#@#$#@
GRAPHICS-WINDOW
304
10
711
269
-1
-1
3.3
1
10
1
1
1
0
0
0
1
0
120
0
75
1
1
1
ticks
30.0

BUTTON
13
45
105
78
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
110
45
209
78
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
1

SLIDER
12
92
157
125
number-of-agents
number-of-agents
100
1000
200.0
1
1
NIL
HORIZONTAL

CHOOSER
11
149
163
194
aggregation-method
aggregation-method
"mean" "median"
0

PLOT
12
344
201
480
Histogram eps
eps
NIL
0.0
1.0
0.0
30.0
false
false
"" "set-plot-y-range 0 round(number-of-agents / 8)"
PENS
"default" 0.02 1 -16777216 true "" "histogram [eps] of turtles"

SLIDER
431
329
600
362
min-eps
min-eps
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
432
370
600
403
max-eps
max-eps
min-eps
1 - min-eps
0.3
0.01
1
NIL
HORIZONTAL

SLIDER
432
406
600
439
alpha
alpha
0.01
6
2.0
0.01
1
NIL
HORIZONTAL

BUTTON
15
304
197
337
NIL
assign-epsilon
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
15
282
414
300
3. Setting Confidence Bounds: eps ~ Beta(alpha,beta,min,max)
12
0.0
1

PLOT
217
344
419
480
pdf beta-distribution
eps
NIL
0.0
1.0
0.0
0.0
true
false
"" "clear-plot"
PENS
"default" 1.0 0 -5825686 true "" "if (max-eps > min-eps) [\nplotxy min-eps 0\nforeach (n-values 99 [ ?1 -> (?1 + 1) / 100 * (max-eps - min-eps) + min-eps ] ) [ ?1 -> plotxy ?1 ( ((?1 - min-eps) ^ (alpha - 1) * (max-eps - ?1) ^ (beta - 1)) / ( max-eps - min-eps ) ^ (alpha + beta - 1) ) ]\nplotxy max-eps 0\n]"

TEXTBOX
16
10
166
40
Setup initializes the model \nGo runs it
12
0.0
1

CHOOSER
725
10
932
55
visualization
visualization
"Colored histogram over time" "Agents' trajectories"
1

PLOT
728
79
1086
284
Histogram
Current Opinion
NIL
0.0
1.0
0.0
0.0
true
false
"" "set-plot-y-range 0 round(number-of-agents / 8)"
PENS
"default" 0.02 1 -13345367 true "" "histogram [opinion] of turtles"

TEXTBOX
15
131
259
149
1. Opinion Update
12
0.0
1

PLOT
728
283
1086
483
Opinion
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"mean" 1.0 0 -16777216 true "" "plot mean [opinion] of turtles"
"median" 1.0 0 -2674135 true "" "plot median [opinion] of turtles"

SLIDER
433
442
600
475
beta
beta
0.01
6
4.0
0.01
1
NIL
HORIZONTAL

TEXTBOX
432
316
599
334
Parameters for beta-distribution
9
0.0
1

SLIDER
14
229
217
262
mu
mu
0
0.30
0.1
0.01
1
NIL
HORIZONTAL

TEXTBOX
14
211
259
229
2. Probability of random opinion reset
12
0.0
1

SWITCH
950
16
1099
49
seed?
seed?
1
1
-1000

SWITCH
1101
112
1229
145
visualization?
visualization?
1
1
-1000

TEXTBOX
1107
61
1257
103
Turn this \"on\" to visualize opinion trajectories. When \"off\", faster execution 
11
0.0
1

@#$#@#$#@
## CREDITS AND REFERENCES

Copyright 2012 Jan Lorenz. http://janlo.de, post@janlo.de

Creative Commons Attribution-ShareAlike 3.0 Unported License
 
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ .
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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
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
