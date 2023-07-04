;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; SOSLIVESTOCK MODEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; This model is based on the SequiaBasalto model developed by Dieguez Cameroni et al. (2012, 2014)
;; Some aspects of the model related with the growth of livestock and the transition through different age classes are based on Robins et al. (2015)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DECLARATION OF GLOBAL VARIABLES AND AGENT VARIABLES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals [
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Climate related global variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  current-season                                                                    ;; define the season in which the simulation begins: 0 = winter, 1 = spring, 2 = summer, 3 = fall
  current-season-name                                                               ;; translates the numbers "0, 1, 2, 3" to "winter, spring, summer, fall"
  season-coef                                                                       ;; affects the live weight gain of animals in relation with the grass quality according to the season: winter = 1, spring = 1.15, summer = 1.05, fall = 1
  climacoef                                                                         ;; climacoef relates the primary production in a season with the average for that season due to climate variations. Takes values from 0.1 to 1.5, and is set by the observer in the interface
  historic-climacoef                                                                ;; in case the observer wants to use historical values for climacoef. For the model to use "historic-climacoef" values, the observer must select the "historic-climacoef" option within the "climacoef-distribution" chooser in the interface.
  test-climacoef                                                                    ;;### THIS IS FOR TEST PURPOSES. IT WILL BE DELETED IN THE FINAL VERSION

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Time related global variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  days-per-tick                                                                     ;; simulate time
  number-of-season                                                                  ;; keep track of the number of seasons that have passed since the start of the simulation
  simulation-time                                                                   ;; keep track of the days of the simulation
  season-days                                                                       ;; keep track of the days that have passed since the start of the season
  year-days                                                                         ;; keep track of the days that have passed since the start of a year (values from 1 to 368)
  season-length                                                                     ;; determines season length (from 1 to 368). Set by the observer in the interface

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Grass related global variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  kmax                                                                              ;; maximum carrying capacity (maximum grass height), it varies according to the season: winter= 7.4 cm, spring= 22.2 cm, summer= 15.6 cm, fall= 11.1 cm
  DM-cm-ha                                                                          ;; quantity of dry matter contained in one centimeter per hectare. Set by the observer in the interface
  grass-energy                                                                      ;; metabolizable energy per Kg of dry matter: 1.8 Mcal/Kg of DM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Livestock related global variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  maxLWG                                                                            ;; defines the maximum live weight gain per animal according to the season: spring = 60 Kg/animal; winter, summer and fall = 40 Kg/animal.
  ni                                                                                ;; defines the live weight gain per animal: 0.24 1/cm
  xi                                                                                ;; defines the live weight gain per animal: 132 kg
  weaned-calf-age-min                                                               ;; beginning of the “weaned-calf” age class of the livestock life cycle: 246 days
  heifer-age-min                                                                    ;; beginning of the “heifer” (for female calves) or “steer” (for male calves) age class of the livestock life cycle: 369 days
  cow-age-min                                                                       ;; beginning of the “cow” age class for heifers: 737 days
  cow-age-max                                                                       ;; life expectancy of cattle: 5520 days
  gestation-period                                                                  ;; gestation period of pregnant cows: 276 days
  lactation-period                                                                  ;; lactating period of cows with calves: 246 days
  weight-gain-lactation                                                             ;; affects the live weight gain of lactating animals (i.e., “born-calf” age class): 0.61 Kg/day

  ticks-since-here                                                                  ;; for rotational grazing strategies only, it measures the number of days since the animals were moved to a new paddock. This variable is important to prevent animals from continuously moving from one paddock to another once they have met the criteria to move to the next paddock. Once animals have met the criteria, they will move to the next paddock and wait X days (defined by the RG-days-in-paddock slider in the interface) to acclimate to the new paddock. Once those days have passed, if the animals still meet the criteria to move between paddocks, they will move.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Market prices & economic balance global variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  supplement-prices                                                                 ;;## SALES MODULE ;; costs for feeding the animals with food supplements (grains, USD/head/season).
  born-calf-prices                                                                  ;;## SALES MODULE ;; market prices per kg for born calves (USD/Kg).
  weaned-calf-prices                                                                ;;## SALES MODULE ;; market prices per kg for weaned calves (USD/Kg).
  steer-prices                                                                      ;;## SALES MODULE ;; market prices per kg for steers (USD/Kg).
  heifer-prices                                                                     ;;## SALES MODULE ;; market prices per kg for empty heifers (USD/Kg).
  cow-prices                                                                        ;;## SALES MODULE ;; market prices per kg for empty cows (USD/Kg).
  cow-with-calf-prices                                                              ;;## SALES MODULE ;; market prices per kg for lactating cows (USD/Kg).
  pregnant-prices                                                                   ;;## SALES MODULE ;; market prices per kg for pregnant cows (USD/Kg).

  OS-males-weaned-calf                                                              ;;## ORDINARY SALES MODULE ;; income from the sale of male weaned calves during ordinary sales.
  OS-males-steer                                                                    ;;## ORDINARY SALES MODULE ;; income from the sale of steers during ordinary sales.
  OS-old-cow                                                                        ;;## ORDINARY SALES MODULE ;; income from the sale of old cows during ordinary sales.
  OS-heifer                                                                         ;;## ORDINARY SALES MODULE ;; income from the sale of heifers during ordinary sales.
  OS-cow                                                                            ;;## ORDINARY SALES MODULE ;; income from the sale of cows during ordinary sales.

  ES-males-weaned-calf                                                              ;;## EXTRAORDINARY SALES MODULE ;; income from the sale of male weaned calves during extraordinary sales.
  ES-males-steer                                                                    ;;## EXTRAORDINARY SALES MODULE ;; income from the sale of steers during extraordinary sales.
  ES-old-cow                                                                        ;;## EXTRAORDINARY SALES MODULE ;; income from the sale of old cows during extraordinary sales.
  ES-heifer                                                                         ;;## EXTRAORDINARY SALES MODULE ;; income from the sale of heifers during extraordinary sales.
  ES-cow                                                                            ;;## EXTRAORDINARY SALES MODULE ;; income from the sale of empty cows during extraordinary sales.


  ordinary-sales-income                                                             ;;## ORDINARY SALES MODULE ;; total income from ordinary sales
  extraordinary-sales-income                                                        ;;## EXTRAORDINARY SALES MODULE ;; total income from extraordinary sales

  cost                                                                              ;;## SALES MODULE ;; regular costs resulting from the various management activities.
  income                                                                            ;;## SALES MODULE ;; total income (ordinary + extraordinary sales)
  balance                                                                           ;;## SALES MODULE ;; balance (income - cost)

  balance-history                                                                   ;;## SALES MODULE ;; variable to store the balance of the system.
  balance-historyXticks                                                             ;;## SALES MODULE ;; balance of the system since the start of the simulation.

]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Patch variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
patches-own [
  grass-height                                                                      ;; primary production (biomass), expressed in centimeters
  soil-quality                                                                      ;; affects the maximum grass height that can be achieved in a patch
  gh-individual                                                                     ;; grass height consumed per cow
  r                                                                                 ;; growth rate for the grass = 0.02 1/day
  GH-consumed                                                                       ;; grass-height consumed by all cows
  DM-kg-ha                                                                          ;; primary production (biomass), expressed in kg of Dry Matter (DM)
  paddock-a                                                                         ;; defines the patches that make up paddock-a in a rotational grazing spatial management strategy
  paddock-b                                                                         ;; defines the patches that make up paddock-b in a rotational grazing spatial management strategy
  paddock-c                                                                         ;; defines the patches that make up paddock-c in a rotational grazing spatial management strategy
  paddock-d                                                                         ;; defines the patches that make up paddock-d in a rotational grazing spatial management strategy
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Turtle variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
breed [cows cow]

cows-own [
  age                                                                               ;; defines the age of each animal (in days)
  born-calf?                                                                        ;; boolean variable that determines the "born-calf" age class of the livestock life cycle (includes both "born-calf-female" and "born-calf-male")
  born-calf-female?                                                                 ;; boolean variable that determines the "born-calf-female" age class of the livestock life cycle
  born-calf-male?                                                                   ;; boolean variable that determines the "born-calf-male" age class of the livestock life cycle
  weaned-calf?                                                                      ;; boolean variable that determines the "weaned-calf" age class of the livestock life cycle (includes both "weaned-calf-female" and "weaned-calf-male")
  weaned-calf-female?                                                               ;; boolean variable that determines the "weaned-calf-female" age class of the livestock life cycle
  weaned-calf-male?                                                                 ;; boolean variable that determines the "weaned-calf-male" age class of the livestock life cycle
  heifer?                                                                           ;; boolean variable that determines the "heifer" age class of the livestock life cycle
  steer?                                                                            ;; boolean variable that determines the "steer" age class of the livestock life cycle
  adult-cow?                                                                        ;; boolean variable that determines the "adult-cow" age class of the livestock life cycle (includes both "cow" and "cow-with-calf")
  cow?                                                                              ;; boolean variable that determines the "cow" age class of the livestock life cycle
  cow-with-calf?                                                                    ;; boolean variable that determines the "cow-withcalf" age class of the livestock life cycle
  pregnant?                                                                         ;; boolean variable that determines the "pregnant" age class of the livestock life cycle
  animal-units                                                                      ;; variable used to calculate the stocking rate. AU = LW / 380
  category-coef                                                                     ;; coefficient that varies with age class and affects the grass consumption of animals. Equal to 1 in all age classes, except for cow-with-calf = 1.1
  initial-weight                                                                    ;; initial weight of the animal at the beginning of the simulation. Set by the observer in the interface
  min-weight                                                                        ;; defines the critical weight which below the animal can die by forage crisis
  live-weight                                                                       ;; variable that defines the state of the animals in terms of live weight
  live-weight-gain                                                                  ;; defines the increment of weight.
  live-weight-gain-history-season                                                   ;; variable to store the live weight gain during a season
  live-weight-gain-historyXticks-season                                             ;; live weight gain since start of season
  live-weight-gain-history-year                                                     ;; variable to store the live weight gain during 368 days (a year)
  live-weight-gain-historyXticks-year                                               ;; live weight gain since start of year
  DM-kg-cow                                                                         ;; biomass available (not consumed!) for one cow
  DDMC                                                                              ;; Daily Dry Matter Consumption. Is the biomass consumed by one cow
  metabolic-body-size                                                               ;; Metabolic Body Size (MBS) = LW^(3/4)
  mortality-rate                                                                    ;; mortality rate can be natural or exceptional
  natural-mortality-rate                                                            ;; annual natural mortality = 2%
  except-mort-rate                                                                  ;; exceptional mortality rates increases to 15% in cows, 30% in pregnant cows, and 23% in the rest of age classes when animal LW falls below the minimum weight
  pregnancy-rate                                                                    ;; probability that a heifer/cow/cow-with-calf will become pregnant
  coefA                                                                             ;; constant used to calculate the pregnancy rate. Cow= 20000, cow-with-calf= 12000, heifer= 4000.
  coefB                                                                             ;; constant used to calculate the pregnancy rate. Cow= 0.0285, cow-with-calf= 0.0265, heifer= 0.029.
  pregnancy-time                                                                    ;; variable to keep track of which day of pregnancy the cow is in (from 0 to 276)
  lactating-time                                                                    ;; variable to keep track of which day of the lactation period the cow is in (from 0 to 246)

  price                                                                             ;;## SALES MODULE ;; market prices per kg for one animal (USD/kg)
  sale?                                                                             ;;## SALES MODULE ;; boolean variable that determines whether the animal is selected for sale (and subsequently removed from the system)
  value                                                                             ;;## SALES MODULE ;; live weight price for one animal (market prices per kg * live weight of the animal) (USD)

  parent                                                                            ;;## EARLY/NATURAL WEANING MODULE
  child                                                                             ;;## EARLY/NATURAL WEANING MODULE
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SETTING UP GLOBAL AND AGENT VARIABLES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  ca
  resize-world 0 (set-x-size - 1) 0 (set-y-size - 1)                               ;; changes the size of the world, set by the observer in the interface
  setup-globals
  setup-grassland
  setup-livestock
  use-new-seed
  reset-ticks
end

to use-new-seed
  let my-seed new-seed                                                              ;; generate a new seed
  output-print word "Seed: " my-seed                                                ;; print it out
  random-seed my-seed                                                               ;; use the generated seed
end

to setup_seed                                                                       ;; alternative setup that allows us to use the same seed for testing purposes
  ca
  resize-world 0 (set-x-size - 1) 0 (set-y-size - 1)
  setup-globals
  setup-grassland
  setup-livestock
  seed-1070152876
  reset-ticks
end

to seed-1070152876
  let my-seed 1070152876
  output-print word "Seed: " my-seed
  random-seed my-seed
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
  set DM-cm-ha set-DM-cm-ha
  set season-coef [1 1.15 1.05 1]
  ;set kmax [7.4 22.2 15.6 11.1]
  set maxLWG [40 60 40 40]
  set current-season initial-season                                                 ;; the initial season is set by the observer in the interface
  set historic-climacoef [0.48 0.3 0.72 0.12 0.71 0.65 1.1]                         ;; historic climacoef values. One value = 1 season (for example, 7 values = 7 seasons, the simulation will stop after season 7). Replace these values with historical values. For the model to use "historic-climacoef" values, the observer must select the "historic-climacoef" option within the "climacoef-distribution" chooser in the interface.

  set supplement-prices [0.113 0.121 0.123 0.115]                                   ;;## SALES MODULE
  set born-calf-prices [0.94 1 0.97 0.961]                                          ;;## SALES MODULE
  set weaned-calf-prices [0.98 1.02 1 0.982]                                        ;;## SALES MODULE
  set steer-prices [0.856 0.917 0.881 0.873]                                        ;;## SALES MODULE
  set heifer-prices [0.701 0.733 0.727 0.696]                                       ;;## SALES MODULE
  set cow-prices [0.561 0.611 0.573 0.581]                                          ;;## SALES MODULE
  set pregnant-prices [0.561 0.611 0.573 0.581]                                     ;;## SALES MODULE
  set cow-with-calf-prices [0.61 0.664 0.665 0.617]                                 ;;## SALES MODULE

  set cost 0                                                                        ;;## SALES MODULE
  set income 0                                                                      ;;## SALES MODULE
  set balance 0                                                                     ;;## SALES MODULE

  set balance-history []                                                            ;;## SALES MODULE
  set balance-historyXticks []                                                      ;;## SALES MODULE

end

to setup-grassland
  if (spatial-management = "rotational grazing") [                                  ;; this section of code is used to set up the paddocks for the rotational grazing management strategy.
    ask patches with [ (pxcor < (set-x-size) / 2 or pxcor = (set-x-size - 1) / 2) and (pycor > (set-y-size - 1) / 2 or pycor = (set-y-size) / 2)] [set paddock-a 1]
    ask patches with [ (pxcor > (set-x-size - 1) / 2 or pxcor = (set-x-size - 1) / 2) and (pycor > (set-y-size) / 2 or pycor = (set-y-size) / 2)]  [set paddock-b 1]
    ask patches with [ (pxcor > (set-x-size) / 2 or pxcor = (set-x-size) / 2) and (pycor < (set-y-size) / 2 or pycor = (set-y-size - 1) / 2)] [set paddock-c 1]
    ask patches with [ (pxcor < (set-x-size) / 2 or pxcor = (set-x-size - 1) / 2) and (pycor < (set-y-size) / 2 or pycor = (set-y-size - 1) / 2)] [set paddock-d 1]
  ]

  ask patches [
    set soil-quality 1
                                                                                    ;; coding of different soil quality distributions
    if (soil-quality-distribution = "uniform") [set soil-quality random-float 1]

    if (soil-quality-distribution = "normal") [
      set soil-quality random-normal 0.5 0.15
      if soil-quality < 0 [set soil-quality 0]
      if soil-quality > 1 [set soil-quality 1]]

    if (soil-quality-distribution = "exponential_low") [
      set soil-quality random-exponential 0.2
      while [soil-quality > 1] [set soil-quality random-exponential 0.2]]

    if (soil-quality-distribution = "exponential_high") [
      set soil-quality 1 - random-exponential 0.2
      while [soil-quality < 0] [set soil-quality 1 - random-exponential 0.2]]

    set grass-height initial-grass-height * soil-quality                            ;; the initial grass height is set by the observer in the interface
    set GH-consumed 0
    ifelse grass-height < 2                                                         ;; patches with grass height less than 2 cm are colored light green. This is based on the assumption that cows cannot eat grass less than 2 cm high
    [set pcolor 37]
    [set pcolor scale-color green grass-height 23 0]
    set r 0.02
  ]
end

to setup-livestock
  if (spatial-management = "free grazing") [                                        ;; livestock setup for the free grazing management strategy
    create-cows initial-num-cows [set shape "cow" set live-weight initial-weight-cows set initial-weight initial-weight-cows set mortality-rate natural-mortality-rate set DDMC 0 set age random (cow-age-max - cow-age-min) + cow-age-min setxy random-pxcor random-pycor become-cow ]
    create-cows initial-num-heifers [set shape "cow" set live-weight initial-weight-heifers set initial-weight initial-weight-heifers set mortality-rate natural-mortality-rate set DDMC 0 set age random (cow-age-min - heifer-age-min) + heifer-age-min setxy random-pxcor random-pycor become-heifer ]
    create-cows initial-num-steers [set shape "cow" set live-weight initial-weight-steers set initial-weight initial-weight-steers set mortality-rate natural-mortality-rate set DDMC 0 set age random (cow-age-min - heifer-age-min) + heifer-age-min setxy random-pxcor random-pycor become-steer ]
    create-cows initial-num-weaned-calves [set shape "cow" set live-weight initial-weight-weaned-calves set initial-weight initial-weight-weaned-calves set mortality-rate natural-mortality-rate set DDMC 0 set age random (heifer-age-min - weaned-calf-age-min) + weaned-calf-age-min setxy random-pxcor random-pycor ifelse random-float 1 < 0.5 [become-weaned-calf-female] [become-weaned-calf-male]]
  ]

  if (spatial-management = "rotational grazing") [                                  ;; livestock setup for the rotational grazing management strategy
    if (starting-paddock = "paddock a") [create-cows initial-num-cows [set shape "cow" set live-weight initial-weight-cows set initial-weight initial-weight-cows set mortality-rate natural-mortality-rate set DDMC 0 set age cow-age-min ask cows [move-to one-of patches with [paddock-a = 1]] become-cow]]
    if (starting-paddock = "paddock a") [create-cows initial-num-heifers [set shape "cow" set live-weight initial-weight-heifers set initial-weight initial-weight-heifers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-a = 1]] become-heifer]]
    if (starting-paddock = "paddock a") [create-cows initial-num-steers [set shape "cow" set live-weight initial-weight-steers set initial-weight initial-weight-steers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-a = 1]] become-steer]]
    if (starting-paddock = "paddock a") [create-cows initial-num-weaned-calves [set shape "cow" set live-weight initial-weight-weaned-calves set initial-weight initial-weight-weaned-calves set mortality-rate natural-mortality-rate set DDMC 0 set age random (heifer-age-min - weaned-calf-age-min) + weaned-calf-age-min ask cows [move-to one-of patches with [paddock-a = 1]] ifelse random-float 1 < 0.5 [become-weaned-calf-female] [become-weaned-calf-male]]]

    if (starting-paddock = "paddock b") [create-cows initial-num-cows [set shape "cow" set live-weight initial-weight-cows set initial-weight initial-weight-cows set mortality-rate natural-mortality-rate set DDMC 0 set age cow-age-min ask cows [move-to one-of patches with [paddock-b = 1]] become-cow]]
    if (starting-paddock = "paddock b") [create-cows initial-num-heifers [set shape "cow" set live-weight initial-weight-heifers set initial-weight initial-weight-heifers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-b = 1]] become-heifer]]
    if (starting-paddock = "paddock b") [create-cows initial-num-steers [set shape "cow" set live-weight initial-weight-steers set initial-weight initial-weight-steers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-b = 1]] become-steer]]
    if (starting-paddock = "paddock b") [create-cows initial-num-weaned-calves [set shape "cow" set live-weight initial-weight-weaned-calves set initial-weight initial-weight-weaned-calves set mortality-rate natural-mortality-rate set DDMC 0 set age random (heifer-age-min - weaned-calf-age-min) + weaned-calf-age-min ask cows [move-to one-of patches with [paddock-b = 1]] ifelse random-float 1 < 0.5 [become-weaned-calf-female] [become-weaned-calf-male]]]

    if (starting-paddock = "paddock c") [create-cows initial-num-cows [set shape "cow" set live-weight initial-weight-cows set initial-weight initial-weight-cows set mortality-rate natural-mortality-rate set DDMC 0 set age cow-age-min ask cows [move-to one-of patches with [paddock-c = 1]] become-cow]]
    if (starting-paddock = "paddock c") [create-cows initial-num-heifers [set shape "cow" set live-weight initial-weight-heifers set initial-weight initial-weight-heifers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-c = 1]] become-heifer]]
    if (starting-paddock = "paddock c") [create-cows initial-num-steers [set shape "cow" set live-weight initial-weight-steers set initial-weight initial-weight-steers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-c = 1]] become-steer]]
    if (starting-paddock = "paddock c") [create-cows initial-num-weaned-calves [set shape "cow" set live-weight initial-weight-weaned-calves set initial-weight initial-weight-weaned-calves set mortality-rate natural-mortality-rate set DDMC 0 set age random (heifer-age-min - weaned-calf-age-min) + weaned-calf-age-min ask cows [move-to one-of patches with [paddock-c = 1]] ifelse random-float 1 < 0.5 [become-weaned-calf-female] [become-weaned-calf-male]]]

    if (starting-paddock = "paddock d") [create-cows initial-num-cows [set shape "cow" set live-weight initial-weight-cows set initial-weight initial-weight-cows set mortality-rate natural-mortality-rate set DDMC 0 set age cow-age-min ask cows [move-to one-of patches with [paddock-d = 1]] become-cow]]
    if (starting-paddock = "paddock d") [create-cows initial-num-heifers [set shape "cow" set live-weight initial-weight-heifers set initial-weight initial-weight-heifers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-d = 1]] become-heifer]]
    if (starting-paddock = "paddock d") [create-cows initial-num-steers [set shape "cow" set live-weight initial-weight-steers set initial-weight initial-weight-steers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-d = 1]] become-steer]]
    if (starting-paddock = "paddock d") [create-cows initial-num-weaned-calves [set shape "cow" set live-weight initial-weight-weaned-calves set initial-weight initial-weight-weaned-calves set mortality-rate natural-mortality-rate set DDMC 0 set age random (heifer-age-min - weaned-calf-age-min) + weaned-calf-age-min ask cows [move-to one-of patches with [paddock-d = 1]] ifelse random-float 1 < 0.5 [become-weaned-calf-female] [become-weaned-calf-male]]]
  ]

  ask cows [                                                                        ;; setup of the variables used to output the average live weight gained during a season (see report "ILWG_SEASON" and "Average SEASONAL ILWG" monitor) or during a year (see report "ILWG_YEAR" and "Average YEARLY ILWG" monitor)
    set live-weight-gain-history-season []
    set live-weight-gain-historyXticks-season []
    set live-weight-gain-history-year []
    set live-weight-gain-historyXticks-year []
  ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This section of the code sets up the parameters that define each of the age classes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to become-born-calf-female
  set born-calf? true
  set born-calf-female? true
  set born-calf-male? false
  set weaned-calf? false
  set weaned-calf-female? false
  set weaned-calf-male? false
  set heifer? false
  set steer? false
  set adult-cow? false
  set cow? false
  set cow-with-calf? false
  set pregnant? false
  set color cyan
  set age 0
  set initial-weight 40
  set live-weight initial-weight
  set animal-units live-weight / set-1-AU
  set size 0.3
  set natural-mortality-rate 0.000054
  set except-mort-rate 0
  set category-coef 1
  set pregnancy-rate 0
  set coefA 0
  set coefB 0
  set pregnancy-time 0
  set lactating-time 0

  set price item current-season born-calf-prices                                    ;;## SALES MODULE
  set sale? false                                                                   ;;## SALES MODULE
  set value price * live-weight                                                     ;;## SALES MODULE
end

to become-born-calf-male
  set born-calf? true
  set born-calf-female? false
  set born-calf-male? true
  set weaned-calf? false
  set weaned-calf-female? false
  set weaned-calf-male? false
  set heifer? false
  set steer? false
  set adult-cow? false
  set cow? false
  set cow-with-calf? false
  set pregnant? false
  set color sky
  set age 0
  set initial-weight 40
  set live-weight initial-weight
  set animal-units live-weight / set-1-AU
  set size 0.3
  set natural-mortality-rate 0.000054
  set except-mort-rate 0
  set category-coef 1
  set pregnancy-rate 0
  set coefA 0
  set coefB 0
  set pregnancy-time 0
  set lactating-time 0

  set price item current-season born-calf-prices                                    ;;## SALES MODULE
  set sale? false                                                                   ;;## SALES MODULE
  set value price * live-weight                                                     ;;## SALES MODULE
end

to become-weaned-calf-female
  set born-calf? false
  set born-calf-female? false
  set born-calf-male? false
  set weaned-calf? true
  set weaned-calf-female? true
  set weaned-calf-male? false
  set heifer? false
  set steer? false
  set adult-cow? false
  set cow? false
  set cow-with-calf? false
  set pregnant? false
  set color yellow - 2
  set animal-units live-weight / set-1-AU
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

  set price item current-season weaned-calf-prices                                  ;;## SALES MODULE
  set sale? false                                                                   ;;## SALES MODULE
  set value price * live-weight                                                     ;;## SALES MODULE
end

to become-weaned-calf-male
  set born-calf? false
  set born-calf-female? false
  set born-calf-male? false
  set weaned-calf? true
  set weaned-calf-female? false
  set weaned-calf-male? true
  set heifer? false
  set steer? false
  set adult-cow? false
  set cow? false
  set cow-with-calf? false
  set pregnant? false
  set color orange
  set animal-units live-weight / set-1-AU
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

  set price item current-season weaned-calf-prices                                  ;;## SALES MODULE
  set sale? false                                                                   ;;## SALES MODULE
  set value price * live-weight                                                     ;;## SALES MODULE
end

to become-heifer
  set born-calf? false
  set born-calf-female? false
  set born-calf-male? false
  set weaned-calf? false
  set weaned-calf-female? false
  set weaned-calf-male? false
  set heifer? true
  set steer? false
  set adult-cow? false
  set cow? false
  set cow-with-calf? false
  set pregnant? false
  set color pink
  set animal-units live-weight / set-1-AU
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

  ifelse pregnant? = true [set price item current-season pregnant-prices] [set price item current-season heifer-prices]                 ;;## SALES MODULE
  set sale? false                                                                                                                       ;;## SALES MODULE
  set value price * live-weight                                                                                                         ;;## SALES MODULE
end

to become-steer
  set born-calf? false
  set born-calf-female? false
  set born-calf-male? false
  set weaned-calf? false
  set weaned-calf-female? false
  set weaned-calf-male? false
  set heifer? false
  set steer? true
  set adult-cow? false
  set cow? false
  set cow-with-calf? false
  set pregnant? false
  set color red
  set animal-units live-weight / set-1-AU
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

  set price item current-season steer-prices                                        ;;## SALES MODULE
  set sale? false                                                                   ;;## SALES MODULE
  set value price * live-weight                                                     ;;## SALES MODULE
end

to become-cow
  set born-calf? false
  set born-calf-female? false
  set born-calf-male? false
  set weaned-calf? false
  set weaned-calf-female? false
  set weaned-calf-male? false
  set heifer? false
  set steer? false
  set adult-cow? true
  set cow? true
  set cow-with-calf? false
  set pregnant? false
  set color brown
  set animal-units live-weight / set-1-AU
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

  ifelse pregnant? = true  [set price item current-season pregnant-prices] [set price item current-season cow-prices]                   ;;## SALES MODULE
  set sale? false                                                                                                                       ;;## SALES MODULE
  set value price * live-weight                                                                                                         ;;## SALES MODULE
end

to become-cow-with-calf
  set born-calf? false
  set born-calf-female? false
  set born-calf-male? false
  set weaned-calf? false
  set weaned-calf-female? false
  set weaned-calf-male? false
  set heifer? false
  set steer? false
  set adult-cow? true
  set cow? false
  set cow-with-calf? true
  set pregnant? false
  set color magenta
  set animal-units live-weight / set-1-AU
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

  ifelse pregnant? = true  [set price item current-season pregnant-prices] [set price item current-season cow-with-calf-prices]         ;;## SALES MODULE
  set sale? false                                                                                                                       ;;## SALES MODULE
  set value price * live-weight                                                                                                         ;;## SALES MODULE
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAIN PROCEDURES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  if current-season = 0 [                                                            ;; setting the Kmax, length of the season and climate distribution for the winter
    set kmax 7.4
    set season-length winter-length
    if (climacoef-distribution = "homogeneus") and (season-days = 0 or season-days = 1) [set climacoef winter-climacoef-homogeneus]
    if (climacoef-distribution = "uniform") and (season-days = 0 or season-days = 1) [set climacoef random-float 1.5]
    if (climacoef-distribution = "normal") and (season-days = 0 or season-days = 1) [set climacoef random-normal 1 0.15 if climacoef < 0 [set climacoef 0.1] if climacoef > 1.5 [set climacoef 1.5]]
    if (climacoef-distribution = "exponential_low") and (season-days = 0 or season-days = 1) [set climacoef random-exponential 0.5 while [climacoef > 1.5] [set climacoef random-exponential 0.5]]
    if (climacoef-distribution = "exponential_high") and (season-days = 0 or season-days = 1) [set climacoef 1.5 - random-exponential 0.1 while [climacoef < 0] [set climacoef 1.5 - random-exponential 0.1]]
  ]

  if current-season = 1 [                                                            ;; setting the Kmax, length of the season and climate distribution for the spring
    set kmax 22.2
    set season-length spring-length
    if (climacoef-distribution = "homogeneus") and (season-days = 0 or season-days = 1) [set climacoef spring-climacoef-homogeneus]
    if (climacoef-distribution = "uniform") and (season-days = 0 or season-days = 1) [set climacoef random-float 1.5]
    if (climacoef-distribution = "normal") and (season-days = 0 or season-days = 1) [set climacoef random-normal 1 0.15 if climacoef < 0 [set climacoef 0.1] if climacoef > 1.5 [set climacoef 1.5]]
    if (climacoef-distribution = "exponential_low") and (season-days = 0 or season-days = 1) [set climacoef random-exponential 0.2 while [climacoef > 1.5] [set climacoef random-exponential 0.2]]
    if (climacoef-distribution = "exponential_high") and (season-days = 0 or season-days = 1) [set climacoef 1.5 - random-exponential 0.1 while [climacoef < 0] [set climacoef 1.5 - random-exponential 0.1]]
  ]

  if current-season = 2 [                                                            ;; setting the Kmax, length of the season and climate distribution for the summer
    set kmax 15.6
    set season-length summer-length
    if (climacoef-distribution = "homogeneus") and (season-days = 0 or season-days = 1) [set climacoef summer-climacoef-homogeneus]
    if (climacoef-distribution = "uniform") and (season-days = 0 or season-days = 1) [set climacoef random-float 1.5]
    if (climacoef-distribution = "normal") and (season-days = 0 or season-days = 1) [set climacoef random-normal 1 0.15 if climacoef < 0 [set climacoef 0.1] if climacoef > 1.5 [set climacoef 1.5]]
    if (climacoef-distribution = "exponential_low") and (season-days = 0 or season-days = 1) [set climacoef random-exponential 0.5 while [climacoef > 1.5] [set climacoef random-exponential 0.5]]
    if (climacoef-distribution = "exponential_high") and (season-days = 0 or season-days = 1) [set climacoef 1.5 - random-exponential 0.1 while [climacoef < 0] [set climacoef 1.5 - random-exponential 0.1]]
  ]

  if current-season = 3 [                                                            ;; setting the Kmax, length of the season and climate distribution for the fall
    set kmax 11.1
    set season-length fall-length
    if (climacoef-distribution = "homogeneus") and (season-days = 0 or season-days = 1) [set climacoef fall-climacoef-homogeneus]
    if (climacoef-distribution = "uniform") and (season-days = 0 or season-days = 1) [set climacoef random-float 1.5]
    if (climacoef-distribution = "normal") and (season-days = 0 or season-days = 1) [set climacoef random-normal 1 0.15 if climacoef < 0 [set climacoef 0.1] if climacoef > 1.5 [set climacoef 1.5]]
    if (climacoef-distribution = "exponential_low") and (season-days = 0 or season-days = 1) [set climacoef random-exponential 0.5 while [climacoef > 1.5] [set climacoef random-exponential 0.5]]
    if (climacoef-distribution = "exponential_high") and (season-days = 0 or season-days = 1) [set climacoef 1.5 - random-exponential 0.1 while [climacoef < 0] [set climacoef 1.5 - random-exponential 0.1]]
  ]

  if current-season = 0 [if season-days >= winter-length [set current-season 1 set season-days 0]] ;; the season change is defined in these lines
  if current-season = 1 [if season-days >= spring-length [set current-season 2 set season-days 0]]
  if current-season = 2 [if season-days >= summer-length [set current-season 3 set season-days 0]]
  if current-season = 3 [if season-days >= fall-length [set current-season 0 set season-days 0]]

  if (climacoef-distribution = "historic-climacoef") [if current-season = 0 [set climacoef item (simulation-time / winter-length) historic-climacoef]]  ;; if "historic-climacoef" is selected, historic values for climacoef are used instead
  if (climacoef-distribution = "historic-climacoef") [if current-season = 1 [set climacoef item (simulation-time / spring-length) historic-climacoef]]
  if (climacoef-distribution = "historic-climacoef") [if current-season = 2 [set climacoef item (simulation-time / summer-length) historic-climacoef]]
  if (climacoef-distribution = "historic-climacoef") [if current-season = 3 [set climacoef item (simulation-time / fall-length) historic-climacoef]]



;;###############################################################################################################################################################################
  set test-climacoef set-test-climacoef                                                                  ;;### THIS IS FOR TEST PURPOSES. IT WILL BE DELETED IN THE FINAL VERSION
  if (climacoef-distribution = "test-climacoef") [if current-season = 0 [set climacoef test-climacoef]]  ;;### THIS IS FOR TEST PURPOSES. IT WILL BE DELETED IN THE FINAL VERSION
  if (climacoef-distribution = "test-climacoef") [if current-season = 1 [set climacoef test-climacoef]]  ;;### THIS IS FOR TEST PURPOSES. IT WILL BE DELETED IN THE FINAL VERSION
  if (climacoef-distribution = "test-climacoef") [if current-season = 2 [set climacoef test-climacoef]]  ;;### THIS IS FOR TEST PURPOSES. IT WILL BE DELETED IN THE FINAL VERSION
  if (climacoef-distribution = "test-climacoef") [if current-season = 3 [set climacoef test-climacoef]]  ;;### THIS IS FOR TEST PURPOSES. IT WILL BE DELETED IN THE FINAL VERSION
;;###############################################################################################################################################################################



  set simulation-time simulation-time + days-per-tick
  set season-days season-days + days-per-tick
  set year-days year-days + days-per-tick

  if year-days >= 369 [set year-days 1]                                              ;; This restart is important to make sure that the "live-weight-gain-history-year" variable works, which is used in the "ILWG_YEAR" report

  if (spatial-management = "rotational grazing") [set ticks-since-here ticks-since-here + days-per-tick]                              ;; for rotational grazing strategies only, it measures the number of days since the animals were moved to a new paddock. This variable is important to prevent animals from continuously moving from one paddock to another once they have met the criteria to move to the next paddock. Once animals have met the criteria, they will move to the next paddock and wait X days (defined by the RG-days-in-paddock slider in the interface) to acclimate to the new paddock. Once those days have passed, if the animals still meet the criteria to move between paddocks, they will move.

  ask cows [                                                                         ;; in this line, the average live weight gain of the cows during the season is calculated
    set live-weight-gain-history-season fput live-weight-gain live-weight-gain-history-season
    if season-days > 0 [set live-weight-gain-historyXticks-season mean (sublist live-weight-gain-history-season 0 season-days)]
    if season-days = season-length [set live-weight-gain-history-season []]
  ]

  ask cows [                                                                         ;; in this line, the average live weight gain of the cows during the year (from day 1 to day 368 and in between) is calculated
    set live-weight-gain-history-year fput live-weight-gain live-weight-gain-history-year
    if year-days > 0 [set live-weight-gain-historyXticks-year mean (sublist live-weight-gain-history-year 0 year-days)]
    if year-days = 368 [set live-weight-gain-history-year []]
  ]

  set balance-history fput balance balance-history                                                    ;;## SALES MODULE
  set balance-historyXticks sum (sublist balance-history 0 simulation-time)                           ;;## SALES MODULE

  ;set balance-history fput balance balance-history
  ;if year-days > 0 [set balance-historyXticks sum (sublist balance-history 0 year-days)]
  ;if year-days = 368 [set balance-history []]



  if simulation-time / 368 = STOP-SIMULATION-AT [stop]                               ;; the observer can decide whether the simulation should run indefinitely (STOP-SIMULATION-AT 0 years) or after X years

  grow-grass
  move
  kgDM/cow
  LWG
  DM-consumption



  if (farmer-profile = "none") [
    grow-livestock-natural-weaning                                                   ;;## EARLY/NATURAL WEANING MODULE
  ]
    if (farmer-profile = "traditional") [
    grow-livestock-natural-weaning                                                   ;;## EARLY/NATURAL WEANING MODULE
  ]
    if (farmer-profile = "environmental") [
    grow-livestock-natural-weaning                                                   ;;## EARLY/NATURAL WEANING MODULE
  ]
  if (farmer-profile = "market") [
    grow-livestock-early-weaning                                                     ;;## EARLY/NATURAL WEANING MODULE
  ]



  if (farmer-profile = "none") [
    uncontrolled-breeding                                                            ;;## CONTROLLED/NATURAL BREEDING MODULE
  ]
  if (farmer-profile = "traditional") [
    uncontrolled-breeding                                                            ;;## CONTROLLED/NATURAL BREEDING MODULE
  ]
  if (farmer-profile = "market") [
    controlled-breeding                                                              ;;## CONTROLLED/NATURAL BREEDING MODULE
  ]
  if (farmer-profile = "environmental") [
    controlled-breeding                                                              ;;## CONTROLLED/NATURAL BREEDING MODULE
  ]



  update-grass-height



  update-prices                                                                      ;;## SALES MODULE

  if (farmer-profile = "traditional") [
    ordinary-sale-males                                                                       ;;## ORDINARY SALES MODULE
  ]


  if (farmer-profile = "market") [
    ordinary-sale-males                                                                       ;;## ORDINARY SALES MODULE
    ordinary-sale-old-cows                                                                    ;;## ORDINARY SALES MODULE
    ordinary-sale-heifers-cows                                                                ;;## ORDINARY SALES MODULE

    extraordinary-sale-males-market-farmer                                                    ;;## EXTRAORDINARY SALES MODULE
    extraordinary-sale-old-cows-market-farmer                                                 ;;## EXTRAORDINARY SALES MODULE
    extraordinary-sale-heifers-cows-market-farmer                                             ;;## EXTRAORDINARY SALES MODULE
  ]


  if (farmer-profile = "environmental") [                                                     ;;## ORDINARY SALES MODULE
    ordinary-sale-males                                                                       ;;## ORDINARY SALES MODULE
    ordinary-sale-old-cows                                                                    ;;## ORDINARY SALES MODULE
    ordinary-sale-heifers-cows                                                                ;;## ORDINARY SALES MODULE


    extraordinary-sale-males-environmental-farmer                                                ;;## EXTRAORDINARY SALES MODULE
    extraordinary-sale-old-cows-environmental-farmer                                             ;;## EXTRAORDINARY SALES MODULE
    extraordinary-sale-heifers-cows-environmental-farmer                                         ;;## EXTRAORDINARY SALES MODULE
  ]

  farm-balance                                                                       ;;## SALES MODULE

  ;ask cows with [pregnant?] [set color pink + 2 set size 1.1]

  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BIOPHYSICAL SUBMODEL PROCEDURES: grow of grass and cattle behavior
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Grow of grass
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to grow-grass                                                                        ;; each patch calculates the height of its grass following a logistic regression. Grass height is affected by season, climacoef (set by the observer in the interface) and consumption of grass by animals (GH-consumed is the grass consumed by cows during the previous day)
  ask patches [
    set grass-height (grass-height + r * grass-height * (1 - grass-height / ((kmax * soil-quality) * climacoef))) - GH-consumed
    if grass-height <= 0 [set grass-height 0.1]                                      ;; to avoid negative values. If grass-height = 0, no grass would grow in a patch. To fix this, we use 0.1 instead.

    ifelse grass-height < 2                                                          ;; patches with grass height less than 2 cm are colored light green. This is based on the assumption that cows cannot eat grass less than 2 cm high
    [set pcolor 37]
    [set pcolor scale-color green grass-height 23 0]

    set DM-kg-ha DM-cm-ha * grass-height                                             ;; converting cm of grass in each patch into kg of Dry Matter (DM)
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cattle behavior
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move                                                                              ;; once the grass height of each patch is updated, if the grass height in a patch is minor than 5 cm (the minimum grass height that maintains the live weight of a cow), the cows moves to another patch. Whether the cows move to a neighboring random patch or to the neighboring patch with the highest grass height is determined by the "perception" slider in the interface.
  if (spatial-management = "free grazing")[                                          ;; cow movement rules for the free grazing management strategy
    ask cows [
      if grass-height < 5
      [ifelse random-float 1 < perception
        [uphill grass-height]
        [move-to one-of neighbors]]]]

  if (spatial-management = "rotational grazing") [                                   ;; cow movement rules for the rotational grazing management strategy
    ask cows [
      let patches-a1 neighbors with [paddock-a = 1]
      let target-a1 max-one-of patches-a1 [grass-height]
      if grass-height < 5 and paddock-a = 1
      [ifelse random-float 1 < perception and paddock-a = 1
        [move-to target-a1]
        [move-to one-of neighbors with [paddock-a = 1]]]]
    ask cows [
      let patches-b1 neighbors with [paddock-b = 1]
      let target-b1 max-one-of patches-b1 [grass-height]
      if grass-height < 5 and paddock-b = 1
      [ifelse random-float 1 < perception and paddock-b = 1
        [move-to target-b1]
        [move-to one-of neighbors with [paddock-b = 1]]]]
    ask cows [
      let patches-c1 neighbors with [paddock-c = 1]
      let target-c1 max-one-of patches-c1 [grass-height]
      if grass-height < 5 and paddock-c = 1
      [ifelse random-float 1 < perception and paddock-c = 1
        [move-to target-c1]
        [move-to one-of neighbors with [paddock-c = 1]]]]
    ask cows [
      let patches-d1 neighbors with [paddock-d = 1]
      let target-d1 max-one-of patches-d1 [grass-height]
      if grass-height < 5 and paddock-d = 1
      [ifelse random-float 1 < perception and paddock-d = 1
        [move-to target-d1]
        [move-to one-of neighbors with [paddock-d = 1]]]]

    if (farmer-profile = "none") or (farmer-profile = "traditional") [            ;; Traditional farmers move cows at the end of each season
      if season-days >= season-length [
        ask cows
        [ifelse paddock-a = 1
          [let next-paddock one-of patches with [paddock-b = 1] move-to next-paddock]
          [ifelse paddock-b = 1
            [let next-paddock one-of patches with [paddock-c = 1] move-to next-paddock]
            [ifelse paddock-c = 1
              [let next-paddock one-of patches with [paddock-d = 1] move-to next-paddock]
              [let next-paddock one-of patches with [paddock-a = 1] move-to next-paddock]]]]]]

    if (farmer-profile = "market") [                                            ;; Market-oriented farmers move cows from one plot to another when the average live weight of the cows is below a threshold (determined by the "RG-live-weight-threshold" slider in the interface).
      if RG-live-weight-threshold > mean [live-weight] of cows and ticks-since-here > RG-days-in-paddock [ ;; Once the animals are moved to the next paddock because they have met the criteria, because the effects of the new paddock on the animals' live weight take several days, and to avoid animals moving continuously from one paddock to another during these first days (because they will still have a value below the threshold), the minimum number of days the animals have to adapt to the new paddock before moving to the next is set with the "RG-days-in-paddock" slider.
        set ticks-since-here 0
        ask cows
        [ifelse paddock-a = 1
          [let next-paddock one-of patches with [paddock-b = 1] move-to next-paddock]
          [ifelse paddock-b = 1
            [let next-paddock one-of patches with [paddock-c = 1] move-to next-paddock]
            [ifelse paddock-c = 1
              [let next-paddock one-of patches with [paddock-d = 1] move-to next-paddock]
              [let next-paddock one-of patches with [paddock-a = 1] move-to next-paddock]]]]]]


    if (farmer-profile = "environmental") [                                            ;; Environmental-oriented farmers move cows from one plot to another when the SR of the paddock is below a threshold (determined by the "RG-SR-threshold" slider in the interface).
      if RG-SR-threshold > sum [animal-units] of cows / (count patches / 4) and ticks-since-here > RG-days-in-paddock [
        set ticks-since-here 0
        ask cows
        [ifelse paddock-a = 1
          [let next-paddock one-of patches with [paddock-b = 1] move-to next-paddock]
          [ifelse paddock-b = 1
            [let next-paddock one-of patches with [paddock-c = 1] move-to next-paddock]
            [ifelse paddock-c = 1
              [let next-paddock one-of patches with [paddock-d = 1] move-to next-paddock]
              [let next-paddock one-of patches with [paddock-a = 1] move-to next-paddock]]]]]]
  ]


end

to kgDM/cow                                                                          ;; each cow calculates the amount of Kg of DM it will receive.
  ask cows [set DM-kg-cow 0]

  ask patches [
  ask cows-here with [weaned-calf? or heifer? or steer? or cow? or cow-with-calf?] [set DM-kg-cow DM-kg-ha / count cows-here with [weaned-calf? or heifer? or steer? or cow? or cow-with-calf?] ]
  ]

   ask cows [set gh-individual ((DM-kg-cow) / DM-cm-ha )]                            ;; for its use in the following procedures, this amount of DM (kg) is converted back to grass height (cm) (important: this is not the grass height the animal consumes!!)
end

to LWG                                                                               ;; the live weight gain of each cow is calculated according to the number of centimeters of grass that correspond to each animal
ask cows [
   ifelse born-calf? = true
    [set live-weight-gain weight-gain-lactation]
    [ifelse grass-height >= 2                                                        ;; cows cannot eat grass less than 2 cm high
      [set live-weight-gain ( item current-season maxLWG - ( xi * e ^ ( - ni * gh-individual ) ) ) / ( season-length * item current-season season-coef )]
      [set live-weight-gain live-weight * -0.005]]

    set live-weight live-weight + live-weight-gain
    if live-weight < 0 [set live-weight 0]

    set animal-units live-weight / set-1-AU                                          ;; updating the AU of each cow used to calculate the total Stocking Rate (SR) of the system
  ]
end

to DM-consumption                                                                    ;; the DDMC consumed by each cow (in kg) is calculated in this procedure
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


to grow-livestock-natural-weaning                                                    ;;## EARLY/NATURAL WEANING MODULE ;; this procedure dictates the rules for the death or progression of animals to the next age class, as well as the lactation period of animals in a NATURAL weaning scenario.
ask cows [
    set age age + days-per-tick
    if age > cow-age-max [die]
    ifelse live-weight < min-weight
    [set mortality-rate except-mort-rate]
    [set mortality-rate natural-mortality-rate]
    if random-float 1 < mortality-rate [die]

    ask cows with [born-calf-female? and not any? my-links ] [ become-weaned-calf-female ]                                 ;; if the link with the mother (an agent with a "cow-with-calf?" state) is lost (this happens when the mother dies, or when the mother switches from a "cow-with-calf?" state to a "cow?" state), the calf weans prematurely.
    ask cows with [born-calf-male? and not any? my-links ] [ become-weaned-calf-male ]

    if (born-calf-female? = true) and (age >= weaned-calf-age-min) [become-weaned-calf-female ask my-out-links [die]]       ;; when the lactating calf moves on to the next age group (weaned-calf), the link (dependency) with its parent is terminated
    if (born-calf-male? = true) and (age >= weaned-calf-age-min) [become-weaned-calf-male ask my-out-links [die]]
    if (weaned-calf-female? = true) and (age >= heifer-age-min) [become-heifer]
    if (weaned-calf-male? = true) and (age >= heifer-age-min) [become-steer]
    if (heifer? = true) and (age >= cow-age-min) and (live-weight >= 280 ) [become-cow]
    if cow-with-calf? = true [set lactating-time lactating-time + days-per-tick]
    if lactating-time >= lactation-period [become-cow]
  ]
end


to grow-livestock-early-weaning                                                      ;;## EARLY/NATURAL WEANING MODULE ;; this procedure dictates the rules for the death or progression of animals to the next age class, as well as the lactation period of animals in a EARLY weaning scenario.
ask cows [
    set age age + days-per-tick
    if age > cow-age-max [die]
    ifelse live-weight < min-weight
    [set mortality-rate except-mort-rate]
    [set mortality-rate natural-mortality-rate]
    if random-float 1 < mortality-rate [die]

    if (cow-with-calf? = true and live-weight < early-weaning-threshold) [become-cow ask my-out-links [die]]               ;; if the mother (an agent with a "cow-with-calf?" state) is below a certain weight, it will switch to the "cow?" state and will kill the link with its child (an agent with a "born-calf" state). This weight is determined by the "early-weaning-threshold" slider in the interface.

    ask cows with [born-calf-female? and not any? my-links ] [ become-weaned-calf-female ]                                 ;; if the link with the mother (an agent with a "cow-with-calf?" state) is lost (this happens when the mother dies, or when the mother switches from a "cow-with-calf?" state to a "cow?" state), the calf weans prematurely.
    ask cows with [born-calf-male? and not any? my-links ] [ become-weaned-calf-male ]

    if (born-calf-female? = true) and (age >= weaned-calf-age-min) [become-weaned-calf-female ask my-out-links [die]]       ;; when the lactating calf moves on to the next age group (weaned-calf), the link (dependency) with its parent is terminated
    if (born-calf-male? = true) and (age >= weaned-calf-age-min) [become-weaned-calf-male ask my-out-links [die]]
    if (weaned-calf-female? = true) and (age >= heifer-age-min) [become-heifer]
    if (weaned-calf-male? = true) and (age >= heifer-age-min) [become-steer]
    if (heifer? = true) and (age >= cow-age-min) and (live-weight >= 280 ) [become-cow]
    if cow-with-calf? = true [set lactating-time lactating-time + days-per-tick]
    if lactating-time >= lactation-period [become-cow]
  ]
end


to uncontrolled-breeding                                                             ;;## CONTROLLED/NATURAL BREEDING MODULE ;; this procedure dictates the rules for which each of the reproductive age classes (i.e., heifer, cow, cow-with-calf) can become pregnant in an UNCONTROLLED breeding scenario, as well as the gestation period of animals
  ask cows [
    if (heifer? = true) or (cow? = true) or (cow-with-calf? = true) [set pregnancy-rate (1 / (1 + coefA * e ^ (- coefB * live-weight)))]
    ;if (heifer? = true) or (cow? = true) or (cow-with-calf? = true) [set pregnancy-rate (1 / (1 + coefA * e ^ (- coefB * live-weight))) / 368]  ;; alternative version, in which the PR is divided by 368.

    if random-float 1 < pregnancy-rate [set pregnant? true]
    if pregnant? = true [
      set pregnancy-time pregnancy-time + days-per-tick
      set except-mort-rate 0.3]

    if pregnancy-time = gestation-period [                                           ;; when the gestation period ends (276 days), a new agent (born-calf) is introduced into the system.
      hatch-cows 1 [
        let new-child nobody
        set new-child self
        set parent myself
        set child nobody
        create-link-with myself                                                      ;; this new agent is linked with its parent agent
        if (spatial-management = "rotational grazing") [if paddock-a = 1 [move-to one-of patches with [paddock-a = 1]] if paddock-b = 1 [move-to one-of patches with [paddock-b = 1]] if paddock-c = 1 [move-to one-of patches with [paddock-c = 1]] if paddock-d = 1 [move-to one-of patches with [paddock-d = 1]]]
        if  (spatial-management = "free grazing") [setxy random-pxcor random-pycor]
        ifelse random-float 1 < 0.5                                                  ;; 50% chance of being born as a male or female calf
        [become-born-calf-female]
        [become-born-calf-male]]
      set pregnant? false
      set pregnancy-time 0
      become-cow-with-calf]
  ]
end


to controlled-breeding                                                               ;;## CONTROLLED/NATURAL BREEDING MODULE ;; this procedure dictates the rules for which each of the reproductive age classes (i.e., heifer, cow, cow-with-calf) can become pregnant in an CONTROLLED breeding scenario, as well as the gestation period of animals
  ask cows [
    if (heifer? = true) or (cow? = true) or (cow-with-calf? = true) [set pregnancy-rate (1 / (1 + coefA * e ^ (- coefB * live-weight)))]
    ;if (heifer? = true) or (cow? = true) or (cow-with-calf? = true) [set pregnancy-rate (1 / (1 + coefA * e ^ (- coefB * live-weight))) / 368] ;; alternative version, in which the PR is divided by 368.

    if current-season = controlled-breeding-season [if random-float 1 < pregnancy-rate [set pregnant? true]]  ;; in a controlled breeding scenario, reproductive age classes can only get pregnant during the season selected by the "controlled-breeding-season" slider in the interface. By default, the breeding season is summer.
    if pregnant? = true [
      set pregnancy-time pregnancy-time + days-per-tick
      set except-mort-rate 0.3]

    if pregnancy-time = gestation-period [                                           ;; when the gestation period ends (276 days), a new agent (born-calf) is introduced into the system.
      hatch-cows 1 [
        let new-child nobody
        set new-child self
        set parent myself
        set child nobody
        create-link-with myself                                                      ;; this new agent is linked with its parent agent
        if (spatial-management = "rotational grazing") [if paddock-a = 1 [move-to one-of patches with [paddock-a = 1]] if paddock-b = 1 [move-to one-of patches with [paddock-b = 1]] if paddock-c = 1 [move-to one-of patches with [paddock-c = 1]] if paddock-d = 1 [move-to one-of patches with [paddock-d = 1]]]
        if  (spatial-management = "free grazing") [setxy random-pxcor random-pycor]
        ifelse random-float 1 < 0.5                                                  ;; 50% chance of being born as a male or female calf
        [become-born-calf-female]
        [become-born-calf-male]]
      set pregnant? false
      set pregnancy-time 0
      become-cow-with-calf]
  ]
end


to update-grass-height                                                               ;; the DDMC of all cows (total DDMC, in kg) in each patch is calculated and converted back to grass height (cm) to calculate the grass height consumed in each patch (GH-consumed)
ask patches [
    set GH-consumed 0
    ask cows-here [
      let totDDMC sum [DDMC] of cows-here
      set GH-consumed totDDMC / DM-cm-ha]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ECONOMIC SUBMODEL PROCEDURES: Cattle prices, cattle sales (ordinary and extraordinary sales) and farm balance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cattle prices
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-prices                                                                     ;;## SALES MODULE
  ask cows [
    if born-calf? = true [set price item current-season born-calf-prices set value price * live-weight]
    if weaned-calf? = true [set price item current-season weaned-calf-prices set value price * live-weight]
    if steer? = true [set price item current-season steer-prices set value price * live-weight]
    if heifer? = true [set price item current-season heifer-prices set value price * live-weight]
    if cow? = true [set price item current-season cow-prices set value price * live-weight]
    if cow-with-calf? = true [set price item current-season cow-with-calf-prices set value price * live-weight]
    if pregnant? = true [set price item current-season pregnant-prices set value price * live-weight]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cattle sales: ordinary sales                                                      ;; Ordinary cattle sales are held on the first day of fall.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to ordinary-sale-males                                                                        ;;## ORDINARY SALES MODULE ;; Ordinary sale of weaned male calves and steers, determined by the maximum number of males the farmer wishes to keep in the system ("keep-n-steers" slider in the interface)

  if current-season = 3 and (season-days = 1) [
    if any? cows with [weaned-calf-male?] [
      if count cows with [weaned-calf-male?] > keep-MAX-n-steers and count cows > keep-MIN-n-cattle [
        while [any? cows with [weaned-calf-male? and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle and count cows with [weaned-calf-male? and sale? = false] > keep-MAX-n-steers] [
          if (ordinary-sale-of-cows-with = "highest live weight") [
            ask max-n-of 1 cows with [weaned-calf-male? and sale? = false] [live-weight] [
              set sale? true
              set OS-males-weaned-calf sum [value] of cows with [weaned-calf-male? and sale?]]]

          if (ordinary-sale-of-cows-with = "lowest live weight") [
            ask min-n-of 1 cows with [weaned-calf-male? and sale? = false] [live-weight] [
              set sale? true
              set OS-males-weaned-calf sum [value] of cows with [weaned-calf-male? and sale?]]]]]]]


  if current-season = 3 and (season-days = 1) [
    if any? cows with [steer?] [
      if count cows with [steer?] > keep-MAX-n-steers and count cows > keep-MIN-n-cattle [
        while [any? cows with [steer? and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle and count cows with [steer? and sale? = false] > keep-MAX-n-steers] [
          if (ordinary-sale-of-cows-with = "highest live weight") [
            ask max-n-of 1 cows with [steer? and sale? = false] [live-weight] [
              set sale? true
              set OS-males-steer sum [value] of cows with [steer? and sale?]]]

          if (ordinary-sale-of-cows-with = "lowest live weight") [
            ask min-n-of 1 cows with [steer? and sale? = false] [live-weight] [
              set sale? true
              set OS-males-steer sum [value] of cows with [steer? and sale?]]]]]]]

  ask cows with [sale?] [die]

end


to ordinary-sale-old-cows                                                               ;;## ORDINARY SALES MODULE ;; Ordinary sale of old empty cows. The age at which a cow is considered old is determined by the "age-sell-old-cow" slider in the interface.

  if current-season = 3 and (season-days = 1) [
    if any? cows with [cow? and age / 368 > age-sell-old-cow] [
      if count cows > keep-MIN-n-cattle [
        ;while [any? cows with [cow? and age / 368 > age-sell-old-cow and sale? = false and pregnant? = false] and count cows with [sale? = false] > keep-MIN-n-cattle] [      ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
        while [any? cows with [cow? and age / 368 > age-sell-old-cow and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle] [
          if (ordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask max-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and sale? = false] [live-weight] [
              set sale? true
              set OS-old-cow sum [value] of cows with [cow? and age / 368 > age-sell-old-cow and sale?]]]

          if (ordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask min-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and sale? = false] [live-weight] [
              set sale? true
              set OS-old-cow sum [value] of cows with [cow? and age / 368 > age-sell-old-cow and sale?]]]]]]]

  ask cows with [sale?] [die]

 end


to ordinary-sale-heifers-cows                                           ;;## ORDINARY SALES MODULE ;; Ordinary sale of heifers and cows. The number of heifers and cows sold is determined by the maximum number of livestock the farmer wishes to keep in the system ("keep-n-cattle" slider in the interface). This is an early attempt to represent the maximum number of animals a farmer can manage.

  if current-season = 3 and (season-days = 1) [
    if any? cows with [heifer? or cow?] [
      if count cows > keep-MAX-n-cattle and count cows > keep-MIN-n-cattle [
        ;while [any? cows with [cow? or heifer? and pregnant? = false and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle] [         ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
        while [any? cows with [cow? or heifer? and sale? = false] and count cows with [sale? = false] > keep-MAX-n-cattle and count cows with [sale? = false] > keep-MIN-n-cattle] [
          if (ordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask max-n-of 1 cows with [cow? or heifer? and sale? = false] [live-weight] [
              set sale? true
              set OS-heifer sum [value] of cows with [heifer? and sale?]
              set OS-cow sum [value] of cows with [cow? and sale?]]]


          if (ordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask min-n-of 1 cows with [cow? or heifer? and sale? = false] [live-weight] [
              set sale? true
              set OS-heifer sum [value] of cows with [heifer? and sale?]
              set OS-cow sum [value] of cows with [cow? and sale?]]]]]]]

  ask cows with [sale?] [die]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cattle sales: extraordinary sales
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to extraordinary-sale-males-market-farmer                                           ;;## EXTRAORDINARY SALES MODULE ;; Extraordinary sale of male animals for the market-oriented farmer. If the market-oriented farmer profile is selected, the extraordinary sale of male animals takes place when the average live weight of all animals in the system is below a threshold (minimum weight set by the user, "ES-market-farmer-min-weight" slider in the interface).

  if any? cows with [weaned-calf-male?] [
    if mean [live-weight] of cows < ES-market-farmer-min-weight and count cows with [weaned-calf-male?] > keep-MAX-n-steers and count cows > keep-MIN-n-cattle [
      while [any? cows with [weaned-calf-male? and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle and count cows with [weaned-calf-male? and sale? = false] > keep-MAX-n-steers] [
        if (extraordinary-sale-of-cows-with = "highest live weight") [
          ask max-n-of 1 cows with [weaned-calf-male? and sale? = false] [live-weight] [
            set sale? true
            set ES-males-weaned-calf sum [value] of cows with [weaned-calf-male? and sale?]]]

        if (extraordinary-sale-of-cows-with = "lowest live weight") [
          ask min-n-of 1 cows with [weaned-calf-male? and sale? = false] [live-weight] [
            set sale? true
            set ES-males-weaned-calf sum [value] of cows with [weaned-calf-male? and sale?]]]]]]


  if any? cows with [steer?] [
    if mean [live-weight] of cows < ES-market-farmer-min-weight and count cows with [steer?] > keep-MAX-n-steers and count cows > keep-MIN-n-cattle [
      while [any? cows with [steer? and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle and count cows with [steer? and sale? = false] > keep-MAX-n-steers] [
        if (extraordinary-sale-of-cows-with = "highest live weight") [
          ask max-n-of 1 cows with [steer? and sale? = false] [live-weight] [
            set sale? true
            set ES-males-steer sum [value] of cows with [steer? and sale?]]]

        if (extraordinary-sale-of-cows-with = "lowest live weight") [
          ask min-n-of 1 cows with [steer? and sale? = false] [live-weight] [
            set sale? true
            set ES-males-steer sum [value] of cows with [steer? and sale?]]]]]]

  ask cows with [sale?] [die]

  end

to extraordinary-sale-old-cows-market-farmer                                                               ;;## EXTRAORDINARY SALES MODULE ;; Extrardinary sale of old cows for the market-oriented farmer. The age at which a cow is considered old is determined by the "age-sell-old-cow" slider in the interface.

  if any? cows with [cow? and age / 368 > age-sell-old-cow] [
    if mean [live-weight] of cows < ES-market-farmer-min-weight and count cows > keep-MIN-n-cattle [
      ;while [any? cows with [cow? and age / 368 > age-sell-old-cow and sale? = false and pregnant? = false] and count cows with [sale? = false] > keep-MIN-n-cattle] [      ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
      while [any? cows with [cow? and age / 368 > age-sell-old-cow and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle] [
        if (extraordinary-sale-of-cows-with = "highest live weight") [
          ;ask max-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
          ask max-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and sale? = false] [live-weight] [
            set sale? true
            set ES-old-cow sum [value] of cows with [cow? and age / 368 > age-sell-old-cow and sale?]]]

        if (extraordinary-sale-of-cows-with = "lowest live weight") [
          ;ask min-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
          ask min-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and sale? = false] [live-weight] [
            set sale? true
            set ES-old-cow sum [value] of cows with [cow? and age / 368 > age-sell-old-cow and sale?]]]]]]

  ask cows with [sale?] [die]

 end

to extraordinary-sale-heifers-cows-market-farmer                                           ;;## EXTRAORDINARY SALES MODULE ;; Extraordinary sale of heifers and cows for the market-oriented farmer

  if any? cows with [heifer? or cow?] [
    if mean [live-weight] of cows < ES-market-farmer-min-weight and count cows > keep-MIN-n-cattle [
      ;while [any? cows with [cow? or heifer? and pregnant? = false and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle] [         ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
      while [any? cows with [cow? or heifer? and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle] [
        if (extraordinary-sale-of-cows-with = "highest live weight") [
          ;ask max-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
          ask max-n-of 1 cows with [cow? or heifer? and sale? = false] [live-weight] [
            set sale? true
            set ES-heifer sum [value] of cows with [heifer? and sale?]
            set ES-cow sum [value] of cows with [cow? and sale?]]]

        if (extraordinary-sale-of-cows-with = "lowest live weight") [
          ;ask min-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
          ask min-n-of 1 cows with [cow? or heifer? and sale? = false] [live-weight] [
            set sale? true
            set ES-heifer sum [value] of cows with [heifer? and sale?]
            set ES-cow sum [value] of cows with [cow? and sale?]]]]]]

  ask cows with [sale?] [die]

end

to extraordinary-sale-males-environmental-farmer                                           ;; ## EXTRAORDINARY SALES MODULE ;; Extraordinary sale of male animals for the environmental farmer. If the enviromental-oriented farmer profile is selected, the extraordinary sale of male animals takes place when the Stocking Rate (SR) of the farm is above the desirable SR ("ES-env-farmer-SR" slider in the interface).

  if (spatial-management = "free grazing") [

    if any? cows with [weaned-calf-male?] [
      if sum [animal-units] of cows / count patches > ES-env-farmer-SR and count cows with [weaned-calf-male?] > keep-MAX-n-steers and count cows > keep-MIN-n-cattle [
        while [any? cows with [weaned-calf-male? and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle and sum [animal-units] of cows with [sale? = false] / count patches > ES-env-farmer-SR and count cows with [weaned-calf-male? and sale? = false] > keep-MAX-n-steers] [
          if (extraordinary-sale-of-cows-with = "highest live weight") [
            ask max-n-of 1 cows with [weaned-calf-male? and sale? = false] [live-weight] [
              set sale? true
              set ES-males-weaned-calf sum [value] of cows with [weaned-calf-male? and sale?]]]

          if (extraordinary-sale-of-cows-with = "lowest live weight") [
            ask min-n-of 1 cows with [weaned-calf-male? and sale? = false] [live-weight] [
              set sale? true
              set ES-males-weaned-calf sum [value] of cows with [weaned-calf-male? and sale?]]]]]]

    if any? cows with [steer?] [
      if sum [animal-units] of cows / count patches > ES-env-farmer-SR and count cows with [steer?] > keep-MAX-n-steers and count cows > keep-MIN-n-cattle [
        while [any? cows with [steer? and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle and sum [animal-units] of cows with [sale? = false] / count patches > ES-env-farmer-SR and count cows with [steer? and sale? = false] > keep-MAX-n-steers] [
          if (extraordinary-sale-of-cows-with = "highest live weight") [
            ask max-n-of 1 cows with [steer? and sale? = false] [live-weight] [
              set sale? true
              set ES-males-steer sum [value] of cows with [steer? and sale?]]]

          if (extraordinary-sale-of-cows-with = "lowest live weight") [
            ask min-n-of 1 cows with [steer? and sale? = false] [live-weight] [
              set sale? true
              set ES-males-steer sum [value] of cows with [steer? and sale?]]]]]]]




  if (spatial-management = "rotational grazing") [

    if any? cows with [weaned-calf-male?] [
      if sum [animal-units] of cows / (count patches / 4) > ES-env-farmer-SR and count cows with [weaned-calf-male?] > keep-MAX-n-steers and count cows > keep-MIN-n-cattle [
        while [any? cows with [weaned-calf-male? and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle and sum [animal-units] of cows with [sale? = false] / (count patches / 4) > ES-env-farmer-SR and count cows with [weaned-calf-male? and sale? = false] > keep-MAX-n-steers] [
          if (extraordinary-sale-of-cows-with = "highest live weight") [
            ask max-n-of 1 cows with [weaned-calf-male? and sale? = false] [live-weight] [
              set sale? true
              set ES-males-weaned-calf sum [value] of cows with [weaned-calf-male? and sale?]]]

          if (extraordinary-sale-of-cows-with = "lowest live weight") [
            ask min-n-of 1 cows with [weaned-calf-male? and sale? = false] [live-weight] [
              set sale? true
              set ES-males-weaned-calf sum [value] of cows with [weaned-calf-male? and sale?]]]]]]

    if any? cows with [steer?] [
      if sum [animal-units] of cows / (count patches / 4) > ES-env-farmer-SR and count cows with [steer?] > keep-MAX-n-steers and count cows > keep-MIN-n-cattle [
        while [any? cows with [steer? and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle and sum [animal-units] of cows with [sale? = false] / (count patches / 4) > ES-env-farmer-SR and count cows with [steer? and sale? = false] > keep-MAX-n-steers] [
          if (extraordinary-sale-of-cows-with = "highest live weight") [
            ask max-n-of 1 cows with [steer? and sale? = false] [live-weight] [
              set sale? true
              set ES-males-steer sum [value] of cows with [steer? and sale?]]]

          if (extraordinary-sale-of-cows-with = "lowest live weight") [
            ask min-n-of 1 cows with [steer? and sale? = false] [live-weight] [
              set sale? true
              set ES-males-steer sum [value] of cows with [steer? and sale?]]]]]]]


  ask cows with [sale?] [die]

  end

to extraordinary-sale-old-cows-environmental-farmer                                                               ;;## EXTRAORDINARY SALES MODULE ;; Extraordinary sale of old cows for the environmental farmer. The age at which a cow is considered old is determined by the "age-sell-old-cow" slider in the interface.

  if (spatial-management = "free grazing") [

    if any? cows with [cow? and age / 368 > age-sell-old-cow] [
      if sum [animal-units] of cows / count patches > ES-env-farmer-SR and count cows > keep-MIN-n-cattle [
        ;while [any? cows with [cow? and age / 368 > age-sell-old-cow and sale? = false and pregnant? = false] and sum [animal-units] of cows with [sale? = false] / count patches > ES-env-farmer-SR] [      ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
        while [any? cows with [cow? and age / 368 > age-sell-old-cow and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle and sum [animal-units] of cows with [sale? = false] / count patches > ES-env-farmer-SR] [
          if (extraordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask max-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and sale? = false] [live-weight] [
              set sale? true
              set ES-old-cow sum [value] of cows with [cow? and age / 368 > age-sell-old-cow and sale?]]]

          if (extraordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask min-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and sale? = false] [live-weight] [
              set sale? true
              set ES-old-cow sum [value] of cows with [cow? and age / 368 > age-sell-old-cow and sale?]]]]]]]



  if (spatial-management = "rotational grazing") [

    if any? cows with [cow? and age / 368 > age-sell-old-cow] [
      if sum [animal-units] of cows / (count patches / 4) > ES-env-farmer-SR and count cows > keep-MIN-n-cattle [
        ;while [any? cows with [cow? and age / 368 > age-sell-old-cow and sale? = false and pregnant? = false] and sum [animal-units] of cows with [sale? = false] / (count patches / 4) > ES-env-farmer-SR] [      ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
        while [any? cows with [cow? and age / 368 > age-sell-old-cow and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle and sum [animal-units] of cows with [sale? = false] / (count patches / 4) > ES-env-farmer-SR] [
          if (extraordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask max-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and sale? = false] [live-weight] [
              set sale? true
              set ES-old-cow sum [value] of cows with [cow? and age / 368 > age-sell-old-cow and sale?]]]



          if (extraordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask min-n-of 1 cows with [cow? and age / 368 > age-sell-old-cow and sale? = false] [live-weight] [
              set sale? true
              set ES-old-cow sum [value] of cows with [cow? and age / 368 > age-sell-old-cow and sale?]]]]]]]

  ask cows with [sale?] [die]

 end


to extraordinary-sale-heifers-cows-environmental-farmer                                           ;;## EXTRAORDINARY SALES MODULE ;; Extraordinary sale of heifers and cows for the environmental farmer.

  if (spatial-management = "free grazing") [

    if any? cows with [heifer? or cow?] [
      if sum [animal-units] of cows / count patches > ES-env-farmer-SR and count cows > keep-MIN-n-cattle [
        ;while [any? cows with [cow? or heifer? and pregnant? = false and sale? = false] and sum [animal-units] of cows with [sale? = false] / count patches > ES-env-farmer-SR] [         ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
        while [any? cows with [cow? or heifer? and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle and sum [animal-units] of cows with [sale? = false] / count patches > ES-env-farmer-SR] [
          if (extraordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask max-n-of 1 cows with [cow? or heifer? and sale? = false] [live-weight] [
              set sale? true
              set ES-heifer sum [value] of cows with [heifer? and sale?]
              set ES-cow sum [value] of cows with [cow? and sale?]]]

          if (extraordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask min-n-of 1 cows with [cow? or heifer? and sale? = false] [live-weight] [
              set sale? true
              set ES-heifer sum [value] of cows with [heifer? and sale?]
              set ES-cow sum [value] of cows with [cow? and sale?]]]]]]]



  if (spatial-management = "rotational grazing") [

    if any? cows with [heifer? or cow?] [
      if sum [animal-units] of cows / (count patches / 4) > ES-env-farmer-SR and count cows > keep-MIN-n-cattle [
        ;while [any? cows with [cow? or heifer? and pregnant? = false and sale? = false] and sum [animal-units] of cows with [sale? = false] / (count patches / 4) > ES-env-farmer-SR] [         ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
        while [any? cows with [cow? or heifer? and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle and sum [animal-units] of cows with [sale? = false] / (count patches / 4) > ES-env-farmer-SR] [
          if (extraordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask max-n-of 1 cows with [cow? or heifer? and sale? = false] [live-weight] [
              set sale? true
              set ES-heifer sum [value] of cows with [heifer? and sale?]
              set ES-cow sum [value] of cows with [cow? and sale?]]]

          if (extraordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask min-n-of 1 cows with [cow? or heifer? and sale? = false] [live-weight] [
              set sale? true
              set ES-heifer sum [value] of cows with [heifer? and sale?]
              set ES-cow sum [value] of cows with [cow? and sale?]]]]]]]



  ask cows with [sale?] [die]

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Farm balance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to farm-balance                                                                      ;;## ORDINARY SALES MODULE
  set ordinary-sales-income OS-males-weaned-calf + OS-males-steer + OS-old-cow + OS-heifer + OS-cow

  set extraordinary-sales-income ES-males-weaned-calf + ES-males-steer + ES-old-cow + ES-heifer + ES-cow

  set income ordinary-sales-income + extraordinary-sales-income
  set balance income - cost

  set OS-males-weaned-calf 0 set OS-males-steer 0 set OS-old-cow 0 set OS-heifer 0 set OS-cow 0
  set ES-males-weaned-calf 0 set ES-males-steer 0 set ES-old-cow 0 set ES-heifer 0 set ES-cow 0

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; REPORTERS (This section of the code contains the reporters that collect the model outputs)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report stocking-rate                                                              ;; outputs the relation between the number of livestock (in terms of animal units) and the total grassland area (num. of patches. 1 patch = 1 ha)
  report sum [animal-units] of cows / count patches
end

to-report paddock-SR
  if (spatial-management = "rotational grazing") [report sum [animal-units] of cows / (count patches / 4)]          ;; outputs the relation between the number of livestock (in terms of animal units) and the paddock area (num. of patches. 1 patch = 1 ha)
end

to-report paddock-size
  if (spatial-management = "rotational grazing") [report count patches / 4]          ;; outputs the paddock area when the rotational grazing management strategy is in effect
end

to-report grass-height-report                                                        ;; outputs the mean grass-height of the grassland
  report mean [grass-height] of patches
end

to-report season-report                                                              ;; outputs the name of the season
    report  item current-season current-season-name
end

 to-report dmgr                                                                      ;; outputs the Dry Matter Growth Rate (DMGR, units: kgDM/ha/day)
  report DM-cm-ha * sum [grass-height] of patches
end

to-report ALWG                                                                       ;; outputs the Annual Live Weight Gain per hectare (kg/year/ha)
  report (sum [live-weight] of cows - sum [initial-weight] of cows) / count patches
end

to-report ILWG                                                                       ;; outputs the mean Inidividual Live Weight Gain (kg/animal)
  report mean [live-weight-gain] of cows
end

to-report ILWG_SEASON                                                                ;; outputs the mean IWLG throughout the season
  report mean [live-weight-gain-historyXticks-season] of cows
end

to-report ILWG_YEAR                                                                  ;; outputs the mean IWLG throughout the year
  report mean [live-weight-gain-historyXticks-year] of cows
end

to-report crop-efficiency                                                            ;; outputs the crop eficiency (DM consumed / DM offered)
  report sum [DDMC] of cows / (DM-cm-ha * mean [grass-height] of patches) * 100
 end


to-report accumulated-balance                                                        ;;## ORDINARY SALES MODULE ;; outputs the accumulated balance of the system since the start of the simulation (USD)
    report balance-historyXticks
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; REFERENCES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Dieguez-Cameroni, F.J., et al. 2014. Virtual experiments using a participatory model to explore interactions between climatic variability
;; and management decisions in extensive systems in the basaltic region of Uruguay. Agricultural Systems 130: 89–104.

;; Dieguez-Cameroni, F., Bommel, P., Corral, J., Bartaburu, D., Pereira, M., Montes, E., Duarte, E., Morales-Grosskopf, H. 2012. Modelización
;; de una explotación ganadera extensiva criadora en basalto. Agrociencia Uruguay 16(2): 120-130.

;; Robins, R., Bogen, S., Francis, A., Westhoek, A., Kanarek, A., Lenhart, S., Eda, S. 2015. Agent-based model for Johne’s disease dynamics
;; in a dairy herd. Veterinary Research 46: 68.
@#$#@#$#@
GRAPHICS-WINDOW
401
108
968
676
-1
-1
55.9
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
29
11
84
44
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
94
12
149
45
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
10
665
200
698
initial-num-cows
initial-num-cows
0
1000
45.0
1
1
NIL
HORIZONTAL

SLIDER
89
278
191
311
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
2598
165
2936
376
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
2191
740
2519
960
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
659
12
737
57
Time (days)
simulation-time
2
1
11

MONITOR
406
683
532
728
Stoking rate (AU/ha)
stocking-rate
4
1
11

PLOT
1207
885
1556
1058
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
11
987
148
1020
perception
perception
0
1
0.5
0.1
1
NIL
HORIZONTAL

MONITOR
646
703
775
748
Total number of cattle
count cows
7
1
11

MONITOR
2521
740
2707
785
Average LW (kg/animal)
mean [live-weight] of cows
3
1
11

SLIDER
204
127
355
160
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
2204
163
2590
378
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
13
268
83
324
0 = winter\n1 = spring\n2 = summer\n3 = fall
11
0.0
1

MONITOR
2600
377
2726
422
Average GH (cm/ha)
grass-height-report
3
1
11

MONITOR
478
12
565
57
Season
season-report
17
1
11

MONITOR
572
12
654
57
Time (years)
simulation-time / 368
3
1
11

SLIDER
10
743
202
776
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
10
777
201
810
initial-weight-heifers
initial-weight-heifers
100
1500
200.0
1
1
kg
HORIZONTAL

MONITOR
400
12
473
57
Area (ha)
;count patches ;grassland-area, 1 patch = 1 ha\n; Other option:\n; sum [animal-units] of cows / count patches\ncount patches
3
1
11

PLOT
2821
733
3279
960
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
"Cow-with-calf" 1.0 0 -5825686 true "" "plot mean [live-weight-gain] of cows with [cow-with-calf?]"
"Average LWG" 1.0 0 -16777216 true "" "plot mean [live-weight-gain] of cows"

PLOT
2945
165
3271
376
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
2947
377
3003
422
CE (%)
crop-efficiency
2
1
11

MONITOR
2204
418
2353
463
Total DDMC (kg)
sum [DDMC] of cows
3
1
11

MONITOR
2353
418
2527
463
Average DDMC (kg/animal)
mean [DDMC] of cows
3
1
11

BUTTON
7
51
69
84
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
698
200
731
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
2204
480
2591
674
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
"Cow" 1.0 0 -6459832 true "" "plot (mean [live-weight] of cows with [cow?] - set-MW-1-AU) / 40"
"Cow-with-calf" 1.0 0 -5825686 true "" "plot (mean [live-weight] of cows with [cow-with-calf?] - set-MW-1-AU) / 40"

MONITOR
2261
673
2391
718
BCS of cows (points)
;(mean [live-weight] of cows with [cow?] - mean [min-weight] of cows with [cow?]) / 40\n;(mean [live-weight] of cows with [cow?] - (((mean [live-weight] of cows with [cow?]) * set-MW-1-AU) / set-1-AU)) / 40\n(mean [live-weight] of cows with [cow?] - set-MW-1-AU) / 40
2
1
11

PLOT
2627
480
3037
673
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

MONITOR
2627
673
2759
718
PR of cows (%)
mean [pregnancy-rate] of cows with [cow?] * 100
2
1
11

MONITOR
2758
673
2901
718
PR of cows-with-calf (%)
mean [pregnancy-rate] of cows with [cow-with-calf?] * 100
2
1
11

MONITOR
2901
673
3038
718
PR of heifers (%)
mean [pregnancy-rate] of cows with [heifer?] * 100
2
1
11

MONITOR
2204
377
2353
422
Total DM (kg)
dmgr
3
1
11

MONITOR
2521
783
2707
828
Average ILWG (kg/animal/day)
;mean [live-weight-gain] of cows\nILWG
3
1
11

MONITOR
2391
673
2546
718
BCS of cows-with-calf (points)
;(mean [live-weight] of cows with [cow-with-calf?] - mean [min-weight] of cows with [cow-with-calf?]) / 40\n;(mean [live-weight] of cows with [cow-with-calf?] - (((mean [live-weight] of cows with [cow-with-calf?]) * set-MW-1-AU) / set-1-AU)) / 40\n\n(mean [live-weight] of cows with [cow-with-calf?] - set-MW-1-AU) / 40
2
1
11

MONITOR
2518
871
2749
916
Average LW of cows (kg/animal)
mean [live-weight] of cows with [cow?]
3
1
11

MONITOR
2521
916
2750
961
Average ILWG of cows (kg/animal/day)
mean [live-weight-gain] of cows with [cow?]
3
1
11

SLIDER
10
824
202
857
initial-num-steers
initial-num-steers
0
1000
15.0
1
1
NIL
HORIZONTAL

SLIDER
10
855
202
888
initial-weight-steers
initial-weight-steers
100
1500
300.0
1
1
kg
HORIZONTAL

SLIDER
11
137
148
170
set-X-size
set-X-size
2
100
10.0
1
1
hm
HORIZONTAL

SLIDER
11
176
147
209
set-Y-size
set-Y-size
2
100
10.0
1
1
hm
HORIZONTAL

TEXTBOX
15
118
106
138
GRAZING AREA
12
0.0
1

MONITOR
533
684
647
729
Area (ha)
count patches
17
1
11

SLIDER
4520
21
4618
54
set-1-AU
set-1-AU
1
1500
380.0
1
1
kg
HORIZONTAL

SLIDER
4621
21
4742
54
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
1005
885
1207
1057
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
4284
233
4492
278
Average ILWG (kg/animal/day)
;mean [live-weight-gain] of cows\nILWG
13
1
11

MONITOR
4284
286
4542
331
Average LWG since the start of the SEASON
;mean [live-weight-gain-historyXticks-season] of cows; Average LWG SEASON\nILWG_SEASON
13
1
11

MONITOR
4280
398
4483
443
NIL
max [count cows-here] of patches
17
1
11

OUTPUT
926
10
1126
55
12

BUTTON
1136
15
1291
48
setup_seed-1070152876 
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
2518
828
2820
873
Average annual live weight gain per hectare (ALWG, kg/ha)
;(sum [live-weight] of cows with [steer?] - sum [initial-weight] of cows with [steer?]) / count patches; para calcular el WGH de los steers\n;(sum [live-weight] of cows - sum [initial-weight] of cows) / count patches\nALWG
3
1
11

MONITOR
832
12
916
57
NIL
year-days
17
1
11

MONITOR
745
12
828
57
NIL
season-days
17
1
11

MONITOR
4280
333
4539
378
Average LWG since the start of the YEAR
;mean [live-weight-gain-historyXticks-year] of cows; Average LWG YEAR\nILWG_YEAR
13
1
11

MONITOR
2353
377
2527
422
Total DM per ha (kg/ha)
;(DM-cm-ha * mean [grass-height] of patches) / DM-available-for-cattle\n(dmgr) / count patches
3
1
11

MONITOR
4545
248
4635
293
ALWG (kg/ha)
;(sum [live-weight] of cows with [steer?] - sum [initial-weight] of cows with [steer?]) / count patches; para calcular el WGH de los steers\n;(sum [live-weight] of cows - sum [initial-weight] of cows) / count patches\nALWG
3
1
11

MONITOR
4656
131
4773
176
BCS of cows (points)
;(mean [live-weight] of cows with [cow?] - mean [min-weight] of cows with [cow?]) / 40\n;(mean [live-weight] of cows with [cow?] - (((mean [live-weight] of cows with [cow?]) * set-MW-1-AU) / set-1-AU)) / 40\n(mean [live-weight] of cows with [cow?] - set-MW-1-AU) / 40
2
1
11

MONITOR
4656
177
4760
222
PR of cows (%)
;mean [pregnancy-rate] of cows with [cow?] * 368 * 100\nmean [pregnancy-rate] of cows with [cow?] * 100
2
1
11

SLIDER
192
12
372
45
STOP-SIMULATION-AT
STOP-SIMULATION-AT
0
100
10.0
1
1
years
HORIZONTAL

CHOOSER
204
201
355
246
soil-quality-distribution
soil-quality-distribution
"homogeneus" "uniform" "normal" "exponential_low" "exponential_high"
0

PLOT
4286
750
4621
964
Grass height distribution
cm
nº patches
0.0
35.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [grass-height] of patches"

MONITOR
4287
966
4434
1011
min grass-height of patches
min [grass-height] of patches
17
1
11

MONITOR
4453
967
4624
1012
max grass-height of patches
max [grass-height] of patches
17
1
11

CHOOSER
9
560
127
605
spatial-management
spatial-management
"free grazing" "rotational grazing"
0

CHOOSER
131
561
230
606
starting-paddock
starting-paddock
"paddock a" "paddock b" "paddock c" "paddock d"
0

MONITOR
401
60
515
105
Paddock area (ha)
paddock-size
3
1
11

SLIDER
203
163
355
196
set-DM-cm-ha
set-DM-cm-ha
1
180
90.0
1
1
kg/cm/ha
HORIZONTAL

SLIDER
11
901
202
934
initial-num-weaned-calves
initial-num-weaned-calves
0
1000
0.0
1
1
NIL
HORIZONTAL

SLIDER
10
936
202
969
initial-weight-weaned-calves
initial-weight-weaned-calves
0
200
150.0
1
1
kg
HORIZONTAL

SLIDER
4
337
194
370
winter-length
winter-length
0
368 - spring-length - summer-length - fall-length
368.0
1
1
days
HORIZONTAL

SLIDER
208
335
388
368
spring-length
spring-length
0
368 - winter-length - summer-length - fall-length
0.0
1
1
days
HORIZONTAL

SLIDER
5
432
195
465
summer-length
summer-length
0
368 - spring-length - winter-length - fall-length
0.0
1
1
days
HORIZONTAL

SLIDER
205
432
388
465
fall-length
fall-length
0
368 - spring-length - winter-length - summer-length
0.0
1
1
days
HORIZONTAL

SLIDER
4
370
194
403
winter-climacoef-homogeneus
winter-climacoef-homogeneus
0.1
1.5
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
208
368
388
401
spring-climacoef-homogeneus
spring-climacoef-homogeneus
0.1
1.5
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
4
465
195
498
summer-climacoef-homogeneus
summer-climacoef-homogeneus
0.1
1.5
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
205
465
388
498
fall-climacoef-homogeneus
fall-climacoef-homogeneus
0.1
1.5
1.0
0.1
1
NIL
HORIZONTAL

TEXTBOX
12
250
162
268
SEASONS AND CLIMATE
12
0.0
1

TEXTBOX
204
94
353
124
INITIAL GRASS HEIGHT \nAND SOIL QUALITY
12
0.0
1

MONITOR
1565
123
1629
168
NIL
climacoef
2
1
11

PLOT
1010
80
1564
217
climacoef
NIL
NIL
0.0
10.0
0.0
1.5
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot climacoef"

TEXTBOX
11
534
239
564
RESOURCE MANAGEMENT STRATEGIES
12
0.0
1

TEXTBOX
11
628
187
658
INITIAL LIVESTOCK NUMBERS\nAND WEIGHT
12
0.0
1

CHOOSER
210
273
338
318
climacoef-distribution
climacoef-distribution
"homogeneus" "uniform" "normal" "exponential_low" "exponential_high" "historic-climacoef" "test-climacoef"
0

BUTTON
168
51
256
84
Go (1 year)
go\nif year-days = 368 [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
76
50
162
83
Go (1 season)
go\nif current-season = 0 [if season-days >= winter-length [stop]]\nif current-season = 1 [if season-days >= spring-length [stop]]\nif current-season = 2 [if season-days >= summer-length [stop]]\nif current-season = 3 [if season-days >= fall-length [stop]]
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
1009
230
1248
275
Yearly ordinary sales (OS)  income (USD)
ordinary-sales-income
3
1
11

SLIDER
214
825
399
858
keep-MAX-n-steers
keep-MAX-n-steers
0
100
5.0
1
1
NIL
HORIZONTAL

PLOT
1009
277
1636
427
Yearly income
Days
USD
0.0
368.0
0.0
10.0
true
true
"" ""
PENS
"OS income" 1.0 0 -13840069 true "" "plot ordinary-sales-income"
"ES income" 1.0 0 -2674135 true "" "plot extraordinary-sales-income"

MONITOR
1010
440
1180
485
Yearly balance (USD)
balance
3
1
11

PLOT
1012
489
1576
639
Yearly balance
Days
USD
0.0
368.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot balance"

SLIDER
214
788
400
821
keep-MAX-n-cattle
keep-MAX-n-cattle
0
500
50.0
1
1
NIL
HORIZONTAL

SLIDER
214
749
401
782
age-sell-old-cow
age-sell-old-cow
4
15
7.0
1
1
years
HORIZONTAL

CHOOSER
222
683
374
728
farmer-profile
farmer-profile
"none" "traditional" "market" "environmental"
3

SLIDER
418
927
637
960
ES-env-farmer-SR
ES-env-farmer-SR
0
2
0.5
0.01
1
AU/ha
HORIZONTAL

TEXTBOX
229
643
379
673
LIVESTOCK MANAGEMENT STRATEGIES
12
0.0
1

SLIDER
1573
78
1703
111
set-test-climacoef
set-test-climacoef
0.1
1.5
1.0
0.1
1
NIL
HORIZONTAL

MONITOR
1688
223
1866
268
meat production (kg/ha)
sum [live-weight] of cows / count patches
3
1
11

PLOT
1688
269
2193
419
meat production 
days
kg/ha
0.0
92.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [live-weight] of cows / count patches"

SLIDER
214
895
399
928
early-weaning-threshold
early-weaning-threshold
180
300
200.0
1
1
kg
HORIZONTAL

SLIDER
4317
22
4500
55
controlled-breeding-season
controlled-breeding-season
0
3
2.0
1
1
NIL
HORIZONTAL

CHOOSER
410
784
596
829
ordinary-sale-of-cows-with
ordinary-sale-of-cows-with
"highest live weight" "lowest live weight"
1

MONITOR
1014
639
1193
684
Accumulated balance (USD)
accumulated-balance
3
1
11

PLOT
1009
708
1574
858
Accumulated balance
Days
USD
0.0
368.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot accumulated-balance"

MONITOR
1249
232
1514
277
Yearly extraordinary sales (ES)  income (USD)
extraordinary-sales-income
3
1
11

MONITOR
683
65
833
110
steers
count cows with [steer?]
17
1
11

CHOOSER
410
833
594
878
extraordinary-sale-of-cows-with
extraordinary-sale-of-cows-with
"highest live weight" "lowest live weight"
1

MONITOR
859
64
919
109
old cows
count cows with [cow? and age / 368 > age-sell-old-cow and sale? = false]
17
1
11

SLIDER
418
967
636
1000
ES-market-farmer-min-weight
ES-market-farmer-min-weight
0
500
250.0
1
1
kg
HORIZONTAL

SLIDER
214
860
399
893
keep-MIN-n-cattle
keep-MIN-n-cattle
0
500
10.0
1
1
NIL
HORIZONTAL

MONITOR
646
955
803
1000
NIL
mean [live-weight] of cows
3
1
11

SLIDER
213
966
410
999
RG-live-weight-threshold
RG-live-weight-threshold
180
300
255.0
1
1
kg
HORIZONTAL

MONITOR
407
727
533
772
SR paddock (AU/ha)
paddock-SR
4
1
11

SLIDER
213
932
399
965
RG-SR-threshold
RG-SR-threshold
0
2
0.3
0.01
1
AU/ha
HORIZONTAL

MONITOR
532
727
647
772
Paddock area (ha)
paddock-size
3
1
11

MONITOR
563
63
663
108
NIL
ticks-since-here
17
1
11

SLIDER
212
1004
410
1037
RG-days-in-paddock
RG-days-in-paddock
0
368
31.0
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
  <experiment name="SA_set-X-size" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <steppedValueSet variable="set-X-size" first="10" step="5" last="50"/>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_initial-grass-height" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-grass-height" first="1" step="1" last="7"/>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_set-DM-cm-ha" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="1"/>
      <value value="20"/>
      <value value="40"/>
      <value value="60"/>
      <value value="80"/>
      <value value="100"/>
      <value value="120"/>
      <value value="140"/>
      <value value="160"/>
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_soil-quality-distribution" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
      <value value="&quot;uniform&quot;"/>
      <value value="&quot;normal&quot;"/>
      <value value="&quot;exponential_low&quot;"/>
      <value value="&quot;exponential_high&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_initial-season" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
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
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_climacoef_distribution" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
      <value value="&quot;uniform&quot;"/>
      <value value="&quot;normal&quot;"/>
      <value value="&quot;exponential_low&quot;"/>
      <value value="&quot;exponential_high&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_climacoef_0.5" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_climacoef_1" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_climacoef_1.5" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_spatial_management" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
      <value value="&quot;rotational grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_initial-num-cows" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-num-cows" first="10" step="20" last="200"/>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_initial-weight-cows" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-weight-cows" first="140" step="20" last="480"/>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_perception" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <steppedValueSet variable="perception" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_climacoef_0.3" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="0.3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_climacoef_0.7" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="0.7"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_climacoef_1.2" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>mean [grass-height] of patches ; mean cm of grass-height per ha</metric>
    <metric>(dmgr) / count patches ; mean kg of DM per ha</metric>
    <metric>dmgr ; TOTAL kg of DM</metric>
    <metric>sum [DDMC] of cows ; TOTAL consumption of DM</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>crop-efficiency</metric>
    <metric>mean [DDMC] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1.2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="PR_soil-quality-distribution" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>stocking-rate</metric>
    <metric>(dmgr) / count patches</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
      <value value="&quot;uniform&quot;"/>
      <value value="&quot;normal&quot;"/>
      <value value="&quot;exponential_low&quot;"/>
      <value value="&quot;exponential_high&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="PR_climacoef-distribution" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>stocking-rate</metric>
    <metric>(dmgr) / count patches</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
      <value value="&quot;uniform&quot;"/>
      <value value="&quot;normal&quot;"/>
      <value value="&quot;exponential_low&quot;"/>
      <value value="&quot;exponential_high&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="PR_spatial-management" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>stocking-rate</metric>
    <metric>(dmgr) / count patches</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
      <value value="&quot;rotational grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="PR_initial-num-cows" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>stocking-rate</metric>
    <metric>(dmgr) / count patches</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-num-cows" first="10" step="20" last="200"/>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="PR_soil-quality-distribution_HOMOGEN_climacoef-distribution_spatial-management" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>stocking-rate</metric>
    <metric>(dmgr) / count patches</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
      <value value="&quot;rotational grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
      <value value="&quot;uniform&quot;"/>
      <value value="&quot;normal&quot;"/>
      <value value="&quot;exponential_low&quot;"/>
      <value value="&quot;exponential_high&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="PR_soil-quality-distribution_UNIFORM_climacoef-distribution_spatial-management" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>stocking-rate</metric>
    <metric>(dmgr) / count patches</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
      <value value="&quot;rotational grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;uniform&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
      <value value="&quot;uniform&quot;"/>
      <value value="&quot;normal&quot;"/>
      <value value="&quot;exponential_low&quot;"/>
      <value value="&quot;exponential_high&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="PR_soil-quality-distribution_NORMAL_climacoef-distribution_spatial-management" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>stocking-rate</metric>
    <metric>(dmgr) / count patches</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
      <value value="&quot;rotational grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;normal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
      <value value="&quot;uniform&quot;"/>
      <value value="&quot;normal&quot;"/>
      <value value="&quot;exponential_low&quot;"/>
      <value value="&quot;exponential_high&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="PR_soil-quality-distribution_EXP-LOW_climacoef-distribution_spatial-management" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>stocking-rate</metric>
    <metric>(dmgr) / count patches</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
      <value value="&quot;rotational grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;exponential_low&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
      <value value="&quot;uniform&quot;"/>
      <value value="&quot;normal&quot;"/>
      <value value="&quot;exponential_low&quot;"/>
      <value value="&quot;exponential_high&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="PR_soil-quality-distribution_EXP-HIGH_climacoef-distribution_spatial-management" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
    <metric>count cows</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>mean [grass-height] of patches</metric>
    <metric>stocking-rate</metric>
    <metric>(dmgr) / count patches</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
      <value value="&quot;rotational grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;exponential_high&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
      <value value="&quot;uniform&quot;"/>
      <value value="&quot;normal&quot;"/>
      <value value="&quot;exponential_low&quot;"/>
      <value value="&quot;exponential_high&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SB_Fig2" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="92"/>
    <metric>simulation-time</metric>
    <metric>season-report</metric>
    <metric>dmgr / count patches ;DM/ha</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-test-climacoef">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-cattle">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;none&quot;"/>
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
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-SR">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;test-climacoef&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-steers">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SB_Fig3" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="92"/>
    <metric>initial-grass-height</metric>
    <metric>set-test-climaCoef</metric>
    <metric>season-report</metric>
    <metric>dmgr / count patches ;DM/ha</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-test-climacoef">
      <value value="0.5"/>
      <value value="1"/>
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-cattle">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;none&quot;"/>
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
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-SR">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="3"/>
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;test-climacoef&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-steers">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SB_Fig4" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="92"/>
    <metric>set-test-climaCoef</metric>
    <metric>season-report</metric>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>ILWG_SEASON</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-test-climacoef">
      <value value="0.5"/>
      <value value="1"/>
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-cattle">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="30"/>
      <value value="45"/>
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-SR">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;test-climacoef&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-steers">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SB_Fig5" repetitions="10" runMetricsEveryStep="false">
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
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-test-climacoef">
      <value value="0.5"/>
      <value value="1"/>
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-cattle">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-num-steers" first="0" step="2" last="100"/>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-SR">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;test-climacoef&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-steers">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SB_Fig6" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="368"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>crop-efficiency</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-test-climacoef">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-cattle">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-num-steers" first="0" step="2" last="100"/>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-SR">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;test-climacoef&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-steers">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SB_Fig6_v2" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="92"/>
    <metric>count cows</metric>
    <metric>stocking-rate</metric>
    <metric>crop-efficiency</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-test-climacoef">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-cattle">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-num-steers" first="0" step="2" last="100"/>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-SR">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;test-climacoef&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-steers">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SB_Fig8" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="644"/>
    <metric>season-report</metric>
    <metric>climacoef</metric>
    <metric>grass-height-report</metric>
    <metric>ILWG</metric>
    <metric>stocking-rate</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-test-climacoef">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-cattle">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="300"/>
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-SR">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;historic-climacoef&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-steers">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_Ordinary-sales_ENV-SR" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3680"/>
    <metric>balance</metric>
    <metric>count cows</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>sum [live-weight] of cows</metric>
    <metric>stocking-rate</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-test-climacoef">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-cattle">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;traditional&quot;"/>
      <value value="&quot;market&quot;"/>
      <value value="&quot;environmental&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-SR">
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-steers">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_Ordinary-sales_ENV-SR-1" repetitions="200" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3680"/>
    <metric>balance</metric>
    <metric>count cows</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>sum [live-weight] of cows</metric>
    <metric>stocking-rate</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-test-climacoef">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-cattle">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;market&quot;"/>
      <value value="&quot;environmental&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-SR">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-steers">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_Ordinary-sales_ENV-SR-0.5" repetitions="200" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3680"/>
    <metric>balance</metric>
    <metric>count cows</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>sum [live-weight] of cows</metric>
    <metric>stocking-rate</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-test-climacoef">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-cattle">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;market&quot;"/>
      <value value="&quot;environmental&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-SR">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-n-steers">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA_Breeding-seasons" repetitions="200" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3680"/>
    <metric>count cows</metric>
    <metric>mean [live-weight] of cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-test-climacoef">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;market&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-weaning-threshold">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-quality-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-paddock">
      <value value="&quot;paddock a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-SR">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MAX-n-cattle">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MAX-n-steers">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;homogeneus&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="controlled-breeding-season">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
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
