globals [
  plate-size  ; the size of the plate on which heat is diffusing
  ; Used for scaling the color of the patches
  min-temp  ; the minimum temperature at setup time
  max-temp  ; the maximum temperature at setup time
]

patches-own [
  old-temperature  ; the temperature of the patch the last time thru go
  temperature  ; the current temperature of the patch
  bacteria
]

turtles-own[edad]

;;;;;;;;;;;;;;;;;;;;;;
;; Setup Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;
to setup
  clear-all

  ; set up the plate
  ask patches [
    set pcolor grey
    set temperature initial-plate-temp
    set-edge-temperatures
    set old-temperature temperature
    (ifelse
      conf-inicial = "Calor" [
        set bacteria true
        set temperature-die 100]
      [ set bacteria false])
  ]

  set min-temp min [old-temperature] of patches
  set max-temp max [old-temperature] of patches


  ;;Inicialización de la comida y tortuga
  ask patch 0 0 [configuracion-inicial] ; Fuente de comida --> Dónde se podrán adherir las bacterias

  crt 1[ ;crt create-turtles
    set color green ;le da color verde a la tortuga
    setxy random-xcor random-ycor ;la coloca en una coordenad random
    set edad 0 ;su edad es 0
  ]

  ask patches [ color-patch ]

  reset-ticks
end

to configuracion-inicial
  (
    ifelse
      conf-inicial = 1  [ ask patches in-radius 2 [set bacteria true]]
      conf-inicial = 2  [ ask patches with [pycor = min-pycor][set bacteria true] ]
      conf-inicial = 3  [ ask patches in-radius 2 [set bacteria true]
                          ask patches with [distance (patch 0 0) <= max-pxcor and distance (patch 0 0) > max-pxcor - 1] [set bacteria true]]
  )
end


; Sets the temperatures of the plate edges and corners
to set-edge-temperatures  ; patch procedure

  ; set the temperatures of the edges
  if (pxcor = max-pxcor) and ((abs pycor) < max-pycor)
    [set temperature right-temp]
  if (pxcor = (- max-pxcor)) and ((abs pycor) < max-pycor)
    [set temperature left-temp]
  if (pycor = max-pycor) and ((abs pxcor) < max-pxcor)
    [set temperature top-temp]
  if (pycor = (- max-pycor)) and ((abs pxcor) < max-pxcor)
    [set temperature bottom-temp]

  ; set the temperatures of the corners
  if (pxcor = max-pxcor) and (pycor = max-pycor)
    [set temperature 0.5 * (right-temp + top-temp)]
  if (pxcor = max-pxcor) and (pycor = (- max-pycor))
    [set temperature 0.5 * (right-temp + bottom-temp)]
  if (pxcor = (- max-pxcor)) and (pycor = max-pycor)
    [set temperature 0.5 * (left-temp + top-temp)]
  if (pxcor = (- max-pxcor)) and (pycor = (- max-pycor))
    [set temperature 0.5 * (left-temp + bottom-temp)]
end


;;;;;;;;;;;;;;;;;;;;;;;;
;; Runtime Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;;;

; Runs the simulation through a loop
to go

  ask patches [
    ; diffuse the heat of a patch with its neighbors
    update-neighbors
    ; set the edges back to their constant heat
    set-edge-temperatures
    set old-temperature temperature
  ]

  propaga-bacteria
  elimina-bacteria

  ask patches [color-patch]

  draw-legend

  tick
end

; color the patch based on its temperature
to color-patch  ; Patch Procedure
  ifelse (bacteria = true)[
    set pcolor scale-color red temperature min-temp max-temp]
    [set pcolor grey]
end

to color-legend  ; Patch Procedure
  set pcolor scale-color red temperature min-temp max-temp
end

; Sets the neighbors
to update-neighbors
  let suma4  (sum [old-temperature] of neighbors4)
  let suma8  (sum [old-temperature] of neighbors)
  let sumaD  (suma8 - suma4)
  (
    ifelse
      neighbors-type = 4  [ set temperature 0.25 * suma4]
      neighbors-type = "4 diagonal" [ set temperature 0.25 * sumaD]
      neighbors-type = 8  [set temperature (0.2 * suma4 + 0.05 * sumaD )]
      [ user-message "Choose your own value for neighbors!" ]
  )
end

to propaga-bacteria

  ask turtles [
    let vecinos patch-set [neighbors] of turtles
    while [(edad < 50) and (not any? vecinos with [bacteria = true])]
    [move-to one-of neighbors
      set vecinos patch-set ([neighbors] of turtles )
    set edad edad + 1
    if any? vecinos with [bacteria = true] [
       set bacteria true
       set edad 50 ]; de esta manera sale del bucle
      ]
  ]
  ask turtles [
    set edad 0
    move-to one-of patches
  ]
end

to elimina-bacteria
  ask patches with [bacteria = true] [
    let vecinos count neighbors with [bacteria = true ]
    if (vecinos = elimina)[set bacteria false]
    if (temperature > temperature-die ) [set bacteria false] ]
end


to draw-legend  ; Patch Procedure
  let x (1 + min-pxcor)
  repeat 3 [
    let y max-pycor - 15
    let z 0
    repeat 10 [
      ask patch (x + 4) y  [ set temperature (z * 10)  color-legend]
      ask patch (x + 4) y  [ set temperature (z * 10)  color-legend ]
      set y y + 1
      set z z + 1
    ]
    set y max-pycor - 15
    set z 0
    repeat 3 [
      if (x = (3 + min-pxcor)) [ ask patch  (x + 1) y [ set plabel (z * 10) ] ]
    set y y + 5
    set z z + 5
    ]
    set x x + 1
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
311
92
622
404
-1
-1
3.0
1
10
1
1
1
0
0
0
1
-50
50
-50
50
1
1
1
ticks
30.0

SLIDER
370
26
525
59
top-temp
top-temp
0
100.0
100.0
1.0
1
NIL
HORIZONTAL

SLIDER
639
116
672
271
right-temp
right-temp
0
100.0
50.0
1.0
1
NIL
VERTICAL

SLIDER
375
424
535
457
bottom-temp
bottom-temp
0
100.0
0.0
1.0
1
NIL
HORIZONTAL

SLIDER
5
50
140
83
initial-plate-temp
initial-plate-temp
0
100.0
50.0
1.0
1
NIL
HORIZONTAL

BUTTON
230
10
295
43
Go
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

SLIDER
262
125
295
280
left-temp
left-temp
0.0
100.0
50.0
1.0
1
NIL
VERTICAL

BUTTON
5
10
121
43
Setup
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
137
10
210
43
Go Once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

CHOOSER
7
95
142
140
neighbors-type
neighbors-type
4 "4 diagonal" 8
2

CHOOSER
8
150
146
195
elimina
elimina
0 1 2 3 4 5 6 7 8
0

SLIDER
8
205
180
238
temperature-die
temperature-die
0
100
100.0
1
1
NIL
HORIZONTAL

CHOOSER
10
251
148
296
conf-inicial
conf-inicial
"Calor" 1 2 3
1

@#$#@#$#@
## WHAT IS IT?

Este modelo es una combinación de dos mundos. Por un lado tenemos la ecuación del calor que evoluciona a partir de los autómatas celulares, donde el paso del tiempo se corresponde con los ticks del modelo. Por otro lado, la evolución de una colonia de bacterias y sus adversos agentes externos, esto es, además de crecer y aumentar el número de bacterias pueden verse afectadas por superpoblación o calor extremo, lo que implica que podrían desaparecer alguna de ellas según las condiciones.


Respecto la ecuación del calor cabe mencionar que se representa una placa vista desde arriba donde las fronteras permanecen estables y cada una de las esquinas de la placa es la media entre las temperatura de las fronteras adyacentes. Para ver exclusivamente la evolución de la ecuación del calor debemos seleccionar la conf-inicial "Calor". Al ejecutar veremos como la placa cambia de color y aparecerá una leyenda en la parte superior izquierda con el rango de valores y colores. En cualquiera de las otras configuraciones veremos la placa en gris y solo aparecerá en la escala de rojo la colonia de bacterias viva.



## HOW IT WORKS


En primer lugar, debemos seleccionar la temperatura inicial de la placa y de cada una de las fronteras que serán estable a lo largo del tiempo. Como la ecuación se resuelve mediante autómatas celulares, cada paso de tiempo se corresponde con los ticks que pasan en nuestro tablero. Podemos observar que tras un número considerable de ticks el tablero permanece constante y no varía más. El método de hallar el calor en cada una de las celdas depende de la vecindad seleccionada, tenemos 3 casos, los 4 típicos vecinos, los 4 vecinos digonales y los 8 vecinos. En el caso de hallar la temperatura de la celda actual según los 4 vecinos (tanto en diagonal como no) basta sumar la temperatura del instante de tiempo anterior de dichos vecinos y hacer la media, es decir, dividir entre 4. Sin embargo, en el caso de considerar los 8 vecinos se calcula de forma ligeramente diferente, debemos sumar dos cantidades: la suma de los vecinos (norte, sur, este y oeste) dividida entre 5 y la suma de los vecinos en diagonal entre 20. Con estos pasos ya tenemos la ecuación del calor resuelta.

En el caso de la colonia de bacteria tenemos una variable llamada bacteria asociada a cada uno de los patches, esto es, si hay una bacteria toma el valor "True" y en caso negativo "False". Por otro lado, hay una tortuga que se mueve aleatoriamente y cuando está en un patch negativo pero a su alrededor algún vecino es una bacteria se une a él y pasa a ser una bacteria, es decir, un patch positivo.

Es importante saber que las bacterias tambien pueden desaparecer. Es el caso de una bacteria cuya temperatura sea mayor que la seleccionada en el panel inicial como TEMPERATURE-DIE. También puede morir según el número de vecinas que tenga como bacterias, que se selecciona en la variable ELIMINA. Si tomamos temperature-die = 100 y elimina = 0, en ningún momento desaparecen las bacterias. 


## HOW TO USE IT

Por un lado los controles relacionados con la temperatura son los siguientes:

-- TOP-TEMP - Temperatura del borde superior
-- BOTTOM-TEMP - Temperatura del borde inferior
-- INITIAL-PLATE-TEMP - Temperatura inicial de la placa
-- LEFT-TEMP - Temperatura del borde izquierdo
-- RIGHT-TEMP - Temperatura del borde derecho
-- NEIGHBORS-TYPE - Tipo de vecinos a considerar en la ecuación

Hay que tener en cuenta que si todos tienen la misma temperatura el modelo no porá evolucionar puesto que no hay diferencia de calor.

Respecto las bacterias tenemos:
-- ELIMINA - Es una variable numérica entera (0,1,2...8) que selecciona el número de vecinos para que la bacteria no viva. Es decir, si una bacteria viva tiene justamente 3 vecinos y la variable ELIMINA es 3, esta bacteria tiene que morir.
-- TEMPERATURE-DIE - Temperatura a partir de la cúal las bacterias no sobreviven.
-- NUM-BAC - Número de bacterias para comenzar el modelo.
-- CONF-INICIAL - Configuración inicial de las bacterias.

Hay 3 botones con las siguientes funciones:
-- SETUP - Inicializa el modelo
-- GO - Ejecuta la simulación indefinidamente
-- GO ONCE - Ejecuta la silumación un solo paso de tiempo

El monitor TIME muestra los pasos de tiempo que ha pasado el modelo.

## THINGS TO NOTICE

Se puede observar que a partir de cambiar ligeramente un parámetro podemos obtener una configuración totalmente diferente a la anterior. Este modelo es bastante interactivo puesto que la gran mayoría de parámetros pueden variar y así conseguir distintos patrones.

## THINGS TO TRY


Para comenzar selecciona la temperatura de la placa inicial y de las fronteras, teniendo en cuenta que no pueden ser todos iguales puesto que la placa estaría estable. También debe seleccionar que vecinos tendrá en cuenta la ecuación a la hora de evolucionar, esto es, puede considerar norte, sur, este y oeste, si selecciona el botón 4, en caso de tomar "4 diagonal" sería noroeste, nordeste, sureste y suroeste y por último, tomando 8 vecinos considera todos.

Respecto las bacterias tenemos varios agentes que seleccionar. Por un lado, selecciona si desea eliminar bacterias con un número concreto de bacterias vecinas, por otro lado, selecciona una temperatura a partir de la que las bacterias no pueden permanecer. Luego, selecciona el número de bacteria inicial, a más bacterias más rápido irá el modelo pues más probabilidad de crecer tiene. Por último, selecciona la configuración inicial de bacterias.

Una vez seleccionado todo es el momento de probar:

Prueba los siguientes ejemplos con distintos valores:

- Top:100, Bottom:0,   Left:20,   Right:20, initial-plate-temp:20, conf-inicial:3,
  temperature-die:80, num_bac:5, neighbors-type:8, elimina:6

- Top:100, Bottom:0,   Left:20,   Right:20, initial-plate-temp:20, conf-inicial:1,
  temperature-die:60, num_bac:5, neighbors-type:8, elimina:0

- Top:100, Bottom:0,   Left:50,   Right:50, initial-plate-temp:20, conf-inicial:2,
  temperature-die:80, num_bac:10, neighbors-type:4, elimina:0


## EXTENDING THE MODEL

El modelo podría variar al considerar otros tipos de placas que no fueran rectangular, como por ejemplo, una placa circular o una placa con un agujero dentro. Además, podríamos extender el modelo considerando otras configuraciones iniciales o añadiendo más parámetros al modelo de las bacterias, como tener energía y en función de esta ser capaz de crecer o no. También se podría incorporar a la placa de calor otros modelo diferenes de bacterias.


## RELATED MODELS

El crecimiento de bacterias ha sido ampliamente estudiado en la comunidad ciéntifica, un ejemplo sería el estudio de crecimiento bacteriano con la presencia de un nutriente y su difusión. Otro modelo importante ampliamente estudiado en este campo y aplicado también al crecimiento de superficies es el modelo propuesto por el matemático británico Eden, A. M.

## HOW TO CITE

Este modelo se ha construido a partir de los siguientes documentos:

-- R. Lahoz-Beltrá. Bioinformática: Simulación, vida artificial e inteligencia artificial. Díaz de Santos.2004. 
-- Joel L. Schiff. Cellular Automata: A Discrete View of the World.Wiley Series in Discrete Mathematics & Optimization.2007.
-- García Vázquez, & Sancho Caparrini, F. { Netlogo: una herramienta de modelado.  Payhip. 2016.
-- ERMENTROUT, G. Bard; EDELSTEIN-KESHET, Leah.Cellular automata approaches to biological modeling. Journal of theoretical Biology, 1993, vol. 160, no 1, p. 97-133.
-- Eden, A. M. (1961). A two-dimensional growth process. Proceedings of the Cambridge Philosophical Society, 37(1), 105-109


## COPYRIGHT AND LICENSE

Copyright 2023 Uri Wilensky.

Trabajo realizado por:
-- Rafael Rodríguez García
-- Isabel María Altamirano Melero

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.

<!-- 1998 2001 -->
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
NetLogo 6.3.0
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
