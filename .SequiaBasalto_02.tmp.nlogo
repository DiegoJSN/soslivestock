;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; REPLICATION OF SEQUIA-BASALTO MODEL IN NETLOGO ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The original model was built in CORMAS, for more information about the original model see Dieguez-Cameroni et al. (2012, 2014)
;; Some aspects of the model related with the growth of livestock and the transition through different age classes are based on Robins et al. (2015).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declaration of agents and variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals [
;; Climate related global variables
  climacoef                                                             ;; relates the primary production in a season with the average for that season due to climate variations
  current-season                                                        ;; define the season in which the simulation begins: 0 = winter, 1 = spring, 2 = summer, 3 = fall
  current-season-name                                                   ;; translates the numbers "0, 1, 2, 3" to "winter, spring, summer, fall"
  season-coef                                                           ;; affects the live weight gain of animals in relation with the grass quality according to the season: winter = 1, spring = 1.15, summer = 1.05, fall = 1

;; Time related global variables
  days-per-tick                                                         ;; variable to simulate time
  number-of-season                                                      ;; variable to keep track of the number of seasons that have passed since the start of the simulation
  simulation-time                                                       ;; variable to keep track of the days of the simulation
  season-days                                                           ;; variable to keep track of the days that have passed since the start of the season (values from 1 to 92)
  year-days                                                             ;; variable to keep track of the days that have passed since the start of a year (values from 1 to 368)

;; Grass related global variables
  kmax                                                                  ;; maximum carrying capacity (maximum grass height), it varies according to the season: winter= 7.4 cm, spring= 22.2 cm, summer= 15.6 cm, fall= 11.1 cm
  DM-cm-ha                                                              ;; variable used to calculate the grass-height consumed from the dry matter consumed: 180 Kg of DM/cm/ha
  grass-energy                                                          ;; metabolizable energy per Kg of dry matter: 1.8 Mcal/Kg of DM

;; Livestock related global variables
  maxLWG                                                                ;; variable that defines the maximum live weight gain per animal according to the season: spring = 60 Kg/animal; winter, summer and fall = 40 Kg/animal.
  ni                                                                    ;; variable used to define the live weight gain per animal: 0.24 1/cm
  xi                                                                    ;; variable used to define the live weight gain per animal: 132 kg
  weaned-calf-age-min                                                   ;; determines the beginning of the “weaned-calf” age class of the livestock life cycle: 246 days
  heifer-age-min                                                        ;; determines the beginning of the “heifer” (for female calves) or “steer” (for male calves) age class of the livestock life cycle: 369 days
  cow-age-min                                                           ;; determines the beginning of the “cow” age class for heifers: 737 days
  cow-age-max                                                           ;; determines the life expectancy of cattle: 5520 days
  gestation-period                                                      ;; determines the gestation period of pregnant cows: 276 days
  lactation-period                                                      ;; determines the lactating period of cows with calves: 184 days
  weight-gain-lactation                                                 ;; affects the live weight gain of lactating animals (i.e., “born-calf” age class): 0.61 Kg/day


;; Market prices & economic balance related global variables
  exploitation-costs ; External data, regular costs for maintaining the plot ($/ha).
  grazing-prices ; External data, costs for renting an external plot ($/head/season sent it to the external plot).
  supplement-prices ; External data, costs for feeding the animals with food supplements (grains, $/head/season).
  born-calves-prices ; External data, prices for selling born calves ($/Kg).
  weaned-calves-prices ; External data, prices for selling weaned calves ($/Kg).
  steers-prices ; External data, prices for selling born steers ($/Kg).
  heifers-prices ; External data, prices for selling heifers ($/Kg).
  cows-prices; External data, prices for selling empty cows ($/Kg).
  pregnant-cows-prices ; External data, prices for selling pregnant cows ($/Kg).
  lactating-cows-prices ; External data, prices for selling lactating cows ($/Kg).
  sheep-prices ; External data, prices for selling sheep-meat ($/Kg).
  wool-prices ; External data, prices for selling wool ($/Kg).
  exploitation-net-incomes
  exploitation-balance
  initial-balance
  ]

breed [cows cow] ;We consider cows as the unique type of livestock (***future-step: to include sheep or goats as other types of livestock, and producers as decision makers).

patches-own [ ; This keyword, like the globals, breed, <breed>-own, and turtles-own keywords, can only be used at the beginning of a program, before any function definitions. It defines the variables that all patches can use. All patches will then have the given variables and be able to use them.
  grass-height ;State of the grass height, determines the carrying capacity of the system.
               ;;;;;;;;;;;;; AGENTS AFFECTED: patches; PROPERTY OF THE AGENT AFFECTED: grass-height
  gh-individual

  r ;Parameter: growth rate for the grass = 0.002 1/day
    ;;;;;;;;;;;;; AGENTS AFFECTED: patches; PROPERTY OF THE AGENT AFFECTED: grass-height (r variable)
  GH-consumed ; grass-height consumed from the total consumption of dry matter

  DM-kg-ha
   ]

cows-own [ ; The turtles-own keyword, like the globals, breed, <breeds>-own, and patches-own keywords, can only be used at the beginning of a program, before any function definitions. It defines the variables belonging to each turtle. If you specify a breed instead of "turtles", only turtles of that breed have the listed variables. (More than one turtle breed may list the same variable.)
  age ;Variable that define the age of each animal (in days)
  born-calf?
  weaned-calf?
  heifer?
  steer?
  cow?
  cow-with-calf?
  pregnant?
  animal-units ;parameter used to calculate the stocking rate. Cow = 1, cow-with-calf= 1, born-calf= 0.2, weaned-calf= 0.5, steer= 0.7, heifer= 0.7.
  category-coef ;This parameter is used to obtain the DDMC. It varies according the category of the animal, is equal to 1 in all categories, except for cow-with-calf = 1.1.
                ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: ddmc (category-coef variable)
  initial-weight ;cow= 280Kg, born-calf= 40Kg, weaned-calf= 150Kg, steer= 150Kg, and heifer= 200Kg.
  min-weight ;parameter to define the critical weight which below the animal can die by forage crisis. Cow= 180 Kg, weaned-calf= 60 Kg, Steer= 100 Kg, Heifer= 100 Kg.
  live-weight ;variable that defines the state of the animals in terms of live weight.
  live-weight-gain ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: live-weight-gain

  live-weight-gain-history-season
  live-weight-gain-historyXticks-season

  live-weight-gain-history-year
  live-weight-gain-historyXticks-year


  DDMC ;Daily dry matter consumption, variable that defines the individual grass consumption (depends on LWG). *Note: 1 cm of grass/ha/92 days = 180 Kg of dry matter (Units: Kg/animal/day).
       ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: ddmc

  DM-kg-cow

  metabolic-body-size ;metabolic body size (MBS) = LW^(3/4)
                      ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: ddmc (LW^(3/4) = MBS variable)
  mortality-rate
  natural-mortality-rate ;annual natural mortality = 2% (in a day = 0.000054).
  except-mort-rate ;exceptional mortality rates increases to 15% (in a day = 0.00041) in cows, 30% (= 0.000815) in pregnant cows, and 23% (0.000625) in the rest of categories when animal Live Weight (LW) falls below a critical survival value (i.e., Minimun weight, min-weight in the code).
  pregnancy-rate ;is calculated as a logistic function of LW, but it also varies with the category of the animals.
                 ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: pregnancy-rate
  coefA ;constant used to calculate the pregnancy rate. Cow= 20000, cow-with-calf= 12000, heifer= 4000.
                 ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: pregnancy-rate (coefA variable)
  coefB ;constant used to calculate the pregnancy rate. Cow= 0.0285, cow-with-calf= 0.0265, heifer= 0.029.
        ;;;;;;;;;;;;; AGENTS AFFECTED: turtles (cows); PROPERTY OF THE AGENT AFFECTED: pregnancy-rate (coefB variable)
  pregnancy-time ; variable to determine gestation-period.
  lactating-time ; variable to determine lactating-period.
  ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setting up the environment and the variables for the agents
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  ca
  resize-world 0 (set-x-size - 1)  0 (set-y-size - 1) ; resize-world min-x-cor max-x-cor min-y-cor max-y-cor; Changes the size of the patch grid. Remember min coordinate must be 0 or less than 0
  setup-globals ; Procedure para darle valores (info) a las globals variables
  setup-grassland
  setup-livestock
  use-new-seed
  reset-ticks
end

to use-new-seed
  let my-seed new-seed            ;; generate a new seed
  output-print word "Seed: " my-seed  ;; print it out
  random-seed my-seed             ;; use the new seed
end

to setup_seed
  ca
  resize-world 0 (set-x-size - 1)  0 (set-y-size - 1) ; resize-world min-x-cor max-x-cor min-y-cor max-y-cor; Changes the size of the patch grid. Remember min coordinate must be 0 or less than 0
  setup-globals ; Procedure para darle valores (info) a las globals variables
  setup-grassland
  setup-livestock
  seed-1070152876
  reset-ticks
end

to seed-1070152876
  let my-seed 1070152876          ;; generate a new seed
  output-print word "Seed: " my-seed  ;; print it out
  random-seed my-seed            ;; use the new seed
end

to setup-globals ; Procedure para darle valores (datos) a las globals variables
  set days-per-tick 1
  set number-of-season 0
  set current-season-name ["winter" "spring" "summer" "fall"] ;this variable just converts the numbers "0, 1, 2, 3" of the seasons to text "winter, spring, summer, fall", and this variable ONLY is used in the reporter/procedure "to-report season-report"
  set simulation-time 0
  set weaned-calf-age-min 246
  set heifer-age-min 369
  set cow-age-min 737
  set cow-age-max 5520
  set gestation-period 276
  set lactation-period 184
  set weight-gain-lactation 0.61
  set ni 0.24
  set xi 132
  set grass-energy 1.8
  set DM-cm-ha 180
  set season-coef [1 1.15 1.05 1] ; al usar corchetes se crea una lista de n valores (en este caso, 4). En este caso, la lógica de crear una lista con valores distintos para la misma variable es que, como veremos más adelante, haremos que esta variable tenga un valor u otro en función del valor de otra variable (utilizando el el comando de NetLogo "item"), de manera que la variable adoptará uno de estos valores en función del valor de otra variable (en este caso, current-season, que puede adoptar 4 valores posibles: 0, 1, 2 ,3). Es decir, cuando current-season tiene valor 0 (i.e., winter) , se llama al primer valor de la lista de season-coef, que es 1 (es decir, season-coef tiene un valor de 1 en winter)
  set kmax [7.4 22.2 15.6 11.1] ; 4 valores: misma lógica que antes
  set maxLWG [40 60 40 40] ; 4 valores: misma lógica que antes
  set current-season initial-season ; initial-season is the slider in Interface (0 = winter, 1 = spring, 2 = summer, 3 = fall). The initial season is chosen by the user.
  set climacoef [1.53 1.31 1.23	1.48 1.29	0.87 0.96	1.26 1.17	0.71 0.86	1.44 1.34	0.86 1.06 1.19 0.72	0.80 0.93	0.98 0.87	1.17 1.02	0.83 0.09	1.32 0.87	1.08 1.42	0.75 1.00	0.65 0.50	1.19 1.07	0.62 0.77 1.05 1.18 1.05] ; variable con 40 valores. Esto es así porque el tiempo que vamos a simular son 10 años. Como cada año tiene 4 estaciones, y como el ClimaCoef varía cada año pues tenemos que: 10 años * 4 estaciones = 40 estaciones en total = 40 valores distintos para climaCoef (recordemos que estos 40 valores son datos históricos)
  set exploitation-costs [5.76 5.76	5.76 5.76	6.25 6.25	6.25 6.25	6.80 6.80	6.80 6.80 5.50 5.50	5.50 5.50	6.63 6.63	6.63 6.63	8.53 8.53	8.53 8.53	11.03	11.03	11.03	11.03	12.50	12.50	12.50	12.50	15.88	15.88	15.88	15.88	16.15	16.15	16.15	16.15] ; 40 valores: misma lógica que antes
  set grazing-prices [4	10 16	8	9	19 20	12 12	22 22	9	8	19 19	13 21	20 21	17 18	13 19	20 34	10 22	16 7 21	20 24	26 12	19 24	20 15	36 36] ; 40 valores: misma lógica que antes
  set supplement-prices [0.09	0.09 0.09	0.09 0.09	0.09 0.09	0.09 0.09	0.09 0.09	0.09 0.08	0.08 0.1 0.1 0.11	0.13 0.1 0.09	0.09 0.1 0.1 0.1 0.1 0.12 0.13 0.13 0.14 0.15 0.15 0.16	0.19 0.21	0.23 0.15	0.15 0.15	0.15 0.15] ; 40 valores: misma lógica que antes
  set born-calves-prices [0.74 0.8 0.84	0.88 0.87	0.71 0.69	0.7	0.66 0.63	0.66 0.76	0.74 0.8 0.86	0.83 0.86	0.98 0.99	0.99 1.02	1.02 0.94	0.98 0.91	1.06 1.13	1.17 1.26	1.3	1.36 1.33	1.31 1.74	1.2	0.94 1.03	1.03 1.03 1.03] ; 40 valores: misma lógica que antes
  set weaned-calves-prices [0.83 0.81	0.88 0.9 0.89	0.76 0.81	0.72 0.73	0.69 0.71	0.73 0.77	0.84 0.87	0.93 0.88	0.95 1 1.05	1.05 1.05	1.01 0.98	0.95 1.17 1.09 1.2 1.3 1.27	1.38 1.35	1.36 1.67	1.21 0.92	1.04 1.04	1.04 1.04] ; 40 valores: misma lógica que antes
  set steers-prices [0.68	0.72 0.76	0.8	0.79 0.65	0.63 0.64	0.6	0.57 0.6 0.69	0.67 0.73	0.78 0.75	0.79 0.89	0.9	0.9	0.93 0.93	0.86 0.89	0.82 0.97 1.02 1.06	1.15 1.18	1.23 1.21	1.19 1.59	1.09 0.85	0.94 0.94	0.94 0.94] ; 40 valores: misma lógica que antes
  set heifers-prices [0.63 0.63	0.68 0.71	0.69 0.6 0.6 0.56	0.53 0.45	0.49 0.48	0.53 0.58	0.64 0.67	0.59 0.7 0.73	0.72 0.75	0.75 0.66	0.69 0.65	0.81 0.83	0.82 0.94	0.92 1.05	0.97 0.98	1.17 0.87	0.62 0.72	0.72 0.72	0.72] ; 40 valores: misma lógica que antes
  set cows-prices [0.45	0.48 0.49	0.57 0.49	0.51 0.51	0.44 0.45	0.4	0.37 0.43	0.48 0.49	0.47 0.59	0.51 0.57	0.62 0.6 0.55	0.55 0.56	0.63 0.46	0.7	0.65 0.74	0.78 0.74	0.89 0.79	0.94 1.17	0.67 0.52	0.5	0.5	0.5	0.5] ; 40 valores: misma lógica que antes
  set pregnant-cows-prices [0.45 0.48	0.49 0.57	0.49 0.51	0.51 0.44	0.45 0.4 0.37 0.43 0.48 0.49 0.47 0.59 0.51	0.57 0.62	0.6	0.55 0.55	0.56 0.63	0.46 0.7 0.65	0.74 0.78	0.74 0.89	0.79 0.94	1.17 0.67	0.52 0.5 0.5	0.5	0.5] ; 40 valores: misma lógica que antes
  set lactating-cows-prices [0.51	0.52 0.54	0.55 0.53	0.45 0.47	0.42 0.42	0.39 0.42	0.42 0.45	0.55 0.61	0.63 0.57	0.64 0.7 0.68	0.67 0.67	0.78 0.65	0.58 0.85	0.77 0.77	0.81 0.83	0.91 0.89	0.92 1.1 0.81	0.52 0.64	0.64 0.64	0.64] ; 40 valores: misma lógica que antes
  set sheep-prices [0.47 0.52	0.47 0.48	0.51 0.49	0.54 0.46	0.49 0.49	0.56 0.51	0.59 0.76	0.92 0.81	0.82 0.96	1.05 0.84	0.81 0.77	0.68 0.59	0.45 0.46	0.56 0.57	0.48 0.64	0.8	0.92 0.94	0.88 0.98	0.98 0.98	0.98 0.98	0.98] ; 40 valores: misma lógica que antes
  set wool-prices [5.6 5.81	5.65 5.76	6.18 5.81	5.86 7.08	9.52 9.31	11.83	13.01	13.79	8.65 12.37 12.43 12.69 12.53 11.59 10.64 10.43 10.01 9.85	8.52 8.26	9	9	9.15 11.1 12.78	14.27 15.4 17.36 17.75 16.07 8.17	8.17 8.17	8.17 8.17] ; 40 valores: misma lógica que antes
end

to setup-grassland ; Procedure para darle valores (info) a los "patches-own" variables
  ask patches [
    set grass-height initial-grass-height ; initial-grass height is the slider in Interface (from a minimum of 3 cm to a maximum of 7 cm)
    set GH-consumed 0 ; establecemos que GH-consumed = 0 en el momento de empezar la simulación (i.e., tick 0 o tiempo 0)
    ifelse grass-height < 2 ; vamos a pedirles a los parches que tengan una grass-height inferior a 2 cm que se coloreen de verde claro. Esto es interesante porque lo relacionamos con la asunción de que las vacas no pueden comer pastos con altura inferior a 2 cm.
    [set pcolor 37]
    [set pcolor scale-color green grass-height 23 0]
    set r 0.002
  ]
end

to setup-livestock

create-cows initial-num-cows [ ; initial-num-cows is the slider in Interface (from 50 to 700)
    set shape "cow"
    set live-weight initial-weight-cows ; se establece que en el tiempo 0 de la simulación (cuando se pulsa setup), la variable live-weight sea igual a initial-weight
    set mortality-rate natural-mortality-rate; la variable "natural-mortality-rate" se encuentra definida en los procedures de "to-become-XXXX (cow/heifer/steer/etc)", así que ya tiene el valor dado: 0.000054 (i.e., 0.005 % diario = 2% anual)
    set DDMC 0; establecemos que el Daily dry matter consumption (DDMC) = 0 en el momento de empezar la simulación (i.e., tick 0 o tiempo 0)
    set age cow-age-min ; esta línea de código desactivada llama a la global variable "cow-age-min" que tiene un valor de 737.
    setxy random-pxcor random-pycor
    become-cow ] ; become-cow es un procedure que define la age class "cow" del ciclo de vida del cattle: le estamos diciendo que todas las vacas que se crean en el tiempo 0 de la simulación sean del age class tipo "cow"

create-cows initial-num-heifers [
    set shape "cow"
    set initial-weight initial-weight-heifer
    set live-weight initial-weight
    set mortality-rate natural-mortality-rate
    set DDMC 0
    set age heifer-age-min
    setxy random-pxcor random-pycor
    become-heifer ]

  create-cows initial-num-steers [
    set shape "cow"
    set initial-weight initial-weight-steer
    set live-weight initial-weight
    set mortality-rate natural-mortality-rate
    set DDMC 0
    set age heifer-age-min
    setxy random-pxcor random-pycor
    become-steer ]

    ask cows [
    set live-weight-gain-history-season []
    set live-weight-gain-historyXticks-season []
    set live-weight-gain-history-year []
    set live-weight-gain-historyXticks-year []
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
    if season-days >= 92 [ ; en esta primera parte se escribe el código relacionado con el cambio de estaciones.
    set number-of-season number-of-season + 1 ; to count the number of seasons in the simulation period (useful for external data of weather and market prices).
    ifelse current-season = 0 [
      set current-season 1
    ]
      [ifelse current-season = 1 [set current-season 2]
        [ifelse current-season = 2 [set current-season 3]
          [set current-season 0]
        ]
    ]

  ]

  set simulation-time simulation-time + days-per-tick

  set season-days season-days + days-per-tick
  if season-days >= 93 [set season-days 1]

  set year-days year-days + days-per-tick
  if year-days >= 369 [set year-days 1]

  ask cows [
    set live-weight-gain-history-season fput live-weight-gain live-weight-gain-history-season
    if season-days > 0 [set live-weight-gain-historyXticks-season mean (sublist live-weight-gain-history-season 0 season-days)]
    if season-days = 92 [set live-weight-gain-history-season []]
  ]

  ask cows [
    set live-weight-gain-history-year fput live-weight-gain live-weight-gain-history-year
    if year-days > 0 [set live-weight-gain-historyXticks-year mean (sublist live-weight-gain-history-year 0 year-days)]
    if year-days = 368 [set live-weight-gain-history-year []]
  ]

  if simulation-time = STOP-SIMULATION-AT[stop]

  grow-grass
  move1
  kgMS/ha/cows
  LWG_kgMS/ha/cows
  DM-consumption_kgMS/ha/cows
  grow-livestock
  reproduce
  update-grass-height_HERE

  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BIOPHYSICAL SUBMODEL (GRASS AND LIVESTOCK)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to grow-grass ; Fórmula de GH (Primary production (biomass) expressed in centimeters)
  ask patches [
    ;;;OPCION 1: NO TIENE UNA VARIABLE ESPECIFICA PARA EL TIEMPO
    ;set grass-height (grass-height + r * grass-height * (1 - grass-height / (item current-season kmax * set-climacoef))) - GH-consumed

    ;;;OPCION 1.1: NO TIENE UNA VARIABLE ESPECIFICA PARA EL TIEMPO. ES UNA FORMULA INVENTADA POR MI... POR ESO LE LLAMO "GH INVENT"
    ;set grass-height (grass-height + r * simulation-time * (1 - grass-height / (item current-season kmax * set-climacoef))) - GH-consumed

    ;,OPCION 2: VARIABLE ESPECIFICA PARA EL TIEMPO USANDO "initial-grass-height"
    ;set grass-height ((item current-season kmax / (1 + ((((item current-season kmax * set-climacoef) - (initial-grass-height)) / (initial-grass-height)) * (e ^ (- r * simulation-time))))) * set-climacoef) - GH-consumed


    ;;OPCION 3: VARIABLE ESPECIFICA PARA EL TIEMPO USANDO "grass-height"
    set grass-height ((item current-season kmax / (1 + ((((item current-season kmax * set-climacoef) - (grass-height)) / (grass-height)) * (e ^ (- r * simulation-time))))) * set-climacoef) - GH-consumed                                                                                                                                                                                ; COMENTARIO IMPORTANTE SOBRE ESTA FORMULA: se ha añadido lo siguiente: ahora, la variable "K" del denominador ahora TAMBIÉN multiplica a "climacoef". Ahora que lo pienso, así tiene más sentido... ya que la capacidad de carga (K) se verá afectada dependiendo de la variabilidad climática (antes solo se tenía en cuenta en el numerador). Ahora que recuerdo, en Dieguez-Cameroni et al. 2012, se menciona lo siguiente sobre la variable K "es una constante estacional que determina la altura máxima de la pastura, multiplicada por el coeficiente climático (coefClima) explicado anteriormente", así que parece que la modificacion nueva que he hecho tiene sentido.


    ;;OPCION 4: r = 0.0004334. CON ESTE VALOR DE r CONSIGO REPLICAR LA FIGURA 2 Y CUADRO 3 DE Dieguez-Cameroni et al. 2012. ESTOY "FORZANDO" LA FORMULA PARA QUE DEN LOS NUMEROS QUE QUIERO, POR ESO LLAMO A ESTA VERSION "GH FORZADO"
    ;set grass-height ((item current-season kmax / (1 + ((((item current-season kmax * set-climacoef) - (grass-height)) / (grass-height)) * (e ^ (- 0.0004334 * simulation-time))))) * set-climacoef) - GH-consumed


  ;if grass-height <= 0 [set grass-height 0.001] ; to avoid negative values.
  ;if grass-height <= 0 [set grass-height 1 ^ -80 ] ; to avoid negative values.
  if grass-height < 0 [set grass-height 0 ]

  ifelse grass-height < 2 [
     set pcolor 37][
     set pcolor scale-color green grass-height 23 0]
    if grass-height < 0 [set pcolor red]

    set DM-kg-ha DM-cm-ha * grass-height
  ]
end

to kgMS/ha/cows
  ask cows [set DM-kg-cow 0] ;le pedimos a las vacas que pongan la variable "DM-kg-cow" a 0

  ask patches [
   ask cows-here [
      set  DM-kg-cow DM-kg-ha / count cows-here ;luego, le pedimos a las vacas que se encuentran en el parche que calculen los kg de DM que le corresponde a cada vaca que se encuentra en el parche
    ]
  ]

  ask cows [set gh-individual ((DM-kg-cow) / DM-cm-ha )] ; los KgDM/cow los pasamos a cm/cow (cm de pasto que le corresponde a cada vaca)
end

to LWG_kgMS/ha/cows
ask cows [
  ; A continuación se encuentra la fórmula del LWG (Defines the increment of weight) LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER
  ; Primero se le dice a las vacas de todo tipo que ganen peso (LWG) en función de si es lactante (born-calf) o de si no lo es (resto de age clases, en este caso se les pide que se alimenten de la hierba siempre y cuando la altura sea mayor o igual a 2 cm):
   ifelse born-calf? = true  ; SI el agente (la vaca) se encuentra en el age class "born-calf", entonces...
      [set live-weight-gain weight-gain-lactation] ; ...entonces LWG = weight-gain-lactation. Recordemos que los born-calf no dependen de las grassland: son lactantes, así que le asumimos un weight-gain-lactation de 0.61 kg/day
      [ifelse grass-height >= 2 ;...PERO si el agente (la vaca) NO es un "born-calf" Y SI el grass-height en un patch es >= 2 (if this is TRUE), there are grass to eat and cows will gain weight using the LWG equation (i.e., LWG = fórmula que se escribe a continuación)...
         [set live-weight-gain ( item current-season maxLWG - ( xi * e ^ ( - ni * gh-individual ) ) ) / ( 92 * item current-season season-coef )] ;
         [set live-weight-gain live-weight * -0.005]] ;... PERO If the grass-height in a patch is < 2 cm (if >=2 is FALSE), the cows lose 0.5% of their live weight (LW) daily (i.e., 0.005)

  ; Segundo, se les pide que actualicen su "live-weight" en función de lo que han comido
set live-weight live-weight + live-weight-gain

set animal-units live-weight / set-1-AU ; Le pedimos a los animales que actualicen su AU

set size animal-units
  ]
end

to DM-consumption_kgMS/ha/cows
ask cows [
  set metabolic-body-size live-weight ^ (3 / 4)
  ; Tercero, se calcula la cantidad de materia seca (Dry Matter = DM) que van a consumir las vacas. Este valor se tendrá en cuenta en el próximo procedure para que los patches puedan actualizar la altura de la hierba.
; A continuación se encuentra la fórmula del DDMC (Daily Dry Matter Consumption. Defines grass consumption) LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER
    ifelse born-calf? = true  ; SI el agente (la vaca) se encuentra en el age class "born-calf", entonces DDMC = 0
       [set DDMC 0] ; ; recordemos que los born-calf no dependen de las grassland: son lactantes, así que no se alimentan de hierba
       [ifelse grass-height >= 2  ;...PERO si el agente (la vaca) NO es un "born-calf" Y si el LWG de la vaca es > 0 (if this is TRUE), DDMC = fórmula que se escribe a continuación...
         [set DDMC ((0.107 * metabolic-body-size * (- 0.0132 *  gh-individual + 1.1513) + (0.141 * metabolic-body-size * live-weight-gain) ) / grass-energy) * category-coef]
         [set DDMC 0]] ;... PERO si live-weight-gain es < 0 (if > 0 is FALSE), establece DDMC = 0 (para evitar DDMC con valores negativos)

    if DDMC < 0 [set DDMC 0] ; para evitar DDMC con valores negativos
  ]

end

to grow-livestock
ask cows [
  set age age + days-per-tick
; Primero: se codifican las reglas por las que los animales mueren.
; Es interesante mencionar que, por ahora (en el open access (antes llamado "wild model"), los animales tienen dos formas de morir: por edad (age) o por mortality rate (que puede ser natural o expecional)
  if age > cow-age-max [die] ; Si la edad (age) del agente es mayor que la edad máxima establecida (cow-age-max), el agente muere
   ifelse live-weight < min-weight ; Pero si la edad se encuentra por debajo del cow-age-max Y SI el peso vivo del animal se encuentra por debajo del peso mínimo (min-weight)...
     [set mortality-rate except-mort-rate] ; ...si esto es TRUE, el animal tendrá una mortality rate = except-mort-rate (mortality rate excepcional, recordemos que exceptional mortality rates increases to 15% (= 0.00041 a day) in cows, 30% (= 0.000815) in pregnant cows, and 23% (0.000625) in the rest of categories.)
     [set mortality-rate natural-mortality-rate] ;...si esto es FALSE, el animal tendrá una mortality rate = natural-mortality rate (annual natural mortality = 2% (in a day = 0.000054))
  if random-float 1 < mortality-rate [die] ; Como el mortality rate es una probabilidad, el animal morirá cuando el mortality rate sea mayor que un número generado al azar entre 0 y 0.999

; Segundo: después, se codifican las reglas de como evoluciona una vaca siguiendo su ciclo de vida (la regla para las etapas "born-calf", "cow-with-calf" y "pregnant" se desarrollan en el procedure "reproduce")
  if age = weaned-calf-age-min [become-weaned-calf] ; aquí se describe la regla para weaned-calf: si el age = weaned-calf-age-min, el animal pasa a la age class "weaned-calf"
  if age = heifer-age-min [ ; si el age = heifer-age-min...
    ifelse random-float 1 < 0.5 ; ...hay un 50% de probabilidades de que el animal se convierta en el age class "heifer" o "steer".
      [become-heifer] ; la regla para heifer: Si un número generado al azar entre 0 y 0.99 (random-float 1) es menor que 0.5, el animal se convertira en "heifer"
      [become-steer]] ; la regla para steer: Si el número es mayor que 0.5, se convertirá en "steer"
  if (heifer? = true) and (age >= cow-age-min) and (live-weight >= 280 ) [become-cow] ; la regla para cow: si el agente es un "heifer" (si esto es TRUE) Y el age = cow-age-min Y live-weight >= 280, el animal pasa al age class de "cow"

  if cow-with-calf? = true [set lactating-time lactating-time + days-per-tick] ; si el agente es un "cow-with-calf" (si esto es TRUE), se establece (set) que el lactating-time = lactating-time + days-per-tick
  if lactating-time = lactation-period [become-cow] ; la regla para cow: cuando el lactating-time = lactation-period, el agente del age class "cow-with-calf" se convierte en el age class "cow"
  ]
end

to reproduce ; A continuación aquí se encuentran la fórmula del Pregnancy rate y las reglas para convertirse en age class "Pregnant".  LA REDACCIÓN DE LA FÓRMULA SI COINCIDE CON LA FÓRMULA DEL PAPER PERO...
  ask cows [
  if (heifer? = true) or (cow? = true) or (cow-with-calf? = true) [set pregnancy-rate (1 / (1 + coefA * e ^ (- coefB * live-weight)))] ; ...¿¿¿¿¿¿¿¿DUDA????? LO DIVIDE ENTRE 368, POR QUÉ?
                                                                                                                                             ; POSIBLE RESPUESTA: 368 parece que hace alusión a un año (aunque un año real tiene 365 días, en esta simulacion 1 año son 368 días, ya que 1 año = 4 estaciones, y 1 estacion = 92 días. Por tanto, 92 días * 4 estaciones = 368 días), ya que se dice que la simulación dura 10 años, y en el código original de Alicia pone que 10 años = 3680 days...
                                                                                                                                             ; ...así que en definitiva, al divir la fórmula entre los días que tiene un año, se calcula el pregnancy rate diario, es decir, la probabilidad de que una vaca del age class "heifer", "cow" o "cow-with-calf" se quede preñada en un día.
  if random-float 1 < pregnancy-rate [set pregnant? true] ; Por lo tanto, si esta probabilidad diaria es mayor que un número generado al azar entre 0 y 0.99, el agente se convertirá en un agente del age class "pregnant" (i.e., el agente quedará preñado)
  if pregnant? = true [ ; Si el agente pertenece al age-class "pregnant" (si esto es TRUE)...
    set pregnancy-time pregnancy-time + days-per-tick ; ...establecemos que el tiempo de embarazo = tiempo de embarazo + days-per-tick
    set except-mort-rate 0.3] ; y establecemos que la except-mort-rate para los animales del age class "pregnant" sea 0.3.  Recordemos que la except-mort-rate para las pregnants cows es de 0.3: 30% (= 0.000815) in pregnant cows
  if pregnancy-time = gestation-period [ hatch-cows 1 [ ; Cuando la pregnancy-time = gestation-period, nace un nuevo agente del breed "cows".
                                                        ; This turtle creates X number of new turtles. Each new turtle inherits of all its variables, including its location, from its parent. (Exceptions: each new turtle will have a new who number, and it may be of a different breed than its parent if the hatch-<breeds> form is used.). The new turtles then run commands (usando los corchetes "[ ]" después de haber escrito el comando "hatch-turtles X [ ]" ). You can use the commands to give the new turtles different colors, headings, locations, or whatever. (The new turtles are created all at once, then run one at a time, in random order.)
                                                        ; If the hatch-<breeds> form is used, the new turtles are created as members of the given breed. Otherwise, the new turtles are the same breed as their parent.
    setxy random-pxcor random-pycor
    become-born-calf] ; la regla para born-calf: se le pide al nuevo agente que ha nacido que se convierta en un age class del tipo "born-calf"
    set pregnant? false ; se le dice al agente que formaba parte del age class "pregnant" que deje de serlo
    set pregnancy-time 0 ; y que reinicie el tiempo de embarazo a 0.
    become-cow-with-calf] ; la regla para cow-with-calf: este agente que acaba de dar la luz a un nuevo agente, se le pide que, además, se convierta en un agente del age class del tipo "cow-with-calf"
  ]
end

to update-grass-height_HERE
ask patches [
  set GH-consumed 0 ; el GH-consumed se actualiza en cada tick partiendo de 0.
  ask cows-here [ ; recordemos que turtles-here o <breeds>-here (i.e., cows-here) es un reporter: reports an agentset containing all the turtles on the caller's patch (including the caller itself if it's a turtle). If the name of a breed is substituted for "turtles", then only turtles of that breed are included.
                  ; este procedimiento es para actualizar la altura de la hierba en cada parche, por eso usamos "cows-here" (siendo "here" en el parche en el que se encuentran los cows)
    let totDDMC sum [DDMC] of cows-here ; creamos variable local, llamada totDDMC: Using a local variable “totDDMC” we calculate the total (total = la suma ("sum") de toda la DM consumida ("DDMC") por todas las vacas que se encuentran en ese parche) daily dry matter consumption (DDMC) in each patch.
    set GH-consumed totDDMC / DM-cm-ha  ; Actualizamos el GH-consumed: with the parameter “DM-cm-ha”, which defines that each centimeter per hectare contains 180 Kg of dry matter, we calculate the grass height consumed in each patch. Therefore, we update the grass height subtracting the grass height consumed from the current grass height.
                                        ; Una vez actualizado el GH-consumed de ese tick con la cantidad de DM que han consumido las vacas...
    ]
  ]
end

to move1
  ask cows [
   let empty-patches patches with [not any? cows-here] ;creamos variable local (empty-patches) que represente a los parches que no tienen vacas
   let target max-one-of empty-patches [grass-height] ;creamos variable local (target) que represente a los parches que no tienen vacas Y que tienen el mayor valor (max-one-of) de grass-height
    if target != nobody and [grass-height] of target > grass-height [move-to target] ;aqui decimos que [si los parches que están vacios Y que tienen el valor maximo de grass-height] (-> if target) [tienen una vaca] (-> != nobody) [Y] (-> and) [la altura maxima del target es mayor que la altura del parche en la que se encuentra la vaca (-> [grass-height] of target > grass-height), [que se mueva al target (-> [move-to target])
     ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This section of the code sets up the parameters that define each of the age classes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to become-born-calf
  set born-calf? true
  set weaned-calf? false
  set heifer? false
  set steer? false
  set cow? false
  set cow-with-calf? false
  set pregnant? false
  set color sky
  set age 0
  set initial-weight 40
  set live-weight initial-weight
  ;set animal-units 0.2
  set animal-units live-weight / set-1-AU
  ;set min-weight 0
  set min-weight set-MW-1-AU * 0.2
  ;set size 0.4
  set size animal-units
  set natural-mortality-rate 0.000054
  set except-mort-rate 0
  set category-coef 1
  set pregnancy-rate 0
  set coefA 0
  set coefB 0
  set pregnancy-time 0
  set lactating-time 0
end

to become-weaned-calf
  set born-calf? false
  set weaned-calf? true
  set heifer? false
  set steer? false
  set cow? false
  set cow-with-calf? false
  set color orange
  ;set animal-units 0.5
  set animal-units live-weight / set-1-AU
  ;set min-weight 60
  set min-weight set-MW-1-AU * 0.5
  ;set size 0.6
  set size animal-units
  set natural-mortality-rate 0.000054
  set except-mort-rate 0.23
  set category-coef 1
  set pregnancy-rate 0
  set coefA 0
  set coefB 0
  set pregnancy-time 0
  set lactating-time 0
end

to become-heifer
  set born-calf? false
  set weaned-calf? false
  set heifer? true
  set steer? false
  set cow? false
  set color pink
  ;set animal-units 0.7
  set animal-units live-weight / set-1-AU
  ;set min-weight 100
  set min-weight set-MW-1-AU * 0.7
  ;set size 0.8
  set size animal-units
  set natural-mortality-rate 0.000054
  set except-mort-rate 0.23
  set category-coef 1
  set pregnancy-rate 0
  set coefA 4000
  set coefB 0.029
  set pregnancy-time 0
  set lactating-time 0
end

to become-steer
  set born-calf? false
  set weaned-calf? false
  set heifer? false
  set steer? true
  set cow? false
  set cow-with-calf? false
  set color red
  ;set animal-units 0.7
  set animal-units live-weight / set-1-AU
  ;set min-weight 100
  set min-weight set-MW-1-AU * 0.7
  ;set size 0.9
  set size animal-units
  set natural-mortality-rate 0.000054
  set except-mort-rate 0.23
  set category-coef 1
  set pregnancy-rate 0
  set coefA 0
  set coefB 0
  set pregnancy-time 0
  set lactating-time 0
end

to become-cow
  set born-calf? false
  set weaned-calf? false
  set heifer? false
  set steer? false
  set cow? true
  set cow-with-calf? false
  set color brown
  ;set animal-units 1
  set animal-units live-weight / set-1-AU
  ;set min-weight 180
  set min-weight set-MW-1-AU
  ;set size 1
  set size animal-units
  set natural-mortality-rate 0.000054
  set except-mort-rate 0.15
  set category-coef 1
  set pregnancy-rate 0
  set coefA 20000
  set coefB 0.0285
  set pregnancy-time 0
  set lactating-time 0
end

to become-cow-with-calf
  set born-calf? false
  set weaned-calf? false
  set heifer? false
  set steer? false
  set cow? false
  set cow-with-calf? true
  set color magenta
  ;set animal-units 1
  set animal-units live-weight / set-1-AU
  ;set min-weight 180
  set min-weight set-MW-1-AU
  ;set size 1.1
  set size animal-units
  set natural-mortality-rate 0.000054
  set except-mort-rate 0.3
  set category-coef 1.1
  set pregnancy-rate 0
  set coefA 12000
  set coefB 0.0265
  set pregnancy-time 0
  set lactating-time 0
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DECISIONAL SUBMODEL (FARMER)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to sell-males ; DECISIONAL (I.E., MANAGEMENT) MODEL. POR HACER

end

to extraordinary-sales ; DECISIONAL (I.E., MANAGEMENT) MODEL. POR HACER

end

to sacrifice-animals ; DECISIONAL (I.E., MANAGEMENT) MODEL. POR HACER
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This section of the code contains the reporters that collect the model outputs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 to-report stocking-rate ; Reporter to output the relation between the stock of livestock (in terms of animal units) and the grassland area (num of patches, 1 patch = 1 ha).
  report sum [animal-units] of cows / count patches
end

to-report grass-height-report ; To report the mean grass-height of the herbage
  report mean [grass-height] of patches
end

to-report season-report ; To show the name of the season
    report  item current-season current-season-name
end

 to-report dmgr ; Reporter to output the Dry Matter Growth Rate (DMGR, units: kgDM/ha/day)
  report DM-cm-ha * sum [grass-height] of patches
end

to-report ALWG ; ALWG (Annual Live Weight Gain, kg/year/ha), o WGH (Weight Gain per Hectare, kg/ha)
  report (sum [live-weight] of cows - sum [initial-weight] of cows) / count patches
end

to-report ILWG ; ILWG (Inidividual Live Weight Gain, kg/animal/day)
  report mean [live-weight-gain] of cows
end

to-report ILWG_SEASON
  report mean [live-weight-gain-historyXticks-season] of cows; Average LWG SEASON
end

to-report ILWG_YEAR
  report mean [live-weight-gain-historyXticks-year] of cows; Average LWG YEAR
end

to-report crop-efficiency ; Reporter to output the crop eficiency (DM consumed / DM offered)
  report sum [DDMC] of cows / (DM-cm-ha * sum [grass-height] of patches) * 100
  ;report sum [DDMC] of cows / ((DM-cm-ha * DM-available-for-cattle ) * sum [grass-height] of patches) * 100


 ;let totDDMC sum [DDMC] of cows ; totDDMC = DM consumed
 ;report (totDDMC / (DM-cm-ha * sum [grass-height] of patches)) * 100 ; (DM-cm-ha * sum [grass-height] of patches) = DM offered

 ;; OTRA ALTERNATIVA PARA CALCULAR EL CROP-EFFICIENCY;;
  ;let totDDMC DM-cm-ha * sum [GH-consumed] of patches ; El "DM consumed" se puede calcular de otra manera: sumamos los cm de hierba que han perdido los patches como consecuencia de la alimentación de los animales. Como GH-consumed está en cm, lo multiplicamos por el DM-cm-ha para obtener la DM consumed (que se expresa en Kg/ha)
  ;report totDDMC / (DM-cm-ha * sum [grass-height] of patches)
 end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; References
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Dieguez-Cameroni, F.J., et al. 2014. Virtual experiments using a participatory model to explore interactions between climatic variability
;; and management decisions in extensive systems in the basaltic region of Uruguay. Agricultural Systems 130: 89–104.

;; Dieguez-Cameroni, F., Bommel, P., Corral, J., Bartaburu, D., Pereira, M., Montes, E., Duarte, E., Morales-Grosskopf, H. 2012. Modelización
;; de una explotación ganadera extensiva criadora en basalto. Agrociencia Uruguay 16(2): 120-130.

;; Robins, R., Bogen, S., Francis, A., Westhoek, A., Kanarek, A., Lenhart, S., Eda, S. 2015. Agent-based model for Johne’s disease dynamics
;; in a dairy herd. Veterinary Research 46: 68.



;OTRA INFO DE INTERES
; Para exportar los resultados de un plot, escribir en el "Command center" de la pestaña "Interfaz" lo siguiente:
; export-plot plotname filename ; por ejemplo 1: export-plot "Seasonal Accumulation DM per ha" "dm_winter.csv"
;                                     ejemplo 2: export-plot "Average of grass-height (GH)" "gh_winter.csv"
;                                     ejemplo 3: export-plot "Daily live-weight-gain (LWG)" "047_05_winter.csv"
@#$#@#$#@
GRAPHICS-WINDOW
386
61
594
170
-1
-1
20.0
1
10
1
1
1
0
1
1
1
0
9
0
4
1
1
1
ticks
30.0

BUTTON
188
113
252
146
Setup
Setup
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
325
113
380
146
Go
Go
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
8
409
159
442
initial-num-cows
initial-num-cows
0
1000
5.0
1
1
cows
HORIZONTAL

SLIDER
263
193
380
226
initial-season
initial-season
0
3
0.0
1
1
NIL
HORIZONTAL

PLOT
854
278
1181
403
Average of grass-height (GH)
Days
cm
0.0
92.0
0.0
0.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot grass-height-report"

PLOT
856
597
1184
817
Live-weight (LW)
Days
kg
0.0
92.0
0.0
0.0
true
true
"" ""
PENS
"Born-calf" 1.0 0 -13791810 true "" "plot mean [live-weight] of cows with [born-calf?]"
"Weaned-calf" 1.0 0 -955883 true "" "plot mean [live-weight] of cows with [weaned-calf?]"
"Heifer" 1.0 0 -2064490 true "" "plot mean [live-weight] of cows with [heifer?]"
"Steer" 1.0 0 -2674135 true "" "plot mean [live-weight] of cows with [steer?]"
"Cow" 1.0 0 -6459832 true "" "plot mean [live-weight] of cows with [cow?]"
"Cow-with-calf" 1.0 0 -5825686 true "" "plot mean [live-weight] of cows with [cow-with-calf?]"
"Average LW" 1.0 0 -16777216 true "" "plot mean [live-weight] of cows"

MONITOR
566
11
644
56
Time (days)
simulation-time
2
1
11

MONITOR
387
549
500
594
Stoking rate (AU/ha)
stocking-rate
4
1
11

PLOT
504
597
852
818
Cattle age classes population sizes
Days
Heads
0.0
92.0
0.0
0.0
true
true
"" ""
PENS
"Born-calf" 1.0 0 -13791810 true "" "plot count cows with [born-calf?]"
"Weaned-calf" 1.0 0 -955883 true "" "plot count cows with [weaned-calf?]"
"Heifer" 1.0 0 -2064490 true "" "plot count cows with [heifer?]"
"Steer" 1.0 0 -2674135 true "" "plot count cows with [steer?]"
"Cow" 1.0 0 -6459832 true "" "plot count cows with [cow?]"
"Cow-with-calf" 1.0 0 -5825686 true "" "plot count cows with [cow-with-calf?]"
"Total" 1.0 0 -16777216 true "" "plot count cows"

SLIDER
10
615
147
648
perception
perception
0
1
1.0
0.1
1
NIL
HORIZONTAL

MONITOR
573
549
702
594
Total number of cattle
count cows
7
1
11

MONITOR
1185
597
1341
642
Average LW (kg/animal)
mean [live-weight] of cows
3
1
11

SLIDER
5
192
146
225
initial-grass-height
initial-grass-height
1
22.2
7.0
0.1
1
cm
HORIZONTAL

CHOOSER
9
753
157
798
management-strategy
management-strategy
"reactive" "proactive"
0

PLOT
854
10
1240
267
Dry-matter (DM) and DM consumption (DDMC)
Days
kg
0.0
92.0
0.0
0.0
true
true
"" ""
PENS
"Total DM" 1.0 0 -16777216 true "" "plot dmgr"
"Total DDMC" 1.0 0 -2674135 true "" "plot sum [DDMC] of cows"

TEXTBOX
317
227
381
283
0 = winter\n1 = spring\n2 = summer\n3 = fall
11
0.0
1

MONITOR
1181
278
1307
323
Average GH (cm/ha)
grass-height-report
3
1
11

SLIDER
152
193
259
226
set-climaCoef
set-climaCoef
0.1
1.5
1.0
0.1
1
NIL
HORIZONTAL

MONITOR
385
11
472
56
Season
season-report
17
1
11

MONITOR
479
11
561
56
Time (years)
simulation-time / 368
3
1
11

SLIDER
7
324
158
357
initial-num-heifers
initial-num-heifers
0
1000
0.0
1
1
NIL
HORIZONTAL

SLIDER
7
358
158
391
initial-weight-heifer
initial-weight-heifer
100
1500
200.0
1
1
kg
HORIZONTAL

MONITOR
308
62
381
107
Area (ha)
count patches ;grassland-area, 1 patch = 1 ha\n; Other option:\n; sum [animal-units] of cows / count patches
7
1
11

PLOT
1430
594
1888
821
Daily individual-live-weight-gain (ILWG)
Days
kg
0.0
92.0
0.0
0.0
true
true
"" ""
PENS
"Born-calf" 1.0 0 -13791810 true "" "plot mean [live-weight-gain] of cows with [born-calf?]"
"Weaned-calf" 1.0 0 -955883 true "" "plot mean [live-weight-gain] of cows with [weaned-calf?]"
"Heifer" 1.0 0 -2064490 true "" "plot mean [live-weight-gain] of cows with [heifer?]"
"Steer" 1.0 0 -2674135 true "" "plot mean [live-weight-gain] of cows with [steer?]"
"Cow" 1.0 0 -6459832 true "" "plot mean [live-weight-gain] of cows with [cow?]"
"Cow-with-calf" 1.0 0 -7500403 true "" "plot mean [live-weight-gain] of cows with [cow-with-calf?]"
"Average LWG" 1.0 0 -16777216 true "" "plot mean [live-weight-gain] of cows"

PLOT
855
416
1181
558
Crop-efficiency (CE)
Days
%
0.0
92.0
0.0
60.0
true
false
"" ""
PENS
"CE" 1.0 0 -16777216 true "" "plot crop-efficiency"

MONITOR
1182
417
1238
462
CE (%)
crop-efficiency
2
1
11

MONITOR
1159
119
1308
164
Total DDMC (kg)
sum [DDMC] of cows
3
1
11

MONITOR
1307
119
1481
164
Average DDMC (kg/animal)
mean [DDMC] of cows
3
1
11

BUTTON
256
113
322
146
Go (1 day)
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
8
442
159
475
initial-weight-cows
initial-weight-cows
100
1500
380.0
1
1
kg
HORIZONTAL

PLOT
1353
228
1754
370
Body condition ccore (BCS)
Days
points
0.0
92.0
0.0
5.0
true
true
"" ""
PENS
"Born-calf" 1.0 0 -13791810 true "" "plot (mean [live-weight] of cows with [born-calf?] - (((mean [live-weight] of cows with [born-calf?]) * set-MW-1-AU) / set-1-AU)) / 40"
"Weaned-calf" 1.0 0 -955883 true "" "plot (mean [live-weight] of cows with [weaned-calf?] - (((mean [live-weight] of cows with [weaned-calf?]) * set-MW-1-AU) / set-1-AU)) / 40"
"Heifer" 1.0 0 -2064490 true "" "plot (mean [live-weight] of cows with [heifer?] - (((mean [live-weight] of cows with [heifer?]) * set-MW-1-AU) / set-1-AU)) / 40"
"Steer" 1.0 0 -2674135 true "" "plot (mean [live-weight] of cows with [steer?] - (((mean [live-weight] of cows with [steer?]) * set-MW-1-AU) / set-1-AU)) / 40"
"Cow" 1.0 0 -6459832 true "" "plot (mean [live-weight] of cows with [cow?] - (((mean [live-weight] of cows with [cow?]) * set-MW-1-AU) / set-1-AU)) / 40"
"Cow-with-calf" 1.0 0 -5825686 true "" "plot (mean [live-weight] of cows with [cow-with-calf?] - (((mean [live-weight] of cows with [cow-with-calf?]) * set-MW-1-AU) / set-1-AU)) / 40"
"Average BCS" 1.0 0 -16777216 true "" "plot (mean [live-weight] of cows - (((mean [live-weight] of cows) * set-MW-1-AU) / set-1-AU)) / 40"

MONITOR
1819
362
1950
407
Average BCS (points)
;(mean [live-weight] of cows - mean [min-weight] of cows) / 40\n(mean [live-weight] of cows - (((mean [live-weight] of cows) * set-MW-1-AU) / set-1-AU)) / 40
2
1
11

MONITOR
1754
273
1884
318
BCS of cows (points)
;(mean [live-weight] of cows with [cow?] - mean [min-weight] of cows with [cow?]) / 40\n(mean [live-weight] of cows with [cow?] - (((mean [live-weight] of cows with [cow?]) * set-MW-1-AU) / set-1-AU)) / 40
2
1
11

MONITOR
1754
318
1884
363
BCS of heifers (points)
;(mean [live-weight] of cows with [heifer?] - mean [min-weight] of cows with [heifer?]) / 40\n(mean [live-weight] of cows with [heifer?] - (((mean [live-weight] of cows with [heifer?]) * set-MW-1-AU) / set-1-AU)) / 40
2
1
11

PLOT
1347
417
1757
558
Pregnancy rate (PR)
Days
%
0.0
92.0
0.0
1.0E-4
true
true
"" ""
PENS
"Heifer" 1.0 0 -2064490 true "" "plot mean [pregnancy-rate] of cows with [heifer?] * 100"
"Cow" 1.0 0 -6459832 true "" "plot mean [pregnancy-rate] of cows with [cow?] * 100"
"Cow-with-calf" 1.0 0 -5825686 true "" "plot mean [pregnancy-rate] of cows with [cow-with-calf?] * 100"
"Average PR" 1.0 0 -16777216 true "" "plot mean [pregnancy-rate] of cows * 100"

MONITOR
1757
551
1888
596
Average PR (%)
mean [pregnancy-rate] of cows * 100
2
1
11

MONITOR
1757
462
1889
507
PR of cows (%)
mean [pregnancy-rate] of cows with [cow?] * 100
2
1
11

MONITOR
1757
418
1900
463
PR of cows-with-calf (%)
mean [pregnancy-rate] of cows with [cow-with-calf?] * 100
2
1
11

MONITOR
1757
506
1890
551
PR of heifers (%)
mean [pregnancy-rate] of cows with [heifer?] * 100
2
1
11

MONITOR
1159
75
1308
120
Total DM (kg)
dmgr
3
1
11

MONITOR
1185
641
1371
686
Average ILWG (kg/animal/day)
;mean [live-weight-gain] of cows\nILWG
3
1
11

MONITOR
1754
228
1909
273
BCS of cows-with-calf (points)
;(mean [live-weight] of cows with [cow-with-calf?] - mean [min-weight] of cows with [cow-with-calf?]) / 40\n(mean [live-weight] of cows with [cow-with-calf?] - (((mean [live-weight] of cows with [cow-with-calf?]) * set-MW-1-AU) / set-1-AU)) / 40
2
1
11

MONITOR
1883
272
2050
317
BCS of weaned-calf (points)
;(mean [live-weight] of cows with [weaned-calf?] - mean [min-weight] of cows with [weaned-calf?]) / 40\n(mean [live-weight] of cows with [weaned-calf?] - (((mean [live-weight] of cows with [weaned-calf?]) * set-MW-1-AU) / set-1-AU)) / 40
2
1
11

MONITOR
1883
317
2050
362
BCS of steer (points)
;(mean [live-weight] of cows with [steer?] - mean [min-weight] of cows with [steer?]) / 40\n(mean [live-weight] of cows with [steer?] - (((mean [live-weight] of cows with [steer?]) * set-MW-1-AU) / set-1-AU)) / 40
2
1
11

MONITOR
1909
228
2050
273
BCS of born-calf (points)
;(mean [live-weight] of cows with [born-calf?] - mean [min-weight] of cows with [born-calf?]) / 40\n(mean [live-weight] of cows with [born-calf?] - (((mean [live-weight] of cows with [born-calf?]) * set-MW-1-AU) / set-1-AU)) / 40
2
1
11

MONITOR
1184
728
1376
773
Average LW of cows (kg/animal)
mean [live-weight] of cows with [cow?]
3
1
11

MONITOR
1185
773
1414
818
Average ILWG of cows (kg/animal/day)
mean [live-weight-gain] of cows with [cow?]
3
1
11

SLIDER
7
246
158
279
initial-num-steers
initial-num-steers
0
1000
0.0
1
1
NIL
HORIZONTAL

SLIDER
7
277
158
310
initial-weight-steer
initial-weight-steer
100
1500
300.0
1
1
kg
HORIZONTAL

SLIDER
6
74
143
107
set-X-size
set-X-size
1
100
10.0
1
1
hm
HORIZONTAL

SLIDER
174
74
302
107
set-Y-size
set-Y-size
1
100
5.0
1
1
hm
HORIZONTAL

TEXTBOX
119
54
269
82
GRAZING AREA
12
0.0
1

MONITOR
504
548
570
593
Area (ha)
count patches
17
1
11

TEXTBOX
153
81
178
100
X
15
0.0
1

SLIDER
158
154
256
187
set-1-AU
set-1-AU
1
1500
385.0
1
1
kg
HORIZONTAL

SLIDER
259
154
380
187
set-MW-1-AU
set-MW-1-AU
1
1500
220.0
1
1
kg
HORIZONTAL

PLOT
299
597
500
818
Stocking rate
Days
AU/ha
0.0
92.0
0.0
0.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot stocking-rate"

MONITOR
170
325
378
370
Average ILWG (kg/animal/day)
;mean [live-weight-gain] of cows\nILWG
13
1
11

MONITOR
170
377
428
422
Average LWG since the start of the SEASON
;mean [live-weight-gain-historyXticks-season] of cows; Average LWG SEASON\nILWG_SEASON
13
1
11

MONITOR
169
492
372
537
NIL
max [count cows-here] of patches
17
1
11

OUTPUT
651
10
851
55
12

BUTTON
692
65
833
98
seed-1070152876 
setup_seed
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1184
685
1430
730
Average annual live weight gain per hectare (ALWG, kg/ha)
;(sum [live-weight] of cows with [steer?] - sum [initial-weight] of cows with [steer?]) / count patches; para calcular el WGH de los steers\n;(sum [live-weight] of cows - sum [initial-weight] of cows) / count patches\nALWG
3
1
11

MONITOR
598
110
682
155
NIL
year-days
17
1
11

MONITOR
599
61
682
106
NIL
season-days
17
1
11

MONITOR
169
426
428
471
Average LWG since the start of the YEAR
;mean [live-weight-gain-historyXticks-year] of cows; Average LWG YEAR\nILWG_YEAR
13
1
11

MONITOR
1307
75
1481
120
Total DM per ha (kg/ha)
;(DM-cm-ha * mean [grass-height] of patches) / DM-available-for-cattle\n(dmgr) / count patches
3
1
11

MONITOR
1480
75
1657
120
Total DM G. Rate (kg/ha/day)
;((DM-cm-ha * mean [grass-height] of patches) / DM-available-for-cattle) / 92\n(dmgr / count patches) / 92
3
1
11

MONITOR
432
288
522
333
ALWG (kg/ha)
;(sum [live-weight] of cows with [steer?] - sum [initial-weight] of cows with [steer?]) / count patches; para calcular el WGH de los steers\n;(sum [live-weight] of cows - sum [initial-weight] of cows) / count patches\nALWG
3
1
11

MONITOR
600
200
717
245
BCS of cows (points)
;(mean [live-weight] of cows with [cow?] - mean [min-weight] of cows with [cow?]) / 40\n(mean [live-weight] of cows with [cow?] - (((mean [live-weight] of cows with [cow?]) * set-MW-1-AU) / set-1-AU)) / 40
2
1
11

MONITOR
600
246
704
291
PR of cows (%)
;mean [pregnancy-rate] of cows with [cow?] * 368 * 100\nmean [pregnancy-rate] of cows with [cow?] * 100
2
1
11

SLIDER
5
112
184
145
STOP-SIMULATION-AT
STOP-SIMULATION-AT
0
7360
0.0
1
1
days
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="SA_sliders" repetitions="3" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>mean [live-weight] of cows</metric>
    <enumeratedValueSet variable="climacoef">
      <value value="0.5"/>
      <value value="1"/>
      <value value="1.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-grass-height" first="3" step="1" last="7"/>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-num-cows" first="1" step="1" last="14"/>
    <steppedValueSet variable="perception" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="SA_climacoef" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>mean [live-weight] of cows</metric>
    <enumeratedValueSet variable="climacoef">
      <value value="0.5"/>
      <value value="1"/>
      <value value="1.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_initial-grass-height" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>mean [live-weight] of cows</metric>
    <steppedValueSet variable="initial-grass-height" first="3" step="1" last="7"/>
  </experiment>
  <experiment name="SA_initial-season" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>mean [live-weight] of cows</metric>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_initial-num-cows" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>mean [live-weight] of cows</metric>
    <steppedValueSet variable="initial-num-cows" first="1" step="1" last="14"/>
  </experiment>
  <experiment name="SA_perception" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>mean [live-weight] of cows</metric>
    <steppedValueSet variable="perception" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="Fig5" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="368"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>ALWG</metric>
    <metric>ILWG_YEAR</metric>
    <enumeratedValueSet variable="DM-cm-ha?">
      <value value="&quot;180&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DM-available-for-cattle">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-version">
      <value value="&quot;open access&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steer">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifer">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="management-strategy">
      <value value="&quot;reactive&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-num-steers" first="0" step="2" last="100"/>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="changing-seasons?">
      <value value="&quot;yes&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="set-climaCoef" first="0.5" step="0.25" last="1.5"/>
  </experiment>
  <experiment name="Fig4" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="92"/>
    <metric>set-climaCoef</metric>
    <metric>season-report</metric>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>ILWG_SEASON</metric>
    <enumeratedValueSet variable="DM-cm-ha?">
      <value value="&quot;180&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DM-available-for-cattle">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-version">
      <value value="&quot;open access&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steer">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifer">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="management-strategy">
      <value value="&quot;reactive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="30"/>
      <value value="45"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="3"/>
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="changing-seasons?">
      <value value="&quot;yes&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-climaCoef">
      <value value="0.5"/>
      <value value="1"/>
      <value value="1.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Fig6" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="368"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>crop-efficiency</metric>
    <enumeratedValueSet variable="DM-cm-ha?">
      <value value="&quot;180&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DM-available-for-cattle">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-version">
      <value value="&quot;open access&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steer">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifer">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="management-strategy">
      <value value="&quot;reactive&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-num-steers" first="0" step="2" last="100"/>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="changing-seasons?">
      <value value="&quot;yes&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-climaCoef">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Fig2" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="92"/>
    <metric>simulation-time</metric>
    <metric>season-report</metric>
    <metric>dmgr / count patches ;DM/ha</metric>
    <enumeratedValueSet variable="DM-cm-ha?">
      <value value="&quot;180&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DM-available-for-cattle">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-version">
      <value value="&quot;grass model&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steer">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifer">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="management-strategy">
      <value value="&quot;reactive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="340"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="changing-seasons?">
      <value value="&quot;yes&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-climaCoef">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Fig3" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="92"/>
    <metric>initial-grass-height</metric>
    <metric>set-climaCoef</metric>
    <metric>season-report</metric>
    <metric>dmgr / count patches ;DM/ha</metric>
    <enumeratedValueSet variable="DM-cm-ha?">
      <value value="&quot;180&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DM-available-for-cattle">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-version">
      <value value="&quot;grass model&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steer">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifer">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="3"/>
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="management-strategy">
      <value value="&quot;reactive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="340"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="changing-seasons?">
      <value value="&quot;yes&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-climaCoef">
      <value value="0.5"/>
      <value value="1"/>
      <value value="1.5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
