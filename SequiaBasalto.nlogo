;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; ADAPTATION OF SEQUIA-BASALTO MODEL TO NETLOGO ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The original model was built in CORMAS, for more information about the original model see Dieguez-Cameroni et al. (2012, 2014)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declaration of agents and variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals [
;; Climate related global variables
  climacoef                                                             ;; climacoef relates the primary production in a season with the average for that season due to climate variations
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
  lactation-period                                                      ;; determines the lactating period of cows with calves: 246 days
  weight-gain-lactation                                                 ;; affects the live weight gain of lactating animals (i.e., “born-calf” age class): 0.61 Kg/day
  ]

breed [cows cow]

patches-own [
  grass-height                                                          ;; primary production (biomass), expressed in centimeters
  gh-individual                                                         ;; grass height consumed per cow
  r                                                                     ;; growth rate for the grass = 0.02 1/day
  GH-consumed                                                           ;; grass-height consumed from the total consumption of dry matter
  DM-kg-ha                                                              ;; primary production (biomass), expressed in kg of Dry Matter (DM)
   ]

cows-own [
  age                                                                   ;; defines the age of each animal (in days)
  born-calf?                                                            ;; boolean variable that determines the "born-calf" age class of the livestock life cycle
  weaned-calf?                                                          ;; boolean variable that determines the "weaned-calf" age class of the livestock life cycle
  heifer?                                                               ;; boolean variable that determines the "heifer" age class of the livestock life cycle
  steer?                                                                ;; boolean variable that determines the "steer" age class of the livestock life cycle
  cow?                                                                  ;; boolean variable that determines the "cow" age class of the livestock life cycle
  cow-with-calf?                                                        ;; boolean variable that determines the "cow-withcalf" age class of the livestock life cycle
  pregnant?                                                             ;; boolean variable that determines the "pregnant" age class of the livestock life cycle
  animal-units                                                          ;; variable used to calculate the stocking rate. AU = LW / 380
  category-coef                                                         ;; coefficient that varies with age class and affects the grass consumption of animals. Equal to 1 in all age classes, except for cow-with-calf = 1.1
  initial-weight                                                        ;; initial weight of the animal at the beginning of the simulation
  min-weight                                                            ;; defines the critical weight which below the animal can die by forage crisis
  live-weight                                                           ;; variable that defines the state of the animals in terms of live weight
  live-weight-gain                                                      ;; defines the increment of weight.
  live-weight-gain-history-season
  live-weight-gain-historyXticks-season                                 ;; live weight gain since start of season
  live-weight-gain-history-year
  live-weight-gain-historyXticks-year                                   ;; live weight gain since start of year
  DM-kg-cow                                                             ;; biomass available (not consumed!) for one cow
  DDMC                                                                  ;; Daily Dry Matter Consumption. Is the biomass consumed by one cow
  metabolic-body-size                                                   ;; Metabolic Body Size (MBS) = LW^(3/4)
  mortality-rate                                                        ;; mortality rate can be natural or exceptional
  natural-mortality-rate                                                ;; annual natural mortality = 2%
  except-mort-rate                                                      ;; exceptional mortality rates increases to 15% in cows, 30% in pregnant cows, and 23% in the rest of age classes when animal LW falls below the minimum weight
  pregnancy-rate                                                        ;; probability that a heifer/cow/cow-with-calf will become pregnant
  coefA                                                                 ;; constant used to calculate the pregnancy rate. Cow= 20000, cow-with-calf= 12000, heifer= 4000.
  coefB                                                                 ;; constant used to calculate the pregnancy rate. Cow= 0.0285, cow-with-calf= 0.0265, heifer= 0.029.
  pregnancy-time                                                        ;; determines the gestation period of pregnant cows.
  lactating-time                                                        ;; determines the lactating period of cows with calves.
   ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setting up the environment and the variables for the agents
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  ca
  resize-world 0 (set-x-size - 1)  0 (set-y-size - 1)                   ;; changes the size of the world, set by the observer in the interface
  setup-globals
  setup-grassland
  setup-livestock
  reset-ticks
end

to setup-globals
  set days-per-tick 1
  set number-of-season 0
  set current-season-name ["winter" "spring" "summer" "fall"]
  set simulation-time 0
  set weaned-calf-age-min 246
  set heifer-age-min 369
  set cow-age-min 737
  set cow-age-max 5520
  set gestation-period 276
  set lactation-period 246
  set weight-gain-lactation 0.61
  set ni 0.24
  set xi 132
  set grass-energy 1.8
  set DM-cm-ha 180
  set season-coef [1 1.15 1.05 1]
  set kmax [7.4 22.2 15.6 11.1]
  set maxLWG [40 60 40 40]
  set current-season initial-season                                     ;; the initial season is set by the observer in the interface

end

to setup-grassland
  ask patches [
    set grass-height initial-grass-height                               ;; the initial grass height is set by the observer in the interface
    set GH-consumed 0
    ifelse grass-height < 2                                             ;; patches with grass height less than 2 cm are colored light green. This is based on the assumption that cows cannot eat grass less than 2 cm high
    [set pcolor 37]
    [set pcolor scale-color green grass-height 23 0]
    set r 0.02
  ]
end

to setup-livestock
  create-cows initial-num-cows [
    set shape "cow"
    set live-weight initial-weight-cows                                 ;; the initial weight is set by the observer in the interface
    set initial-weight initial-weight-cows
    set mortality-rate natural-mortality-rate
    set DDMC 0
    ;set age cow-age-min
    set age random (cow-age-max - cow-age-min) + cow-age-min
    setxy random-pxcor random-pycor
    become-cow ]

    ask cows [
    set live-weight-gain-history-season []
    set live-weight-gain-historyXticks-season []
    set live-weight-gain-history-year []
    set live-weight-gain-historyXticks-year []
  ]
  end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go

  set climacoef set-climacoef                                           ;; the climacoef is set by the observer in the interface

  if season-days >= 92 [set number-of-season number-of-season + 1       ;; the season change and duration is determined in this line
    ifelse current-season = 0
    [set current-season 1]
    [ifelse current-season = 1
      [set current-season 2]
      [ifelse current-season = 2
        [set current-season 3]
        [set current-season 0]
        ]
    ]
  ]

  set simulation-time simulation-time + days-per-tick

  set season-days season-days + days-per-tick
  if season-days >= 93 [set season-days 1]                              ;; this restart important to make sure that the "live-weight-gain-history-season" variable works, which is used in the "ILWG_SEASON" report

  set year-days year-days + days-per-tick
  if year-days >= 369 [set year-days 1]                                 ;; this restart important to make sure that the "live-weight-gain-history-year" variable works, which is used in the "ILWG_YEAR" report

  ask cows [                                                            ;; in this line, the average live weight gain of the cows during the season (from day 1 to day 92 and in between) is calculated
    set live-weight-gain-history-season fput live-weight-gain live-weight-gain-history-season
    if season-days > 0 [set live-weight-gain-historyXticks-season mean (sublist live-weight-gain-history-season 0 season-days)]
    if season-days = 92 [set live-weight-gain-history-season []]
  ]

  ask cows [                                                            ;; in this line, the average live weight gain of the cows during the year (from day 1 to day 368 and in between) is calculated
    set live-weight-gain-history-year fput live-weight-gain live-weight-gain-history-year
    if year-days > 0 [set live-weight-gain-historyXticks-year mean (sublist live-weight-gain-history-year 0 year-days)]
    if year-days = 368 [set live-weight-gain-history-year []]
  ]

  if simulation-time / 368 = STOP-SIMULATION-AT [stop]                  ;; the observer can decide whether the simulation should run indefinitely (STOP-SIMULATION-AT 0 years) or after X years

  grow-grass
  move
  kgDM/cow
  LWG
  DM-consumption
  grow-livestock
  reproduce
  update-grass-height

  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BIOPHYSICAL SUBMODEL (GRASS AND LIVESTOCK)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to grow-grass                                                           ;; each patch calculates the height of its grass following a logistic regression. Grass height is affected by season, climacoef (set by the observer in the interface) and consumption of grass by animals (GH consumed is the grass consumed by cows on the previous tick)
  ask patches [
    set grass-height (grass-height + r * grass-height * (1 - grass-height / (item current-season kmax * climacoef))) - GH-consumed
    if grass-height < 0 [set grass-height 0 ]

    ifelse grass-height < 2                                             ;; patches with grass height less than 2 cm are colored light green. This is based on the assumption that cows cannot eat grass less than 2 cm high
    [set pcolor 37]
    [set pcolor scale-color green grass-height 23 0]

    set DM-kg-ha DM-cm-ha * grass-height                                ;; converting cm of grass in each patch into kg of Dry Matter (DM)
  ]
end

to move                                                                 ;; once the grass height of each patch is updated, cows move to the patch with fewer cows and the highest grass height
  ask cows [
    let empty-patches patches with [not any? cows-here]
    let target max-one-of empty-patches [grass-height]
    if target != nobody and [grass-height] of target > grass-height [move-to target]
     ]
end

to kgDM/cow                                                             ;; after the cows have moved to a new patch, each cow calculates the amount of Kg of DM it will receive.
  ask cows [set DM-kg-cow 0]

  ask patches [
   ask cows-here [set DM-kg-cow DM-kg-ha / count cows-here]
  ]

   ask cows [set gh-individual ((DM-kg-cow) / DM-cm-ha )]               ;; for its use in the following procedures, this amount of DM (kg) is converted back to grass height (cm) (important: this is not the grass height the animal consumes!!)
end

to LWG                                                                  ;; the live weight gain of each cow is calculated according to the number of centimeters of grass that correspond to each animal
ask cows [
   ifelse born-calf? = true
    [set live-weight-gain weight-gain-lactation]
    [ifelse grass-height >= 2                                           ;; cows cannot eat grass less than 2 cm high
      [set live-weight-gain ( item current-season maxLWG - ( xi * e ^ ( - ni * gh-individual ) ) ) / ( 92 * item current-season season-coef )]
      [set live-weight-gain live-weight * -0.005]]

    set live-weight live-weight + live-weight-gain
    if live-weight < 0 [set live-weight 0]

    set animal-units live-weight / 380
  ]
end

to DM-consumption                                                       ;; the DDMC consumed by each cow (in kg) is calculated in this procedure
ask cows [
  set metabolic-body-size live-weight ^ (3 / 4)
    ifelse born-calf? = true
       [set DDMC 0]
       [ifelse grass-height >= 2
         [set DDMC ((0.107 * metabolic-body-size * (- 0.0132 *  gh-individual + 1.5132) + (0.141 * metabolic-body-size * live-weight-gain) ) / grass-energy) * category-coef]
         [set DDMC 0]]
    if DDMC < 0 [set DDMC 0]
  ]
end

to grow-livestock                                                       ;; this procedure dictates the rules for the death or progression of animals to the next age class, as well as the lactating time of animals
ask cows [
  set age age + days-per-tick
  if age > cow-age-max [die]
   ifelse live-weight < min-weight
    [set mortality-rate except-mort-rate]
    [set mortality-rate natural-mortality-rate]
    if random-float 1 < mortality-rate [die]

  if age = weaned-calf-age-min [become-weaned-calf]

  if age = heifer-age-min [
    ifelse random-float 1 < 0.5
      [become-heifer]
      [become-steer]]

  if (heifer? = true) and (age >= cow-age-min) and (live-weight >= 280 ) [become-cow]

  if cow-with-calf? = true [set lactating-time lactating-time + days-per-tick]

  if lactating-time = lactation-period [become-cow]
  ]
end

to reproduce                                                            ;; this procedure dictates the rules for which each of the reproductive age classes (i.e., heifer, cow, cow-with-calf) can become pregnant, as well as the gestation period of animals
  ask cows [
    if (heifer? = true) or (cow? = true) or (cow-with-calf? = true) [set pregnancy-rate (1 / (1 + coefA * e ^ (- coefB * live-weight))) / 368]
    if random-float 1 < pregnancy-rate [set pregnant? true]
    if pregnant? = true [
      set pregnancy-time pregnancy-time + days-per-tick
      set except-mort-rate 0.3]

    if pregnancy-time = gestation-period [
      hatch-cows 1 [
        setxy random-pxcor random-pycor
        become-born-calf]
    set pregnant? false
    set pregnancy-time 0
    become-cow-with-calf]
  ]
end

to update-grass-height                                                  ;; the DDMC of all cows (total DDMC, in kg) in each patch is calculated and converted back to grass height (cm) to calculate the grass height consumed in each patch (GH-consumed)
ask patches [
    set GH-consumed 0
    ask cows-here [
      let totDDMC sum [DDMC] of cows-here
      set GH-consumed totDDMC / DM-cm-ha]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This section of the code sets up the parameters that define each of the age classes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
  set animal-units live-weight / 380
  set size 0.3
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
  set animal-units live-weight / 380
  set min-weight 60
  set size 0.5
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
  set animal-units live-weight / 380
  set min-weight 100
  set size 0.7
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
  set animal-units live-weight / 380
  set min-weight 100
  set size 0.7
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
  set animal-units live-weight / 380
  set min-weight 180
  set size 1
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
  set animal-units live-weight / 380
  set min-weight 180
  set size 1.1
  set natural-mortality-rate 0.000054
  set except-mort-rate 0.3
  set category-coef 1.1
  set pregnancy-rate 0
  set coefA 12000
  set coefB 0.0265
  set pregnancy-time 0
  set lactating-time 0
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This section of the code contains the reporters that collect the model outputs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report stocking-rate                                                 ;; outputs the relation between the number of livestock (in terms of animal units) and the grassland area (num. of patches. 1 patch = 1 ha)
  report sum [animal-units] of cows / count patches
end

to-report grass-height-report                                           ;; outputs the mean grass-height of the grassland
  report mean [grass-height] of patches
end

to-report season-report                                                 ;; outputs the name of the season
    report  item current-season current-season-name
end

 to-report dmgr                                                         ;; outputs the Dry Matter Growth Rate (DMGR, units: kgDM/ha/day)
  report DM-cm-ha * sum [grass-height] of patches
end

to-report ALWG                                                          ;; outputs the Annual Live Weight Gain per hectare (kg/year/ha)
  report (sum [live-weight] of cows - sum [initial-weight] of cows) / count patches
end

to-report ILWG                                                          ;; outputs the mean Inidividual Live Weight Gain (kg/animal)
  report mean [live-weight-gain] of cows
end

to-report ILWG_SEASON                                                   ;; outputs the mean IWLG throughout the season
  report mean [live-weight-gain-historyXticks-season] of cows
end

to-report ILWG_YEAR                                                     ;; outputs the mean IWLG throughout the year
  report mean [live-weight-gain-historyXticks-year] of cows
end

to-report crop-efficiency                                               ;; outputs the crop eficiency (DM consumed / DM offered)
  report sum [DDMC] of cows / (DM-cm-ha * mean [grass-height] of patches) * 100
 end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; References
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dieguez-Cameroni, F.J., et al. 2014. Virtual experiments using a participatory model to explore interactions between climatic variability and management decisions in extensive systems in the basaltic region of Uruguay. Agricultural Systems 130: 89–104.
;; Dieguez-Cameroni, F., Bommel, P., Corral, J., Bartaburu, D., Pereira, M., Montes, E., Duarte, E., Morales-Grosskopf, H. 2012. Modelización de una explotación ganadera extensiva criadora en basalto. Agrociencia Uruguay 16(2): 120-130.
@#$#@#$#@
GRAPHICS-WINDOW
435
61
981
608
-1
-1
53.8
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
9
1
1
1
ticks
30.0

BUTTON
7
10
71
43
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
174
11
250
44
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
11
276
166
309
initial-num-cows
initial-num-cows
0
1000
50.0
1
1
cows
HORIZONTAL

SLIDER
201
132
337
165
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
993
249
1389
482
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
993
554
1405
787
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
660
10
732
55
Time (days)
simulation-time
2
1
11

MONITOR
736
10
849
55
Stoking rate (AU/ha)
stocking-rate
4
1
11

PLOT
636
613
984
834
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

MONITOR
854
10
979
55
Total number of cattle
count cows
7
1
11

SLIDER
12
202
154
235
initial-grass-height
initial-grass-height
1
22.2
7.4
0.1
1
cm
HORIZONTAL

PLOT
991
10
1387
243
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
348
136
412
194
0 = winter\n1 = spring\n2 = summer\n3 = fall
11
0.0
1

MONITOR
1389
249
1535
294
Average GH (cm)
grass-height-report
2
1
11

SLIDER
201
168
337
201
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
503
10
578
55
Season
season-report
17
1
11

MONITOR
581
10
657
55
Time (years)
simulation-time / 368
3
1
11

MONITOR
433
10
500
55
Area (ha)
count patches
7
1
11

MONITOR
1387
53
1533
98
Total DDMC (kg)
sum [DDMC] of cows
2
1
11

BUTTON
75
10
170
43
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
10
312
166
345
initial-weight-cows
initial-weight-cows
100
1500
380.0
1
1
kg
HORIZONTAL

MONITOR
1406
643
1660
688
Body Condition Score (BCS) of adult cows (points)
(mean [live-weight] of cows with [cow?] - 220) / 40
2
1
11

MONITOR
1406
690
1660
735
Pregnancy Rate (PR) of adult cows (%)
mean [pregnancy-rate] of cows with [cow?] * 100
2
1
11

MONITOR
1387
10
1533
55
Total DM (kg)
dmgr
2
1
11

MONITOR
1172
508
1405
553
Average LW Gain (LWG) of cattle (kg/animal)
mean [live-weight-gain] of cows
2
1
11

SLIDER
12
130
154
163
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
12
165
154
198
set-Y-size
set-Y-size
1
100
10.0
1
1
hm
HORIZONTAL

TEXTBOX
13
110
183
140
GRAZING AREA AND GRASS
12
0.0
1

PLOT
435
613
636
834
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

SLIDER
256
11
428
44
STOP-SIMULATION-AT
STOP-SIMULATION-AT
0
100
0.0
1
1
years
HORIZONTAL

BUTTON
75
44
170
77
Go (1 season)
go\nif season-days = 92 [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1387
96
1533
141
Crop Efficiency (%)
crop-efficiency
2
1
11

MONITOR
992
508
1171
553
Average LW of cattle (kg/animal)
mean [live-weight] of cows
2
1
11

MONITOR
1533
10
1687
55
Total DM per ha (kg/ha)
dmgr / count patches
2
1
11

MONITOR
1533
54
1687
99
Average DDMC (kg/animal)
mean [DDMC] of cows
2
1
11

MONITOR
1406
554
1660
599
Average LW of adult cows (kg/animal)
mean [live-weight] of cows with [cow?]
2
1
11

MONITOR
1406
598
1660
643
Average LWG of adult cows (kg/animal)
mean [live-weight-gain] of cows with [cow?]
2
1
11

TEXTBOX
202
113
352
131
SEASONS AND CLIMATE
12
0.0
1

TEXTBOX
12
257
162
275
LIVESTOCK NUMBERS
12
0.0
1

MONITOR
1665
554
1912
599
Average LW of adult cows-with-calf (kg/animal)
mean [live-weight] of cows with [cow-with-calf?]
2
1
11

MONITOR
1665
600
1913
645
Average LWG of adult cows-with-calf (kg/animal)
mean [live-weight-gain] of cows with [cow-with-calf?]
2
1
11

MONITOR
1665
645
1913
690
BCS of adult cows-with-calf (points)
(mean [live-weight] of cows with [cow-with-calf?] - 220) / 40
2
1
11

MONITOR
1665
691
1913
736
PR of adult cows-with-calf (%)
mean [pregnancy-rate] of cows with [cow-with-calf?] * 100
2
1
11

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
  <experiment name="Fig5" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="368"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>ALWG</metric>
    <metric>ILWG_YEAR</metric>
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
    <enumeratedValueSet variable="perception">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-num-steers" first="0" step="2" last="100"/>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <steppedValueSet variable="set-climaCoef" first="0.5" step="0.5" last="1.5"/>
  </experiment>
  <experiment name="Fig4" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="92"/>
    <metric>set-climaCoef</metric>
    <metric>season-report</metric>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>ILWG_SEASON</metric>
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
    <enumeratedValueSet variable="perception">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
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
    <enumeratedValueSet variable="set-climaCoef">
      <value value="0.5"/>
      <value value="1"/>
      <value value="1.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Fig2" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="92"/>
    <metric>simulation-time</metric>
    <metric>season-report</metric>
    <metric>dmgr / count patches ;DM/ha</metric>
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
    <enumeratedValueSet variable="perception">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="3"/>
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
    <enumeratedValueSet variable="perception">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="3"/>
      <value value="7"/>
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
    <enumeratedValueSet variable="set-climaCoef">
      <value value="0.5"/>
      <value value="1"/>
      <value value="1.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Fig6" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="92"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>crop-efficiency</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
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
    <enumeratedValueSet variable="perception">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="management-strategy">
      <value value="&quot;reactive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-num-steers" first="0" step="2" last="150"/>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-climaCoef">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Fig8" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="644"/>
    <metric>grass-height-report</metric>
    <metric>season-report</metric>
    <metric>climacoef</metric>
    <metric>ILWG ; all cows</metric>
    <metric>ILWG_ADULTCOWS; ILWG only adult cows (cows and cows-with-calf)</metric>
    <metric>stocking-rate</metric>
    <metric>stocking-rate_ADULTCOWS ; cows with [cow?] and cows with [cow-with-calf?]</metric>
    <metric>count cows</metric>
    <metric>count cows with [cow?] + count cows with [cow-with-calf?]</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="300"/>
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-value?">
      <value value="&quot;historic-climacoef&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="management-strategy">
      <value value="&quot;reactive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="644"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-climaCoef">
      <value value="1"/>
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
