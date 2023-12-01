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
  direct-climacoef-control                                                          ;; allows the user to change the climate coefficient in real time (i.e. while the simulation is running)

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

  carrying-capacity                                                                 ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  estimated-kmax                                                                    ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW variable usada por el environmental farmer para estimar la K (en cm) del sistema
  estimated-DM-cm-ha                                                                ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW variable usada por el environmental farmer para estimar los kgMS del sistema
  estimated-carrying-capacity                                                       ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW variable usada por el environmental farmer para estimar la capacidad de carga del sistema

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Livestock related global variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  maxLWG                                                                            ;; defines the maximum live weight gain per animal according to the season: spring = 60 Kg/animal; winter, summer and fall = 40 Kg/animal.

  maxLWcow                                                                          ;; defines the maximum live weight for cows (650 kg)
  maxLWbull                                                                         ;; defines the maximum live weight for steers and bulls (1000 kg)

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

  days-until-breeding-season                                                        ;; NEWWWWWWWWWWWWWWW;; FEED SUPPLEMENTATION (FOR BREEDING) MODULE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Market prices & economic balance global variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  supplement-prices                                                                 ;;## SALES MODULE ;; costs for feeding the animals with food supplements (grains, USD/Kg).
  born-calf-prices                                                                  ;;## SALES MODULE ;; market prices per kg for born calves (USD/Kg).
  weaned-calf-prices                                                                ;;## SALES MODULE ;; market prices per kg for weaned calves (USD/Kg).
  steer-prices                                                                      ;;## SALES MODULE ;; market prices per kg for steers (USD/Kg).
  heifer-prices                                                                     ;;## SALES MODULE ;; market prices per kg for empty heifers (USD/Kg).
  cow-prices                                                                        ;;## SALES MODULE ;; market prices per kg for empty cows (USD/Kg).
  cow-with-calf-prices                                                              ;;## SALES MODULE ;; market prices per kg for lactating cows (USD/Kg).
  pregnant-prices                                                                   ;;## SALES MODULE ;; market prices per kg for pregnant cows (USD/Kg).

  bull-prices                                                                       ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


  OS-females-weaned-calf                                                            ;;FEMALESALESNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


  OS-males-weaned-calf                                                              ;;## ORDINARY SALES MODULE ;; income from the sale of male weaned calves during ordinary sales.
  OS-males-steer                                                                    ;;## ORDINARY SALES MODULE ;; income from the sale of steers during ordinary sales.
  OS-old-cow                                                                        ;;## ORDINARY SALES MODULE ;; income from the sale of old cows during ordinary sales.
  OS-heifer                                                                         ;;## ORDINARY SALES MODULE ;; income from the sale of heifers during ordinary sales.
  OS-cow                                                                            ;;## ORDINARY SALES MODULE ;; income from the sale of cows during ordinary sales.

  OS-bull                                                                           ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  OS-old-bull




  ES-females-weaned-calf                                                            ;;FEMALESALESNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ES-males-weaned-calf                                                              ;;## EXTRAORDINARY SALES MODULE ;; income from the sale of male weaned calves during extraordinary sales.
  ES-males-steer                                                                    ;;## EXTRAORDINARY SALES MODULE ;; income from the sale of steers during extraordinary sales.
  ES-old-cow                                                                        ;;## EXTRAORDINARY SALES MODULE ;; income from the sale of old cows during extraordinary sales.
  ES-heifer                                                                         ;;## EXTRAORDINARY SALES MODULE ;; income from the sale of heifers during extraordinary sales.
  ES-cow                                                                            ;;## EXTRAORDINARY SALES MODULE ;; income from the sale of empty cows during extraordinary sales.

  ES-bull                                                                           ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ordinary-sales-income                                                             ;;## ORDINARY SALES MODULE ;; total income from ordinary sales
  extraordinary-sales-income                                                        ;;## EXTRAORDINARY SALES MODULE ;; total income from extraordinary sales

  FS-cow                                                                            ;;## FEED SUPPLEMENTATION MODULE ;; cost of supplementing adult cows
  FS-cow-with-calf                                                                  ;;## FEED SUPPLEMENTATION MODULE ;; cost of supplementing cows with calves
  FS-heifer                                                                         ;;## FEED SUPPLEMENTATION MODULE ;; cost of supplementing heifers
  FS-steer                                                                          ;;## FEED SUPPLEMENTATION MODULE ;; cost of supplementing steers
  FS-weaned-calf                                                                    ;;## FEED SUPPLEMENTATION MODULE ;; cost of supplementing weaned calves

  FS-bull                                                                           ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  supplement-cost                                                                   ;;## FEED SUPPLEMENTATION MODULE ;; total cost of feed supplementation

  FSB-cow                                                                           ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW ;; Feed supplementation for breeding cows

  other-cost                                                                        ;;## SALES MODULE ;; other costs associated with the livestock system

  cost                                                                              ;;## SALES MODULE ;; total costs resulting from the livestock system (supplement cost + other cost)
  income                                                                            ;;## SALES MODULE ;; total income (ordinary + extraordinary sales)
  balance                                                                           ;;## SALES MODULE ;; balance (income - cost)

  cost-history                                                                      ;;## SALES MODULE ;; variable to store the cost history of the system
  cost-historyXticks                                                                ;;## SALES MODULE ;; costs of the system since the start of the simulation

  income-history                                                                    ;;## SALES MODULE ;; variable to store the income history of the system
  income-historyXticks                                                              ;;## SALES MODULE ;; income of the system since the start of the simulation

  balance-history                                                                   ;;## SALES MODULE ;; variable to store the balance history of the system
  balance-historyXticks                                                             ;;## SALES MODULE ;; balance of the system since the start of the simulation (i.e., savings)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Wellbeing related global variables                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  supplement-effort                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  supplement-effort-history
  supplement-effort-historyXticks

  supplement-effort-history-season                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  supplement-effort-historyXticks-season                                         ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  supplement-effort-history-year                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  supplement-effort-historyXticks-year                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW






  weaning-effort

  weaning-effort-history                                                  ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  weaning-effort-historyXticks

  weaning-effort-history-season                                                  ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  weaning-effort-historyXticks-season                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  weaning-effort-history-year                                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  weaning-effort-historyXticks-year                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW







  OS-males-effort                                                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  OS-males-effort-history                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  OS-males-effort-historyXticks

  OS-males-effort-history-season                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  OS-males-effort-historyXticks-season                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  OS-males-effort-history-year                                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  OS-males-effort-historyXticks-year                                             ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW







  OS-old-cow-effort                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  OS-old-cow-effort-history                                                      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  OS-old-cow-effort-historyXticks

  OS-old-cow-effort-history-season                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  OS-old-cow-effort-historyXticks-season                                         ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  OS-old-cow-effort-history-year                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  OS-old-cow-effort-historyXticks-year                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW








  OS-old-bull-effort

  OS-old-bull-effort-history
  OS-old-bull-effort-historyXticks

  OS-old-bull-effort-history-season
  OS-old-bull-effort-historyXticks-season
  OS-old-bull-effort-history-year
  OS-old-bull-effort-historyXticks-year










  OS-females-effort                                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  OS-females-effort-history                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  OS-females-effort-historyXticks

  OS-females-effort-history-season                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  OS-females-effort-historyXticks-season                                      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  OS-females-effort-history-year                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  OS-females-effort-historyXticks-year                                        ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW







  OS-total-effort                                                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  OS-total-effort-history

  OS-total-effort-history-season                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  OS-total-effort-history-year                                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW







  ES-males-effort                                                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ES-males-effort-history                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ES-males-effort-historyXticks

  ES-males-effort-history-season                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ES-males-effort-historyXticks-season                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ES-males-effort-history-year                                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ES-males-effort-historyXticks-year                                             ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW







  ES-old-cow-effort                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ES-old-cow-effort-history                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ES-old-cow-effort-historyXticks

  ES-old-cow-effort-history-season                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ES-old-cow-effort-historyXticks-season                                         ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ES-old-cow-effort-history-year                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ES-old-cow-effort-historyXticks-year                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW







  ES-females-effort                                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ES-females-effort-history                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ES-females-effort-historyXticks

  ES-females-effort-history-season                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ES-females-effort-historyXticks-season                                      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ES-females-effort-history-year                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ES-females-effort-historyXticks-year                                        ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW







  ES-total-effort                                                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ES-total-effort-history                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ES-total-effort-history-season                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ES-total-effort-history-year                                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW







  breeding-effort

  breeding-effort-history                                                  ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  breeding-effort-historyXticks

  breeding-effort-history-season                                                  ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  breeding-effort-historyXticks-season                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  breeding-effort-history-year                                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  breeding-effort-historyXticks-year                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW









  rotational-effort                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  rotational-effort-history                                                  ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  rotational-effort-historyXticks

  rotational-effort-history-season                                                  ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  rotational-effort-historyXticks-season                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  rotational-effort-history-year                                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  rotational-effort-historyXticks-year                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW





  other-daily-effort                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  other-daily-effort-history                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  other-daily-effort-historyXticks                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  other-daily-effort-history-season                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  other-daily-effort-historyXticks-season                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  other-daily-effort-history-year                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  other-daily-effort-historyXticks-year                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW





  total-effort                                                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  total-effort-history

  total-effort-history-season                                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  total-effort-history-year                                                      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Patch variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
patches-own [
  grass-height                                                                      ;; primary production (biomass), expressed in centimeters
  soil-quality                                                                      ;; affects the maximum grass height that can be achieved in a patch
  r                                                                                 ;; growth rate for the grass = 0.02 1/day
  GH-consumed                                                                       ;; grass-height consumed by all cows
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

  bull?                                                                             ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  old?                                                                              ;; OLDNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  animal-units                                                                      ;; variable used to calculate the stocking rate. AU = LW / 380
  category-coef                                                                     ;; coefficient that varies with age class and affects the grass consumption of animals. Equal to 1 in all age classes, except for cow-with-calf = 1.1
  initial-weight                                                                    ;; initial weight of the animal at the beginning of the simulation. Set by the observer in the interface
  min-weight                                                                        ;; defines the critical weight which below the animal can die by forage crisis

  live-weight                                                                       ;; variable that defines the state of the animals in terms of live weight


  live-weight-gain                                                                  ;; defines the increment of weight.

  live-weight-gain-feed                                                             ;;NEWWWWWWWWWWWWW ;;FEED SUPPLEMENTATION MODULE ;; define el incremento de peso
  live-weight-gain-feed-breeding

  live-weight-gain-max                                                              ;;NEWWWWWWWWWWWWW ;;FEED SUPPLEMENTATION MODULE ;; con esta variable calculamos el LWG máximo que puede ganar el animal en un día.

  live-weight-gain-history                                                          ;;NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  live-weight-gain-historyXticks                                                    ;;NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  live-weight-gain-history-season                                                   ;; variable to store the live weight gain during a season
  live-weight-gain-historyXticks-season                                             ;; live weight gain since start of season
  live-weight-gain-history-year                                                     ;; variable to store the live weight gain during 368 days (a year)
  live-weight-gain-historyXticks-year                                               ;; live weight gain since start of year
  DM-kg-cow                                                                         ;; biomass available (not consumed!) for one cow

  DDMC                                                                              ;; Daily Dry Matter Consumption. Is the biomass consumed by one cow

  DDMC-history
  DDMC-historyXticks

  DDMC-history-season
  DDMC-historyXticks-season
  DDMC-history-year
  DDMC-historyXticks-year



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

  supplemented?                                                                     ;;## FEED SUPPLEMENTATION MODULE ;; boolean variable that indicates whether or not the animal has been selected for feed supplementation
  difference-LW                                                                     ;;## FEED SUPPLEMENTATION MODULE ;; variable to know how many kilos the animal selected for supplementation is below the threshold ("xxxx-min-weight-for-feed-sup" sliders in the interface) at which it will be supplemented.

  difference-LW-breeding                                                            ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  kg-supplement-DM                                                                  ;;## FEED SUPPLEMENTATION MODULE ;; kg of supplementary feed required by the animal
  USD-supplement-DM                                                                 ;;## FEED SUPPLEMENTATION MODULE ;; the price of the feed supplement that is required by the animal(USD)

  kg-supplement-DM-breeding                                                         ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  USD-supplement-DM-breeding                                                        ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


  weaning-calf?                                                                     ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

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
  set season-coef [1 1.15 1.05 1]
  set maxLWG [40 60 40 40]

  set maxLWcow 650
  set maxLWbull 1000

  set current-season initial-season                                                 ;; the initial season is set by the observer in the interface
  set historic-climacoef [0.48 0.3 0.72 0.12 0.71 0.65 1.1]                         ;; historic climacoef values. One value = 1 season (for example, 7 values = 7 seasons, the simulation will stop after season 7). Replace these values with historical values. For the model to use "historic-climacoef" values, the observer must select the "historic-climacoef" option within the "climacoef-distribution" chooser in the interface.

  set supplement-prices [0.113 0.121 0.123 0.115]
  set born-calf-prices [0.94 1 0.97 0.961]
  set weaned-calf-prices [0.98 1.02 1 0.982]
  set steer-prices [0.856 0.917 0.881 0.873]
  set heifer-prices [0.701 0.733 0.727 0.696]
  set cow-prices [0.561 0.611 0.573 0.581]
  set pregnant-prices [0.561 0.611 0.573 0.581]
  set cow-with-calf-prices [0.61 0.664 0.665 0.617]

  set bull-prices [0.856 0.917 0.881 0.873]                                         ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set cost 0
  set income 0
  set balance 0
  set supplement-effort 0
  set weaning-effort 0
  set OS-males-effort 0                                                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-old-cow-effort 0                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-females-effort 0                                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-males-effort 0                                                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-old-cow-effort 0                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-females-effort 0                                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set breeding-effort 0
  set rotational-effort 0

  set other-daily-effort 0






  set OS-old-bull-effort 0

  set cost-history []
  set cost-historyXticks []

  set income-history []
  set income-historyXticks []

  set balance-history []
  set balance-historyXticks []





  set supplement-effort-history []
  set supplement-effort-history-season []                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set supplement-effort-historyXticks-season []                                         ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set supplement-effort-history-year []                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set supplement-effort-historyXticks-year []                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW






  set weaning-effort-history []
  set weaning-effort-history-season []                                                  ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set weaning-effort-historyXticks-season []                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set weaning-effort-history-year []                                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set weaning-effort-historyXticks-year []                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW








  set OS-males-effort-history []
  set OS-males-effort-history-season []                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-males-effort-historyXticks-season []                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-males-effort-history-year []                                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-males-effort-historyXticks-year []                                             ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW







  set OS-old-cow-effort-history []
  set OS-old-cow-effort-history-season []                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-old-cow-effort-historyXticks-season []                                         ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-old-cow-effort-history-year []                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-old-cow-effort-historyXticks-year []                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW





  set OS-old-bull-effort-history []
  set OS-old-bull-effort-history-season []
  set OS-old-bull-effort-historyXticks-season []
  set OS-old-bull-effort-history-year []
  set OS-old-bull-effort-historyXticks-year []







  set OS-females-effort-history []
  set OS-females-effort-history-season []                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-females-effort-historyXticks-season []                                      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-females-effort-history-year []                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-females-effort-historyXticks-year []                                        ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW









  set ES-males-effort-history []
  set ES-males-effort-history-season []                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-males-effort-historyXticks-season []                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-males-effort-history-year []                                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-males-effort-historyXticks-year []                                             ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW










  set ES-old-cow-effort-history []
  set ES-old-cow-effort-history-season []                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-old-cow-effort-historyXticks-season []                                         ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-old-cow-effort-history-year []                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-old-cow-effort-historyXticks-year []                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW









  set ES-females-effort-history []
  set ES-females-effort-history-season []                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-females-effort-historyXticks-season []                                      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-females-effort-history-year []                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-females-effort-historyXticks-year []                                        ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW



  set breeding-effort-history []
  set breeding-effort-history-season []                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set breeding-effort-historyXticks-season []                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set breeding-effort-history-year []                                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set breeding-effort-historyXticks-year []                                             ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


  set rotational-effort-history []
  set rotational-effort-history-season []                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set rotational-effort-historyXticks-season []                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set rotational-effort-history-year []                                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set rotational-effort-historyXticks-year []                                             ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW



  set other-daily-effort-history []
  set other-daily-effort-history-season []
  set other-daily-effort-historyXticks-season []
  set other-daily-effort-history-year []
  set other-daily-effort-historyXticks-year []

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
    create-cows initial-num-cows [set shape "cow" set live-weight initial-weight-cows set initial-weight initial-weight-cows set mortality-rate natural-mortality-rate set DDMC 0
      ;set age random (cow-age-max - cow-age-min) + cow-age-min
      set age cow-age-min
      setxy random-pxcor random-pycor become-cow ]

    if bull:cow-ratio > 0 [                                                                                                                                           ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
    create-cows round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio)
    [set shape "cow" set live-weight initial-weight-bulls set initial-weight initial-weight-bulls set mortality-rate natural-mortality-rate set DDMC 0
      ;set age random (cow-age-max - heifer-age-min) + heifer-age-min
      set age heifer-age-min
      setxy random-pxcor random-pycor become-bull ]
    if count cows with [bull?] < 1 [
      create-cows 1
      [set shape "cow" set live-weight initial-weight-bulls set initial-weight initial-weight-bulls set mortality-rate natural-mortality-rate set DDMC 0
      ;set age random (cow-age-max - heifer-age-min) + heifer-age-min
      set age heifer-age-min
      setxy random-pxcor random-pycor become-bull]]]

    create-cows initial-num-heifers [set shape "cow" set live-weight initial-weight-heifers set initial-weight initial-weight-heifers set mortality-rate natural-mortality-rate set DDMC 0
      ;set age random (cow-age-min - heifer-age-min) + heifer-age-min
      set age heifer-age-min
      setxy random-pxcor random-pycor become-heifer ]
    create-cows initial-num-steers [set shape "cow" set live-weight initial-weight-steers set initial-weight initial-weight-steers set mortality-rate natural-mortality-rate set DDMC 0
      ;set age random (cow-age-min - heifer-age-min) + heifer-age-min
      set age heifer-age-min
      setxy random-pxcor random-pycor become-steer ]
    create-cows initial-num-weaned-calves [set shape "cow" set live-weight initial-weight-weaned-calves set initial-weight initial-weight-weaned-calves set mortality-rate natural-mortality-rate set DDMC 0
      ;set age random (heifer-age-min - weaned-calf-age-min) + weaned-calf-age-min
      set age weaned-calf-age-min
      setxy random-pxcor random-pycor
      ;become-weaned-calf-male]
      ifelse random-float 1 < 0.5 [become-weaned-calf-female] [become-weaned-calf-male]]
  ]

  if (spatial-management = "rotational grazing") [                                  ;; livestock setup for the rotational grazing management strategy
    if (starting-paddock = "paddock a") [create-cows initial-num-cows [set shape "cow" set live-weight initial-weight-cows set initial-weight initial-weight-cows set mortality-rate natural-mortality-rate set DDMC 0 set age cow-age-min ask cows [move-to one-of patches with [paddock-a = 1]] become-cow]]
    if (starting-paddock = "paddock a") [if bull:cow-ratio > 0 [create-cows round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio) [set shape "cow" set live-weight initial-weight-bulls set initial-weight initial-weight-bulls set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-a = 1]] become-bull] if count cows with [bull?] < 1 [create-cows 1 [set shape "cow" set live-weight initial-weight-bulls set initial-weight initial-weight-bulls set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-a = 1]] become-bull]]]]                                  ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
    if (starting-paddock = "paddock a") [create-cows initial-num-heifers [set shape "cow" set live-weight initial-weight-heifers set initial-weight initial-weight-heifers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-a = 1]] become-heifer]]
    if (starting-paddock = "paddock a") [create-cows initial-num-steers [set shape "cow" set live-weight initial-weight-steers set initial-weight initial-weight-steers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-a = 1]] become-steer]]
    if (starting-paddock = "paddock a") [create-cows initial-num-weaned-calves [set shape "cow" set live-weight initial-weight-weaned-calves set initial-weight initial-weight-weaned-calves set mortality-rate natural-mortality-rate set DDMC 0 set age random (heifer-age-min - weaned-calf-age-min) + weaned-calf-age-min ask cows [move-to one-of patches with [paddock-a = 1]] ifelse random-float 1 < 0.5 [become-weaned-calf-female] [become-weaned-calf-male]]]

    if (starting-paddock = "paddock b") [create-cows initial-num-cows [set shape "cow" set live-weight initial-weight-cows set initial-weight initial-weight-cows set mortality-rate natural-mortality-rate set DDMC 0 set age cow-age-min ask cows [move-to one-of patches with [paddock-b = 1]] become-cow]]
    if (starting-paddock = "paddock b") [if bull:cow-ratio > 0 [create-cows round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio) [set shape "cow" set live-weight initial-weight-bulls set initial-weight initial-weight-bulls set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-b = 1]] become-bull] if count cows with [bull?] < 1 [create-cows 1 [set shape "cow" set live-weight initial-weight-bulls set initial-weight initial-weight-bulls set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-b = 1]] become-bull]]]]                                  ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
    if (starting-paddock = "paddock b") [create-cows initial-num-heifers [set shape "cow" set live-weight initial-weight-heifers set initial-weight initial-weight-heifers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-b = 1]] become-heifer]]
    if (starting-paddock = "paddock b") [create-cows initial-num-steers [set shape "cow" set live-weight initial-weight-steers set initial-weight initial-weight-steers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-b = 1]] become-steer]]
    if (starting-paddock = "paddock b") [create-cows initial-num-weaned-calves [set shape "cow" set live-weight initial-weight-weaned-calves set initial-weight initial-weight-weaned-calves set mortality-rate natural-mortality-rate set DDMC 0 set age random (heifer-age-min - weaned-calf-age-min) + weaned-calf-age-min ask cows [move-to one-of patches with [paddock-b = 1]] ifelse random-float 1 < 0.5 [become-weaned-calf-female] [become-weaned-calf-male]]]

    if (starting-paddock = "paddock c") [create-cows initial-num-cows [set shape "cow" set live-weight initial-weight-cows set initial-weight initial-weight-cows set mortality-rate natural-mortality-rate set DDMC 0 set age cow-age-min ask cows [move-to one-of patches with [paddock-c = 1]] become-cow]]
    if (starting-paddock = "paddock c") [if bull:cow-ratio > 0 [create-cows round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio) [set shape "cow" set live-weight initial-weight-bulls set initial-weight initial-weight-bulls set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-c = 1]] become-bull] if count cows with [bull?] < 1 [create-cows 1 [set shape "cow" set live-weight initial-weight-bulls set initial-weight initial-weight-bulls set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-c = 1]] become-bull]]]]                                  ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
    if (starting-paddock = "paddock c") [create-cows initial-num-heifers [set shape "cow" set live-weight initial-weight-heifers set initial-weight initial-weight-heifers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-c = 1]] become-heifer]]
    if (starting-paddock = "paddock c") [create-cows initial-num-steers [set shape "cow" set live-weight initial-weight-steers set initial-weight initial-weight-steers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-c = 1]] become-steer]]
    if (starting-paddock = "paddock c") [create-cows initial-num-weaned-calves [set shape "cow" set live-weight initial-weight-weaned-calves set initial-weight initial-weight-weaned-calves set mortality-rate natural-mortality-rate set DDMC 0 set age random (heifer-age-min - weaned-calf-age-min) + weaned-calf-age-min ask cows [move-to one-of patches with [paddock-c = 1]] ifelse random-float 1 < 0.5 [become-weaned-calf-female] [become-weaned-calf-male]]]

    if (starting-paddock = "paddock d") [create-cows initial-num-cows [set shape "cow" set live-weight initial-weight-cows set initial-weight initial-weight-cows set mortality-rate natural-mortality-rate set DDMC 0 set age cow-age-min ask cows [move-to one-of patches with [paddock-d = 1]] become-cow]]
    if (starting-paddock = "paddock d") [if bull:cow-ratio > 0 [create-cows round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio) [set shape "cow" set live-weight initial-weight-bulls set initial-weight initial-weight-bulls set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-d = 1]] become-bull] if count cows with [bull?] < 1 [create-cows 1 [set shape "cow" set live-weight initial-weight-bulls set initial-weight initial-weight-bulls set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-d = 1]] become-bull]]]]                                  ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
    if (starting-paddock = "paddock d") [create-cows initial-num-heifers [set shape "cow" set live-weight initial-weight-heifers set initial-weight initial-weight-heifers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-d = 1]] become-heifer]]
    if (starting-paddock = "paddock d") [create-cows initial-num-steers [set shape "cow" set live-weight initial-weight-steers set initial-weight initial-weight-steers set mortality-rate natural-mortality-rate set DDMC 0 set age heifer-age-min ask cows [move-to one-of patches with [paddock-d = 1]] become-steer]]
    if (starting-paddock = "paddock d") [create-cows initial-num-weaned-calves [set shape "cow" set live-weight initial-weight-weaned-calves set initial-weight initial-weight-weaned-calves set mortality-rate natural-mortality-rate set DDMC 0 set age random (heifer-age-min - weaned-calf-age-min) + weaned-calf-age-min ask cows [move-to one-of patches with [paddock-d = 1]] ifelse random-float 1 < 0.5 [become-weaned-calf-female] [become-weaned-calf-male]]]
  ]

  ask cows [                                                                        ;; setup of the variables used to output the average live weight gained during a season (see report "ILWG_SEASON" and "Average SEASONAL ILWG" monitor) or during a year (see report "ILWG_YEAR" and "Average YEARLY ILWG" monitor)

    set live-weight-gain-history []
    set live-weight-gain-historyXticks []

    set live-weight-gain-history-season []
    set live-weight-gain-historyXticks-season []
    set live-weight-gain-history-year []
    set live-weight-gain-historyXticks-year []
  ]


  ask cows [                                                                         ;; ;; CALCULA EL DRY MATTER CONSUMPTION A LO LARGO DE UNA ESTACIÓN (DDMC-history-season), DE UN AÑO (DDMC-history-year), Y DESDE QUE EMPEZÓ LA SIMULACIÓN (DDMC-history)
    set DDMC-history []
    set DDMC-historyXticks []
    set DDMC-history-season []
    set DDMC-historyXticks-season []
    set DDMC-history-year []
    set DDMC-historyXticks-year []
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

  set bull? false                                                                             ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

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

  set supplemented? false                                                           ;;## FEED SUPPLEMENTATION MODULE
  set kg-supplement-DM 0                                                            ;;## FEED SUPPLEMENTATION MODULE
  set USD-supplement-DM 0                                                           ;;## FEED SUPPLEMENTATION MODULE



  set kg-supplement-DM-breeding 0                                                            ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set USD-supplement-DM-breeding 0                                                           ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW




  set weaning-calf? false                                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
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

  set bull? false                                                                             ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

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

  set supplemented? false                                                           ;;## FEED SUPPLEMENTATION MODULE
  set kg-supplement-DM 0                                                            ;;## FEED SUPPLEMENTATION MODULE
  set USD-supplement-DM 0                                                           ;;## FEED SUPPLEMENTATION MODULE


  set kg-supplement-DM-breeding 0                                                            ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set USD-supplement-DM-breeding 0                                                           ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW



  set weaning-calf? false                                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
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

  set bull? false                                                                             ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set color yellow - 2
  set animal-units live-weight / set-1-AU
  ;set min-weight 60
  set min-weight 100
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

  set supplemented? false                                                                               ;;## FEED SUPPLEMENTATION MODULE
  if supplemented? = true [set difference-LW weaned-calf-min-weight-for-feed-sup - live-weight]         ;;## FEED SUPPLEMENTATION MODULE
  set kg-supplement-DM 0                                                                                ;;## FEED SUPPLEMENTATION MODULE
  set USD-supplement-DM 0                                                                               ;;## FEED SUPPLEMENTATION MODULE

  ifelse age / 368 > age-sell-old-cow/bull [set old? true] [set old? false]                                                       ;;OLDNEW###################################################


  set kg-supplement-DM-breeding 0                                                            ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set USD-supplement-DM-breeding 0                                                           ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW



  set weaning-calf? false                                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
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

  set bull? false                                                                             ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set color orange
  set animal-units live-weight / set-1-AU
  ;set min-weight 60
  set min-weight 100
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

  set supplemented? false                                                                                          ;;## FEED SUPPLEMENTATION MODULE
  if supplemented? = true [set difference-LW weaned-calf-min-weight-for-feed-sup - live-weight]                    ;;## FEED SUPPLEMENTATION MODULE
  set kg-supplement-DM 0                                                                                           ;;## FEED SUPPLEMENTATION MODULE
  set USD-supplement-DM 0                                                                                          ;;## FEED SUPPLEMENTATION MODULE


  set kg-supplement-DM-breeding 0                                                            ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set USD-supplement-DM-breeding 0                                                           ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


  ifelse age / 368 > age-sell-old-cow/bull [set old? true] [set old? false]                                                       ;;OLDNEW###################################################


  set kg-supplement-DM-breeding 0                                                            ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set USD-supplement-DM-breeding 0                                                           ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW



  set weaning-calf? false                                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
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

  set bull? false                                                                             ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set color pink
  set animal-units live-weight / set-1-AU
  ;set min-weight 100
  set min-weight 150
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

  set supplemented? false                                                                                          ;;## FEED SUPPLEMENTATION MODULE
  if supplemented? = true [set difference-LW heifer/steer-min-weight-for-feed-sup - live-weight]                   ;;## FEED SUPPLEMENTATION MODULE
  set kg-supplement-DM 0                                                                                           ;;## FEED SUPPLEMENTATION MODULE
  set USD-supplement-DM 0                                                                                          ;;## FEED SUPPLEMENTATION MODULE


  ifelse age / 368 > age-sell-old-cow/bull [set old? true] [set old? false]                                                       ;;OLDNEW###################################################


  set kg-supplement-DM-breeding 0                                                            ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set USD-supplement-DM-breeding 0                                                           ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW



  set weaning-calf? false                                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
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

  set bull? false                                                                             ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set color red
  set animal-units live-weight / set-1-AU
  ;set min-weight 100
  set min-weight 150
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

  set supplemented? false                                                                                          ;;## FEED SUPPLEMENTATION MODULE
  if supplemented? = true [set difference-LW heifer/steer-min-weight-for-feed-sup - live-weight]                   ;;## FEED SUPPLEMENTATION MODULE
  set kg-supplement-DM 0                                                                                           ;;## FEED SUPPLEMENTATION MODULE
  set USD-supplement-DM 0                                                                                          ;;## FEED SUPPLEMENTATION MODULE


  ifelse age / 368 > age-sell-old-cow/bull [set old? true] [set old? false]                                                       ;;OLDNEW###################################################


  set kg-supplement-DM-breeding 0                                                            ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set USD-supplement-DM-breeding 0                                                           ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


  set weaning-calf? false                                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to become-bull
  set born-calf? false
  set born-calf-female? false
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

  set bull? true                                                                             ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set color black
  set animal-units live-weight / set-1-AU
  ;set min-weight 180
  set min-weight 220
  set size 1.2
  set natural-mortality-rate 0.000054
  set except-mort-rate 0.15
  set category-coef 1.1
  set pregnancy-rate 0
  set coefA 0
  set coefB 0
  set pregnancy-time 0
  set lactating-time 0

  set price item current-season bull-prices                                        ;;## SALES MODULE
  set sale? false                                                                   ;;## SALES MODULE
  set value price * live-weight                                                     ;;## SALES MODULE

  set supplemented? false                                                                                          ;;## FEED SUPPLEMENTATION MODULE
  if supplemented? = true [set difference-LW bull-min-weight-for-feed-sup - live-weight]                   ;;## FEED SUPPLEMENTATION MODULE
  set kg-supplement-DM 0                                                                                           ;;## FEED SUPPLEMENTATION MODULE
  set USD-supplement-DM 0                                                                                          ;;## FEED SUPPLEMENTATION MODULE


  ifelse age / 368 > age-sell-old-cow/bull [set old? true] [set old? false]                                                       ;;OLDNEW###################################################


  set kg-supplement-DM-breeding 0                                                            ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set USD-supplement-DM-breeding 0                                                           ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


  set weaning-calf? false                                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
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

  set bull? false                                                                             ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set color brown
  set animal-units live-weight / set-1-AU
  ;set min-weight 180
  set min-weight 220
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

  set supplemented? false                                                                                          ;;## FEED SUPPLEMENTATION MODULE
  if supplemented? = true [set difference-LW cow-min-weight-for-feed-sup - live-weight]                            ;;## FEED SUPPLEMENTATION MODULE
  set kg-supplement-DM 0                                                                                           ;;## FEED SUPPLEMENTATION MODULE
  set USD-supplement-DM 0                                                                                          ;;## FEED SUPPLEMENTATION MODULE


  if supplemented? = true [set difference-LW-breeding min-weight-for-breeding - live-weight] ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set kg-supplement-DM-breeding 0                                                            ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set USD-supplement-DM-breeding 0                                                           ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW



  ifelse age / 368 > age-sell-old-cow/bull [set old? true] [set old? false]                                                       ;;OLDNEW###################################################


  set weaning-calf? false                                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
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

  set bull? false                                                                             ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set color magenta
  set animal-units live-weight / set-1-AU
  ;set min-weight 180
  set min-weight 220
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

  set supplemented? false                                                                                          ;;## FEED SUPPLEMENTATION MODULE
  if supplemented? = true [set difference-LW cow-with-calf-min-weight-for-feed-sup - live-weight]                  ;;## FEED SUPPLEMENTATION MODULE
  set kg-supplement-DM 0                                                                                           ;;## FEED SUPPLEMENTATION MODULE
  set USD-supplement-DM 0                                                                                          ;;## FEED SUPPLEMENTATION MODULE


  set kg-supplement-DM-breeding 0                                                            ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set USD-supplement-DM-breeding 0                                                           ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


  ifelse age / 368 > age-sell-old-cow/bull [set old? true] [set old? false]                                                       ;;OLDNEW###################################################


  set weaning-calf? false                                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAIN PROCEDURES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go

  set DM-cm-ha set-DM-cm-ha                                                          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PONER UNA DESCRIPCION AQUI TAMBIEN

  if current-season = 0 [                                                            ;; setting the Kmax, length of the season and climate distribution for the winter
    ;set kmax 7.4
    set kmax K-winter
    set season-length winter-length
    if (climacoef-distribution = "homogeneus") and (season-days = 0 or season-days = 1) [set climacoef winter-climacoef-homogeneus]
    if (climacoef-distribution = "uniform") and (season-days = 0 or season-days = 1) [set climacoef random-float 1.5]
    if (climacoef-distribution = "normal") and (season-days = 0 or season-days = 1) [set climacoef random-normal 1 0.15 if climacoef < 0 [set climacoef 0.1] if climacoef > 1.5 [set climacoef 1.5]]
    if (climacoef-distribution = "exponential_low") and (season-days = 0 or season-days = 1) [set climacoef random-exponential 0.5 while [climacoef > 1.5] [set climacoef random-exponential 0.5]]
    if (climacoef-distribution = "exponential_high") and (season-days = 0 or season-days = 1) [set climacoef 1.5 - random-exponential 0.1 while [climacoef < 0] [set climacoef 1.5 - random-exponential 0.1]]
  ]

  if current-season = 1 [                                                            ;; setting the Kmax, length of the season and climate distribution for the spring
    ;set kmax 22.2
    set kmax K-spring
    set season-length spring-length
    if (climacoef-distribution = "homogeneus") and (season-days = 0 or season-days = 1) [set climacoef spring-climacoef-homogeneus]
    if (climacoef-distribution = "uniform") and (season-days = 0 or season-days = 1) [set climacoef random-float 1.5]
    if (climacoef-distribution = "normal") and (season-days = 0 or season-days = 1) [set climacoef random-normal 1 0.15 if climacoef < 0 [set climacoef 0.1] if climacoef > 1.5 [set climacoef 1.5]]
    if (climacoef-distribution = "exponential_low") and (season-days = 0 or season-days = 1) [set climacoef random-exponential 0.2 while [climacoef > 1.5] [set climacoef random-exponential 0.2]]
    if (climacoef-distribution = "exponential_high") and (season-days = 0 or season-days = 1) [set climacoef 1.5 - random-exponential 0.1 while [climacoef < 0] [set climacoef 1.5 - random-exponential 0.1]]
  ]

  if current-season = 2 [                                                            ;; setting the Kmax, length of the season and climate distribution for the summer
    ;set kmax 15.6
    set kmax K-summer
    set season-length summer-length
    if (climacoef-distribution = "homogeneus") and (season-days = 0 or season-days = 1) [set climacoef summer-climacoef-homogeneus]
    if (climacoef-distribution = "uniform") and (season-days = 0 or season-days = 1) [set climacoef random-float 1.5]
    if (climacoef-distribution = "normal") and (season-days = 0 or season-days = 1) [set climacoef random-normal 1 0.15 if climacoef < 0 [set climacoef 0.1] if climacoef > 1.5 [set climacoef 1.5]]
    if (climacoef-distribution = "exponential_low") and (season-days = 0 or season-days = 1) [set climacoef random-exponential 0.5 while [climacoef > 1.5] [set climacoef random-exponential 0.5]]
    if (climacoef-distribution = "exponential_high") and (season-days = 0 or season-days = 1) [set climacoef 1.5 - random-exponential 0.1 while [climacoef < 0] [set climacoef 1.5 - random-exponential 0.1]]
  ]

  if current-season = 3 [                                                            ;; setting the Kmax, length of the season and climate distribution for the fall
    ;set kmax 11.1
    set kmax K-fall
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

  set direct-climacoef-control set-direct-climacoef-control                                                               ;; if "direct-climacoef-control" is selected, the user can change the climate coefficient in real time (i.e. while the simulation is running)
  if (climacoef-distribution = "direct-climacoef-control") [if current-season = 0 [set climacoef direct-climacoef-control]]
  if (climacoef-distribution = "direct-climacoef-control") [if current-season = 1 [set climacoef direct-climacoef-control]]
  if (climacoef-distribution = "direct-climacoef-control") [if current-season = 2 [set climacoef direct-climacoef-control]]
  if (climacoef-distribution = "direct-climacoef-control") [if current-season = 3 [set climacoef direct-climacoef-control]]

  set simulation-time simulation-time + days-per-tick
  set season-days season-days + days-per-tick
  set year-days year-days + days-per-tick

  if year-days >= 369 [set year-days 1]                                              ;; This reset is important to make sure that the "live-weight-gain-history-year" variable works, which is used in the "ILWG_YEAR" report

  if (spatial-management = "rotational grazing") [set ticks-since-here ticks-since-here + days-per-tick]                              ;; for rotational grazing strategies only, it measures the number of days since the animals were moved to a new paddock. This variable is important to prevent animals from continuously moving from one paddock to another once they have met the criteria to move to the next paddock. Once animals have met the criteria, they will move to the next paddock and wait X days (defined by the RG-days-in-paddock slider in the interface) to acclimate to the new paddock. Once those days have passed, if the animals still meet the criteria to move between paddocks, they will move.



  ;; DÍAS HASTA QUE EMPIECE LA BREEDING-SEASON.

  if controlled-breeding-season = 0 [
    if current-season = 0 [set days-until-breeding-season 0]
    if current-season = 1 [set days-until-breeding-season (spring-length + summer-length + fall-length) - season-days]
    if current-season = 2 [set days-until-breeding-season (summer-length + fall-length) - season-days]
    if current-season = 3 [set days-until-breeding-season (fall-length) - season-days]]

  if controlled-breeding-season = 1 [
    if current-season = 0 [set days-until-breeding-season (winter-length) - season-days]
    if current-season = 1 [set days-until-breeding-season 0]
    if current-season = 2 [set days-until-breeding-season (summer-length + fall-length + winter-length) - season-days]
    if current-season = 3 [set days-until-breeding-season (fall-length + winter-length) - season-days]]

  if controlled-breeding-season = 2 [
    if current-season = 0 [set days-until-breeding-season (winter-length + spring-length) - season-days]
    if current-season = 1 [set days-until-breeding-season (spring-length) - season-days]
    if current-season = 2 [set days-until-breeding-season 0]
    if current-season = 3 [set days-until-breeding-season (fall-length + winter-length + spring-length) - season-days]]

  if controlled-breeding-season = 3 [
    if current-season = 0 [set days-until-breeding-season (winter-length + spring-length + summer-length) - season-days]
    if current-season = 1 [set days-until-breeding-season (spring-length + summer-length) - season-days]
    if current-season = 2 [set days-until-breeding-season (summer-length) - season-days]
    if current-season = 3 [set days-until-breeding-season 0]]







  ask cows [
    set live-weight-gain-history fput live-weight-gain live-weight-gain-history
    set live-weight-gain-historyXticks sum (sublist live-weight-gain-history 0 simulation-time)
  ]

  ask cows [                                                                         ;; in this line, the average live weight gain of the cows during the season is calculated
    set live-weight-gain-history-season fput live-weight-gain live-weight-gain-history-season
    if season-days > 0 [set live-weight-gain-historyXticks-season mean (sublist live-weight-gain-history-season 0 season-days)]
    if season-days = season-length [set live-weight-gain-history-season []]
    ;if season-days = 92 [set live-weight-gain-history-season []]
  ]

  ask cows [                                                                         ;; in this line, the average live weight gain of the cows during the year (from day 1 to day 368 and in between) is calculated
    set live-weight-gain-history-year fput live-weight-gain live-weight-gain-history-year
    if year-days > 0 [set live-weight-gain-historyXticks-year mean (sublist live-weight-gain-history-year 0 year-days)]
    if year-days = 368 [set live-weight-gain-history-year []]
  ]


;; ------------------------------------------------------------------------------------------------- ;; CALCULA EL DRY MATTER CONSUMPTION A LO LARGO DE UNA ESTACIÓN (DDMC-history-season), DE UN AÑO (DDMC-history-year), Y DESDE QUE EMPEZÓ LA SIMULACIÓN (DDMC-history)
  ask cows [
    set DDMC-history fput DDMC DDMC-history
    set DDMC-historyXticks sum (sublist DDMC-history 0 simulation-time)
  ]

  ask cows [
    set DDMC-history-season fput DDMC DDMC-history-season
    set DDMC-historyXticks-season sum (sublist DDMC-history-season 0 season-days)
    if season-days = season-length [set DDMC-history-season []]
    ;if season-days = 92 [set supplement-effort-history-season []]
  ]

  ask cows [
    set DDMC-history-year fput DDMC DDMC-history-year
    set DDMC-historyXticks-year sum (sublist DDMC-history-year 0 year-days)
    if year-days = 368 [set DDMC-history-year []]
  ]
;; -------------------------------------------------------------------------------------------------



  set cost-history fput cost cost-history                                                             ;;## SALES MODULE
  set cost-historyXticks sum (sublist cost-history 0 simulation-time)                                 ;;## SALES MODULE

  set income-history fput income income-history                                                       ;;## SALES MODULE
  set income-historyXticks sum (sublist income-history 0 simulation-time)                             ;;## SALES MODULE

  set balance-history fput balance balance-history                                                    ;;## SALES MODULE
  set balance-historyXticks sum (sublist balance-history 0 simulation-time)                           ;;## SALES MODULE




  set supplement-effort-history fput supplement-effort supplement-effort-history                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set supplement-effort-historyXticks sum (sublist supplement-effort-history 0 simulation-time)                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


  set supplement-effort-history-season fput supplement-effort supplement-effort-history-season                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set supplement-effort-historyXticks-season sum (sublist supplement-effort-history-season 0 season-days)                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if season-days = season-length [set supplement-effort-history-season []]
  ;if season-days = 92 [set supplement-effort-history-season []]                                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set supplement-effort-history-year fput supplement-effort supplement-effort-history-year                                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set supplement-effort-historyXticks-year sum (sublist supplement-effort-history-year 0 year-days)                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if year-days = 368 [set supplement-effort-history-year []]                                                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW







  set weaning-effort-history fput weaning-effort weaning-effort-history                                                        ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set weaning-effort-historyXticks sum (sublist weaning-effort-history 0 simulation-time)                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set weaning-effort-history-season fput weaning-effort weaning-effort-history-season                                                        ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set weaning-effort-historyXticks-season sum (sublist weaning-effort-history-season 0 season-days)                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if season-days = season-length [set weaning-effort-history-season []]
  ;if season-days = 92 [set weaning-effort-history-season []]                                                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set weaning-effort-history-year fput weaning-effort weaning-effort-history-year                                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set weaning-effort-historyXticks-year sum (sublist weaning-effort-history-year 0 year-days)                                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if year-days = 368 [set weaning-effort-history-year []]                                                                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW









  set OS-males-effort-history fput OS-males-effort OS-males-effort-history                                                  ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-males-effort-historyXticks sum (sublist OS-males-effort-history 0 simulation-time)

  set OS-males-effort-history-season fput OS-males-effort OS-males-effort-history-season                                                  ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-males-effort-historyXticks-season sum (sublist OS-males-effort-history-season 0 season-days)                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if season-days = season-length [set OS-males-effort-history-season []]
  ;if season-days = 92 [set OS-males-effort-history-season []]

  set OS-males-effort-history-year fput OS-males-effort OS-males-effort-history-year                                                  ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-males-effort-historyXticks-year sum (sublist OS-males-effort-history-year 0 year-days)                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if year-days = 368 [set OS-males-effort-history-year []]








  set OS-old-cow-effort-history fput OS-old-cow-effort OS-old-cow-effort-history                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-old-cow-effort-historyXticks sum (sublist OS-old-cow-effort-history 0 simulation-time)

  set OS-old-cow-effort-history-season fput OS-old-cow-effort OS-old-cow-effort-history-season                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-old-cow-effort-historyXticks-season sum (sublist OS-old-cow-effort-history-season 0 season-days)                                         ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if season-days = season-length [set OS-old-cow-effort-history-season []]
  ;if season-days = 92 [set OS-old-cow-effort-history-season []]

  set OS-old-cow-effort-history-year fput OS-old-cow-effort OS-old-cow-effort-history-year                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-old-cow-effort-historyXticks-year sum (sublist OS-old-cow-effort-history-year 0 year-days)                                         ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if year-days = 368 [set OS-old-cow-effort-history-year []]




  set OS-old-bull-effort-history fput OS-old-bull-effort OS-old-bull-effort-history
  set OS-old-bull-effort-historyXticks sum (sublist OS-old-bull-effort-history 0 simulation-time)

  set OS-old-bull-effort-history-season fput OS-old-bull-effort OS-old-bull-effort-history-season
  set OS-old-bull-effort-historyXticks-season sum (sublist OS-old-bull-effort-history-season 0 season-days)
  if season-days = season-length [set OS-old-bull-effort-history-season []]
  ;if season-days = 92 [set OS-old-bull-effort-history-season []]

  set OS-old-bull-effort-history-year fput OS-old-bull-effort OS-old-bull-effort-history-year
  set OS-old-bull-effort-historyXticks-year sum (sublist OS-old-bull-effort-history-year 0 year-days)
  if year-days = 368 [set OS-old-bull-effort-history-year []]













  set OS-females-effort-history fput OS-females-effort OS-females-effort-history                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-females-effort-historyXticks sum (sublist OS-females-effort-history 0 simulation-time)

  set OS-females-effort-history-season fput OS-females-effort OS-females-effort-history-season                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-females-effort-historyXticks-season sum (sublist OS-females-effort-history-season 0 season-days)                                  ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if season-days = season-length [set OS-females-effort-history-season []]
  ;if season-days = 92 [set OS-females-effort-history-season []]

  set OS-females-effort-history-year fput OS-females-effort OS-females-effort-history-year                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-females-effort-historyXticks-year sum (sublist OS-females-effort-history-year 0 year-days)                                  ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if year-days = 368 [set OS-females-effort-history-year []]










  set ES-males-effort-history fput ES-males-effort ES-males-effort-history                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-males-effort-historyXticks sum (sublist ES-males-effort-history 0 simulation-time)

  set ES-males-effort-history-season fput ES-males-effort ES-males-effort-history-season                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-males-effort-historyXticks-season sum (sublist ES-males-effort-history-season 0 season-days)                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if season-days = season-length [set ES-males-effort-history-season []]
  ;if season-days = 92 [set ES-males-effort-history-season []]

  set ES-males-effort-history-year fput ES-males-effort ES-males-effort-history-year                                                 ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-males-effort-historyXticks-year sum (sublist ES-males-effort-history-year 0 year-days)                                           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if year-days = 368 [set ES-males-effort-history-year []]










  set ES-old-cow-effort-history fput ES-old-cow-effort ES-old-cow-effort-history                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-old-cow-effort-historyXticks sum (sublist ES-old-cow-effort-history 0 simulation-time)

  set ES-old-cow-effort-history-season fput ES-old-cow-effort ES-old-cow-effort-history-season                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-old-cow-effort-historyXticks-season sum (sublist ES-old-cow-effort-history-season 0 season-days)                                         ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if season-days = season-length [set ES-old-cow-effort-history-season []]
  ;if season-days = 92 [set ES-old-cow-effort-history-season []]

  set ES-old-cow-effort-history-year fput ES-old-cow-effort ES-old-cow-effort-history-year                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-old-cow-effort-historyXticks-year sum (sublist ES-old-cow-effort-history-year 0 year-days)                                         ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if year-days = 368 [set ES-old-cow-effort-history-year []]









  set ES-females-effort-history fput ES-females-effort ES-females-effort-history                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-females-effort-historyXticks sum (sublist ES-females-effort-history 0 simulation-time)

  set ES-females-effort-history-season fput ES-females-effort ES-females-effort-history-season                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-females-effort-historyXticks-season sum (sublist ES-females-effort-history-season 0 season-days)                                      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if season-days = season-length [set ES-females-effort-history-season []]
  ;if season-days = 92 [set ES-females-effort-history-season []]

  set ES-females-effort-history-year fput ES-females-effort ES-females-effort-history-year                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-females-effort-historyXticks-year sum (sublist ES-females-effort-history-year 0 year-days)                                      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if year-days = 368 [set ES-females-effort-history-year []]








  set breeding-effort-history fput breeding-effort breeding-effort-history                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set breeding-effort-historyXticks sum (sublist breeding-effort-history 0 simulation-time)

  set breeding-effort-history-season fput breeding-effort breeding-effort-history-season                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set breeding-effort-historyXticks-season sum (sublist breeding-effort-history-season 0 season-days)                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set breeding-effort-history-year fput breeding-effort breeding-effort-history-year                                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set breeding-effort-historyXticks-year sum (sublist breeding-effort-history-year 0 year-days)                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set breeding-effort 0




  set rotational-effort-history fput rotational-effort rotational-effort-history                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set rotational-effort-historyXticks sum (sublist rotational-effort-history 0 simulation-time)                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set rotational-effort-history-season fput rotational-effort rotational-effort-history-season                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set rotational-effort-historyXticks-season sum (sublist rotational-effort-history-season 0 season-days)                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set rotational-effort-history-year fput rotational-effort rotational-effort-history-year                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set rotational-effort-historyXticks-year sum (sublist rotational-effort-history-year 0 year-days)                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  if ticks-since-here = 1 [set rotational-effort 0]                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW




  set other-daily-effort-history fput other-daily-effort other-daily-effort-history                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set other-daily-effort-historyXticks sum (sublist other-daily-effort-history 0 simulation-time)

  set other-daily-effort-history-season fput other-daily-effort other-daily-effort-history-season                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set other-daily-effort-historyXticks-season sum (sublist other-daily-effort-history-season 0 season-days)                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set other-daily-effort-history-year fput other-daily-effort other-daily-effort-history-year                                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set other-daily-effort-historyXticks-year sum (sublist other-daily-effort-history-year 0 year-days)                                               ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  set other-daily-effort 0



;; ###########################################################################################################################################################################################################################
;; ####################################### CALCULO DEL CARRYING CAPACITY (REAL Y ESTIMADO) QUE USARÁ EL ENVIRONMENTAL FARMER PARA TOMAR DECISIONES DURANTE EL EXTRAORDINARY SALES ############################################
;; ###########################################################################################################################################################################################################################

  if season-days = 1 [   ;; CALCULO DEL ESTIMATED CARRYING CAPACITY (EL QUE USA EL ENVIRONMENTAL FARMER). ESTE CALCULO SE HACE AL INICIO DE CADA SEASON

  if (spatial-management = "free grazing") [

    set estimated-kmax mean [grass-height] of patches * mean [soil-quality] of patches                                         ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWW ES-ENVIRONMENTAL
    set estimated-DM-cm-ha DM-cm-ha]                                                                                           ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWW ES-ENVIRONMENTAL

  if (spatial-management = "rotational grazing") [

      ask patches with [paddock-a = 1] [
        if any? cows-here [
          set estimated-kmax mean [grass-height] of patches with [paddock-a = 1] * mean [soil-quality] of patches with [paddock-a = 1]                 ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWW ES-ENVIRONMENTAL
          set estimated-DM-cm-ha DM-cm-ha]]                                                                                                            ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWW ES-ENVIRONMENTAL

      ask patches with [paddock-b = 1] [
        if any? cows-here [
          set estimated-kmax mean [grass-height] of patches with [paddock-b = 1] * mean [soil-quality] of patches with [paddock-b = 1]                 ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWW ES-ENVIRONMENTAL
          set estimated-DM-cm-ha DM-cm-ha]]                                                                                                            ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWW ES-ENVIRONMENTAL

      ask patches with [paddock-c = 1] [
        if any? cows-here [
          set estimated-kmax mean [grass-height] of patches with [paddock-c = 1] * mean [soil-quality] of patches with [paddock-c = 1]                 ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWW ES-ENVIRONMENTAL
          set estimated-DM-cm-ha DM-cm-ha]]                                                                                                            ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWW ES-ENVIRONMENTAL

      ask patches with [paddock-d = 1] [
        if any? cows-here [
          set estimated-kmax mean [grass-height] of patches with [paddock-d = 1] * mean [soil-quality] of patches with [paddock-d = 1]                 ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWW ES-ENVIRONMENTAL
          set estimated-DM-cm-ha DM-cm-ha]]
  ]]                                                                                                        ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWW ES-ENVIRONMENTAL

  ;; FORMULA DEL ESTIMATED CARRYING CAPACITY (EL QUE USA EL ENV. FARMER)

  if (spatial-management = "free grazing") [

    set estimated-carrying-capacity ((((estimated-kmax * estimated-DM-cm-ha) * climacoef * count patches) * (%-DM-available-for-cattle / 100)) / season-length) / daily-DM-consumed-by-cattle]         ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWW ES-ENVIRONMENTAL.LA VARIABLE "%-DM-available-for-cattle" ES EL % DE DM QUE UTILIZARÁ EL GANADO

  if (spatial-management = "rotational grazing") [

    ask patches with [paddock-a = 1] [
      if any? cows-here [
        set estimated-carrying-capacity ((((estimated-kmax * estimated-DM-cm-ha) * climacoef * count patches with [paddock-a = 1]) * (%-DM-available-for-cattle / 100)) / season-length) / daily-DM-consumed-by-cattle]]

    ask patches with [paddock-b = 1] [
      if any? cows-here [
        set estimated-carrying-capacity ((((estimated-kmax * estimated-DM-cm-ha) * climacoef * count patches with [paddock-b = 1]) * (%-DM-available-for-cattle / 100)) / season-length) / daily-DM-consumed-by-cattle]]

    ask patches with [paddock-c = 1] [
      if any? cows-here [
        set estimated-carrying-capacity ((((estimated-kmax * estimated-DM-cm-ha) * climacoef * count patches with [paddock-c = 1]) * (%-DM-available-for-cattle / 100)) / season-length) / daily-DM-consumed-by-cattle]]

    ask patches with [paddock-d = 1] [
      if any? cows-here [
        set estimated-carrying-capacity ((((estimated-kmax * estimated-DM-cm-ha) * climacoef * count patches with [paddock-d = 1]) * (%-DM-available-for-cattle / 100)) / season-length) / daily-DM-consumed-by-cattle]]]

  ;; FORMULA DEL REAL CARRYING CAPACITY DEL SISTEMA (A TITULO INFORMATIVO)

  if (spatial-management = "free grazing") [

    if any? cows [
      ifelse mean [DDMC] of cows = 0
      [set carrying-capacity ((((mean [grass-height] of patches * DM-cm-ha) * climacoef * count patches) * 1) / season-length) / daily-DM-consumed-by-cattle]
      [set carrying-capacity ((((mean [grass-height] of patches * DM-cm-ha) * climacoef * count patches) * 1) / season-length) / mean [DDMC] of cows]]]

    if (spatial-management = "rotational grazing") [

      ask patches with [paddock-a = 1] [
        if any? cows-here [
          ifelse mean [DDMC] of cows = 0
          [set carrying-capacity  ((((mean [grass-height] of patches with [paddock-a = 1] * mean [soil-quality] of patches with [paddock-a = 1]) * DM-cm-ha) * climacoef * count patches with [paddock-a = 1]) / season-length) / daily-DM-consumed-by-cattle]
          [set carrying-capacity  ((((mean [grass-height] of patches with [paddock-a = 1] * mean [soil-quality] of patches with [paddock-a = 1]) * DM-cm-ha) * climacoef * count patches with [paddock-a = 1]) / season-length) / mean [DDMC] of cows]]]                                                                                                            ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWW ES-ENVIRONMENTAL


      ask patches with [paddock-b = 1] [
        if any? cows-here [
          ifelse mean [DDMC] of cows = 0
          [set carrying-capacity  ((((mean [grass-height] of patches with [paddock-b = 1] * mean [soil-quality] of patches with [paddock-b = 1]) * DM-cm-ha) * climacoef * count patches with [paddock-b = 1]) / season-length) / daily-DM-consumed-by-cattle]
          [set carrying-capacity  ((((mean [grass-height] of patches with [paddock-b = 1] * mean [soil-quality] of patches with [paddock-b = 1]) * DM-cm-ha) * climacoef * count patches with [paddock-b = 1]) / season-length) / mean [DDMC] of cows]]]


      ask patches with [paddock-c = 1] [
        if any? cows-here [
          ifelse mean [DDMC] of cows = 0
          [set carrying-capacity  ((((mean [grass-height] of patches with [paddock-c = 1] * mean [soil-quality] of patches with [paddock-c = 1]) * DM-cm-ha) * climacoef * count patches with [paddock-c = 1]) / season-length) / daily-DM-consumed-by-cattle]
          [set carrying-capacity  ((((mean [grass-height] of patches with [paddock-c = 1] * mean [soil-quality] of patches with [paddock-c = 1]) * DM-cm-ha) * climacoef * count patches with [paddock-c = 1]) / season-length) / mean [DDMC] of cows]]]


      ask patches with [paddock-d = 1] [
        if any? cows-here [
          ifelse mean [DDMC] of cows = 0
          [set carrying-capacity  ((((mean [grass-height] of patches with [paddock-d = 1] * mean [soil-quality] of patches with [paddock-d = 1]) * DM-cm-ha) * climacoef * count patches with [paddock-d = 1]) / season-length) / daily-DM-consumed-by-cattle]
          [set carrying-capacity  ((((mean [grass-height] of patches with [paddock-d = 1] * mean [soil-quality] of patches with [paddock-d = 1]) * DM-cm-ha) * climacoef * count patches with [paddock-d = 1]) / season-length) / mean [DDMC] of cows]]]]

;; ###########################################################################################################################################################################################################################
;; ###########################################################################################################################################################################################################################
;; ###########################################################################################################################################################################################################################

  if simulation-time / 368 = STOP-SIMULATION-AT [stop]                               ;; the observer can decide whether the simulation should run indefinitely (STOP-SIMULATION-AT 0 years) or after X years

  ;if count cows = 0 [stop]

  grow-grass

  move

  LWG

  DM-consumption

  set supplement-cost 0

  if (farmer-profile = "market") or (farmer-profile = "market-fsb") [

    feed-supplementation                                                             ;;## FEED SUPPLEMENTATION MODULE

  ]


  if (farmer-profile = "market-fsb") [

    feed-supplementation-for-controlled-breeding                                     ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ]

  if (farmer-profile = "environmental") [
    ;if count cows <= keep-MIN-n-breeding-cows [
    feed-supplementation
  ;]                        ;;## FEED SUPPLEMENTATION MODULE ;; environmental farmers only supplement animals when the system meets or falls below the minimum herd size desired by the farmer ("keep-MIN-n-cattle" slider in the interface)
  ]

  if (farmer-profile = "none") [
    grow-livestock-natural-weaning-none-profile                                      ;;## EARLY/NATURAL WEANING MODULE
  ]
    if (farmer-profile = "traditional") [
    grow-livestock-natural-weaning                                                   ;;## EARLY/NATURAL WEANING MODULE
  ]
    if (farmer-profile = "environmental") [
    grow-livestock-natural-weaning                                                   ;;## EARLY/NATURAL WEANING MODULE
  ]
  if (farmer-profile = "market") or (farmer-profile = "market-fsb") [
    grow-livestock-early-weaning                                                     ;;## EARLY/NATURAL WEANING MODULE
  ]

  if (farmer-profile = "none") [
    uncontrolled-breeding                                                            ;;## CONTROLLED/NATURAL BREEDING MODULE
  ]
  if (farmer-profile = "traditional") [
    uncontrolled-breeding                                                            ;;## CONTROLLED/NATURAL BREEDING MODULE
  ]
  if (farmer-profile = "market") or (farmer-profile = "market-fsb") [
    controlled-breeding                                                              ;;## CONTROLLED/NATURAL BREEDING MODULE
  ]
  if (farmer-profile = "environmental") [
    controlled-breeding                                                              ;;## CONTROLLED/NATURAL BREEDING MODULE
  ]

  update-grass-height

  update-prices                                                                      ;;## SALES MODULE

  if (farmer-profile = "traditional") [
    ordinary-sale-males                                                              ;;## ORDINARY SALES MODULE
  ]

  if (farmer-profile = "market") or (farmer-profile = "market-fsb") [
    ordinary-sale-males                                                              ;;## ORDINARY SALES MODULE
    ordinary-sale-old-cows                                                           ;;## ORDINARY SALES MODULE
    ordinary-sale-old-bulls
    ordinary-sale-non-replacement-females                                                       ;;## ORDINARY SALES MODULE

    extraordinary-sale-males-market-farmer                                           ;;## EXTRAORDINARY SALES MODULE
    extraordinary-sale-old-cows-market-farmer                                        ;;## EXTRAORDINARY SALES MODULE
    extraordinary-sale-non-replacement-females-market-farmer                                    ;;## EXTRAORDINARY SALES MODULE
  ]

  if (farmer-profile = "environmental") [                                            ;;## ORDINARY SALES MODULE
    ordinary-sale-males                                                              ;;## ORDINARY SALES MODULE
    ordinary-sale-old-cows                                                           ;;## ORDINARY SALES MODULE
    ordinary-sale-old-bulls
    ordinary-sale-non-replacement-females                                                       ;;## ORDINARY SALES MODULE

    extraordinary-sale-males-environmental-farmer                                    ;;## EXTRAORDINARY SALES MODULE
    extraordinary-sale-old-cows-environmental-farmer                                 ;;## EXTRAORDINARY SALES MODULE
    extraordinary-sale-non-replacement-females-environmental-farmer                             ;;## EXTRAORDINARY SALES MODULE
  ]

  farm-balance                                                                       ;;## SALES MODULE

  effort                                                                             ;;## WELLBEING MODULE



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
  ]




end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cattle behavior
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move                                                                              ;; once the grass height of each patch is updated, if the grass height in a patch is minor than 5 cm (the minimum grass height that maintains the live weight of a cow), the cows moves to another patch. Whether the cows move to a neighboring random patch or to the neighboring patch with the highest grass height is determined by the "perception" slider in the interface.
  if (spatial-management = "free grazing") [                                         ;; cow movement rules for the free grazing management strategy
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

    if (farmer-profile = "none") or (farmer-profile = "traditional") or (farmer-profile = "environmental") [             ;; Traditional and environmental farmers move cows at the end of each season
      if season-days >= season-length [
        set ticks-since-here 0
        ask cows
        [ifelse paddock-a = 1
          [let next-paddock one-of patches with [paddock-b = 1] move-to next-paddock]
          [ifelse paddock-b = 1
            [let next-paddock one-of patches with [paddock-c = 1] move-to next-paddock]
            [ifelse paddock-c = 1
              [let next-paddock one-of patches with [paddock-d = 1] move-to next-paddock]
              [let next-paddock one-of patches with [paddock-a = 1] move-to next-paddock]]]]]]

    if (farmer-profile = "market") or (farmer-profile = "market-fsb") [                                                                                     ;; Market-oriented farmers move cows from one plot to another when the average live weight of the cows is below a threshold (determined by the "RG-live-weight-threshold" slider in the interface).
      if RG-market-farmer-live-weight-threshold > mean [live-weight] of cows with [born-calf? = false] and ticks-since-here > RG-days-in-paddock [ ;; Once the animals are moved to the next paddock because they have met the criteria, because the effects of the new paddock on the animals' live weight take several days, and to avoid animals moving continuously from one paddock to another during these first days (because they will still have a value below the threshold), the minimum number of days the animals have to adapt to the new paddock before moving to the next is set with the "RG-days-in-paddock" slider.
        set ticks-since-here 0
        ask cows
        [ifelse paddock-a = 1
          [let next-paddock one-of patches with [paddock-b = 1] move-to next-paddock]
          [ifelse paddock-b = 1
            [let next-paddock one-of patches with [paddock-c = 1] move-to next-paddock]
            [ifelse paddock-c = 1
              [let next-paddock one-of patches with [paddock-d = 1] move-to next-paddock]
              [let next-paddock one-of patches with [paddock-a = 1] move-to next-paddock]]]]]]]

end


to LWG                                                                               ;; the live weight gain of each cow is calculated according to the number of centimeters of grass that correspond to each animal
ask cows [

    ifelse born-calf? = true
    [set live-weight-gain weight-gain-lactation]
    [ifelse grass-height >= 2                                                        ;; cows cannot eat grass less than 2 cm high
      [set live-weight-gain ( item current-season maxLWG - ( xi * e ^ ( - ni * grass-height ) ) ) / ( season-length * item current-season season-coef )]
      [set live-weight-gain live-weight * -0.005]]

    set live-weight live-weight + live-weight-gain
    if (heifer? = true) and live-weight > maxLWcow [set live-weight maxLWcow]
    if (adult-cow? = true) and live-weight > maxLWcow [set live-weight maxLWcow]
    if (steer? = true) and live-weight > maxLWbull [set live-weight maxLWbull]
    if (bull? = true) and live-weight > maxLWbull [set live-weight maxLWbull]                                                ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
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
         [set DDMC ((0.107 * metabolic-body-size * (- 0.0132 *  grass-height + 1.5132) + (0.141 * metabolic-body-size * live-weight-gain) ) / grass-energy) * category-coef]
         [set DDMC 0]]
    if DDMC < 0 [set DDMC 0]
  ]

end









to feed-supplementation                                                             ;;## FEED SUPPLEMENTATION MODULE

  set FS-cow 0 set FS-cow-with-calf 0 set FS-heifer 0 set FS-steer 0 set FS-weaned-calf 0 set FS-bull 0      ;; the daily cost of purchasing feed supplements is reset every tick. This allows to keep track of the amount of money spent on feed supplements each day.

  ask cows [set live-weight-gain-feed 0] ;; reseteamos el live-weight-gain-feed en cada tick

  if balance-historyXticks <= 0 [                                                                              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
    ask cows with [cow?] [set supplemented? false set kg-supplement-DM 0 set USD-supplement-DM 0]              ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
    ask cows with [bull?] [set supplemented? false set kg-supplement-DM 0 set USD-supplement-DM 0]             ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
    ask cows with [heifer?] [set supplemented? false set kg-supplement-DM 0 set USD-supplement-DM 0]           ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
    ask cows with [steer?] [set supplemented? false set kg-supplement-DM 0 set USD-supplement-DM 0]            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
    ask cows with [weaned-calf?] [set supplemented? false set kg-supplement-DM 0 set USD-supplement-DM 0]      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
    ask cows with [cow-with-calf?] [set supplemented? false set kg-supplement-DM 0 set USD-supplement-DM 0]    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ]


  if balance-historyXticks > 0 [                                                                ;; the farmer can buy feed for the animals if the balance of the system is positive (i.e. if there are savings).
    ask cows with [cow?] [ifelse live-weight < cow-min-weight-for-feed-sup [set supplemented? true] [set supplemented? false set kg-supplement-DM 0 set USD-supplement-DM 0]] ;; animals below the threshold set by the farmer (the "xxxx-min-weight-for-feed-sup" slider in the interface) are selected for feed supplementation
    ask cows with [bull?] [ifelse live-weight < bull-min-weight-for-feed-sup [set supplemented? true] [set supplemented? false set kg-supplement-DM 0 set USD-supplement-DM 0]]             ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
    ask cows with [heifer?] [ifelse live-weight < heifer/steer-min-weight-for-feed-sup [set supplemented? true] [set supplemented? false set kg-supplement-DM 0 set USD-supplement-DM 0]]
    ask cows with [steer?] [ifelse live-weight < heifer/steer-min-weight-for-feed-sup [set supplemented? true] [set supplemented? false set kg-supplement-DM 0 set USD-supplement-DM 0]]
    ask cows with [weaned-calf?] [ifelse live-weight < weaned-calf-min-weight-for-feed-sup [set supplemented? true] [set supplemented? false set kg-supplement-DM 0 set USD-supplement-DM 0]]
    ask cows with [cow-with-calf?] [ifelse live-weight < cow-with-calf-min-weight-for-feed-sup [set supplemented? true] [set supplemented? false set kg-supplement-DM 0 set USD-supplement-DM 0]]


    ask cows with [supplemented?] [                                       ;; PRIMERO, ASUMIMOS EL PESO MAXIMO QUE PUEDE GANAR UNA VACA AL DIA
      set live-weight-gain-max set-live-weight-gain-max

      set live-weight-gain-feed live-weight-gain-max - live-weight-gain   ;; SEGUNDO, EN FUNCIÓN DEL PESO MAXIMO QUE PUEDE GANAR LA VACA, CALCULAMOS EL PESO RESTANTE QUE QUEDA PARA ALCANZAR ESE PESO MAXIMO PARTIENDO DE LO QUE YA HA GANADO LA VACA

      set kg-supplement-DM live-weight-gain-feed * feed-sup-conversion-ratio  ;; TERCERO, CALCULAMOS LOS KG DE FORRAJE QUE HAY QUE COMPRAR PARA QUE LA VACA LLEGUE AL PESO MAXIMO DIARIO

    ]


    ask cows with [supplemented?] [
      set USD-supplement-DM item current-season supplement-prices * kg-supplement-DM]           ;; the price of the feed supplement required to keep the animals above the threshold


    ask cows with [supplemented?] [
      ifelse sum [USD-supplement-DM] of cows with [supplemented?] > balance-historyXticks
      [                                                                                       ;; if the money needed to supplement all the animals selected for supplementation is greater than the savings of the livestock system (balance-historyXticks)...
        set kg-supplement-DM (balance-historyXticks / count cows with [supplemented?]) / item current-season supplement-prices  ;; ...the kg of supplement to be purchased is calculated based on the current system's savings and divided among the animals selected for supplementation
        set USD-supplement-DM kg-supplement-DM * item current-season supplement-prices

        set live-weight-gain-feed (kg-supplement-DM / feed-sup-conversion-ratio)
        set live-weight live-weight + live-weight-gain-feed]

      [                                                                                   ;; if the money needed is below than the savings of the livestock system (i.e., if the farmer has enough money)...
        set live-weight-gain-feed live-weight-gain-max - live-weight-gain
        set live-weight live-weight + live-weight-gain-feed]

      if (heifer? = true) and live-weight > maxLWcow [set live-weight maxLWcow]
      if (adult-cow? = true) and live-weight > maxLWcow [set live-weight maxLWcow]
      if (steer? = true) and live-weight > maxLWbull [set live-weight maxLWbull]
      if (bull? = true) and live-weight > maxLWbull [set live-weight maxLWbull]      ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

      if live-weight < 0 [set live-weight 0]

      set animal-units live-weight / set-1-AU

      set FS-cow sum [USD-supplement-DM] of cows with [cow?]                                    ;; once the animals have been supplemented, the daily cost of purchasing supplements is calculated for each age group
      set FS-bull sum [USD-supplement-DM] of cows with [bull?]             ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
      set FS-heifer sum [USD-supplement-DM] of cows with [heifer?]
      set FS-cow-with-calf sum [USD-supplement-DM] of cows with [cow-with-calf?]
      set FS-steer sum [USD-supplement-DM] of cows with [steer?]
      set FS-weaned-calf sum [USD-supplement-DM] of cows with [weaned-calf?]]

  ]

  set supplement-cost FS-cow + FS-cow-with-calf + FS-heifer + FS-steer + FS-weaned-calf + FS-bull        ;; once the daily cost has been calculated for each age group, the TOTAL daily cost (i.e. the total cost to feed ALL animals in one day) is calculated

end







to feed-supplementation-for-controlled-breeding                                                 ;;## NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW ;; Feed supplementation for breeding cows

  set FSB-cow 0 ;; the daily cost of purchasing feed supplements is reset every tick. This allows to keep track of the amount of money spent on feed supplements each day.

  ask cows with [cow?] [set live-weight-gain-feed-breeding 0] ;; reseteamos el live-weight-gain-feed-breeding en cada tick

  ask cows with [cow?] [if pregnant? = false [set kg-supplement-DM-breeding 0 set USD-supplement-DM-breeding 0]]
  ;ask cows with [cow?] [set kg-supplement-DM-breeding 0 set USD-supplement-DM-breeding 0]

  ask cows with [cow? and pregnant? = false] [
  ;ask cows with [cow?] [

    if live-weight > cow-min-weight-for-feed-sup [

      if balance-historyXticks <= 0 [
        ask cows with [cow? and pregnant? = false] [set supplemented? false set kg-supplement-DM-breeding 0 set USD-supplement-DM-breeding 0]]
        ;ask cows with [cow?] [set supplemented? false set kg-supplement-DM-breeding 0 set USD-supplement-DM-breeding 0]]

      if balance-historyXticks > 0 [
        ask cows with [cow? and pregnant? = false] [
          ifelse live-weight < min-weight-for-breeding
          [set supplemented? true]
          [set supplemented? false set kg-supplement-DM-breeding 0 set USD-supplement-DM-breeding 0]]

        ask cows with [cow? and pregnant? = false and supplemented?] [                                       ;; PRIMERO, ASUMIMOS EL PESO MAXIMO QUE PUEDE GANAR UNA VACA AL DIA
          set live-weight-gain-max set-live-weight-gain-max
          set live-weight-gain-feed-breeding live-weight-gain-max - live-weight-gain   ;; SEGUNDO, EN FUNCIÓN DEL PESO MAXIMO QUE PUEDE GANAR LA VACA, CALCULAMOS EL PESO RESTANTE QUE QUEDA PARA ALCANZAR ESE PESO MAXIMO PARTIENDO DE LO QUE YA HA GANADO LA VACA
          set kg-supplement-DM-breeding live-weight-gain-feed-breeding * feed-sup-conversion-ratio  ;; TERCERO, CALCULAMOS LOS KG DE FORRAJE QUE HAY QUE COMPRAR PARA QUE LA VACA LLEGUE AL PESO MAXIMO DIARIO
        ]

        ask cows with [cow? and pregnant? = false and supplemented?] [
          set USD-supplement-DM-breeding item current-season supplement-prices * kg-supplement-DM-breeding]           ;; the price of the feed supplement required to keep the animals above the threshold

        ask cows with [cow? and pregnant? = false and supplemented?] [
          ifelse sum [USD-supplement-DM-breeding] of cows with [cow? and pregnant? = false and supplemented?] > balance-historyXticks
          [                                                                                       ;; if the money needed to supplement all the animals selected for supplementation is greater than the savings of the livestock system (balance-historyXticks)...
            set kg-supplement-DM-breeding (balance-historyXticks / count cows with [cow? and pregnant? = false and supplemented?]) / item current-season supplement-prices  ;; ...the kg of supplement to be purchased is calculated based on the current system's savings and divided among the animals selected for supplementation
            set USD-supplement-DM-breeding kg-supplement-DM-breeding * item current-season supplement-prices
            set live-weight-gain-feed-breeding (kg-supplement-DM-breeding / feed-sup-conversion-ratio)
            set live-weight live-weight + live-weight-gain-feed-breeding]
          [                                                                                   ;; if the money needed is below than the savings of the livestock system (i.e., if the farmer has enough money)...
            set live-weight-gain-feed-breeding live-weight-gain-max - live-weight-gain
            set live-weight live-weight + live-weight-gain-feed-breeding]

          if (adult-cow? = true) and live-weight > maxLWcow [set live-weight maxLWcow]

          if live-weight < 0 [set live-weight 0]

          set animal-units live-weight / set-1-AU

          set FSB-cow sum [USD-supplement-DM-breeding] of cows with [cow? and pregnant? = false and supplemented?]]]]

          ;set FSB-cow sum [USD-supplement-DM-breeding] of cows with [cow?]]]]

]

  set supplement-cost supplement-cost + FSB-cow

end






to grow-livestock-natural-weaning-none-profile                                                    ;;## EARLY/NATURAL WEANING MODULE ;; this procedure dictates the rules for the death or progression of animals to the next age class, as well as the lactation period of animals in a NATURAL weaning scenario.
ask cows [
    set age age + days-per-tick
    if age > cow-age-max [die]
    ifelse live-weight < min-weight
    [set mortality-rate except-mort-rate]
    [set mortality-rate natural-mortality-rate]
    if random-float 1 < mortality-rate [die]

    ifelse age / 368 > age-sell-old-cow/bull [set old? true] [set old? false]                                                       ;;OLDNEW###################################################

    ask cows with [cow-with-calf? and not any? my-links] [become-cow]                                                      ;; if the link with the child (an agent with the state "born-calf") is lost (this happens when the child dies), the mother changes from the state "cow-with-calf" to the state "cow".
    ask cows with [born-calf-female? and not any? my-links ] [ become-weaned-calf-female ]                                 ;; if the link with the mother (an agent with a "cow-with-calf?" state) is lost (this happens when the mother dies, or when the mother switches from a "cow-with-calf?" state to a "cow?" state), the calf weans prematurely.
    ask cows with [born-calf-male? and not any? my-links ] [ become-weaned-calf-male ]

    if (born-calf-female? = true) and (age >= weaned-calf-age-min) [become-weaned-calf-female ask my-out-links [die]]       ;; when the lactating calf moves on to the next age group (weaned-calf), the link (dependency) with its parent is terminated
    if (born-calf-male? = true) and (age >= weaned-calf-age-min) [become-weaned-calf-male ask my-out-links [die]]
    if (weaned-calf-female? = true) and (age >= heifer-age-min) [become-heifer]

    if (weaned-calf-male? = true) and (age >= heifer-age-min) [become-bull]                                                                                              ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

    if (heifer? = true) and (age >= cow-age-min) and (live-weight >= 280 ) [become-cow]
    if cow-with-calf? = true [set lactating-time lactating-time + days-per-tick]
    if lactating-time >= lactation-period [become-cow]
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

    ifelse age / 368 > age-sell-old-cow/bull [set old? true] [set old? false]                                                       ;;OLDNEW###################################################

    ask cows with [cow-with-calf? and not any? my-links] [become-cow]                                                      ;; if the link with the child (an agent with the state "born-calf") is lost (this happens when the child dies), the mother changes from the state "cow-with-calf" to the state "cow".
    ask cows with [born-calf-female? and not any? my-links ] [ become-weaned-calf-female ]                                 ;; if the link with the mother (an agent with a "cow-with-calf?" state) is lost (this happens when the mother dies, or when the mother switches from a "cow-with-calf?" state to a "cow?" state), the calf weans prematurely.
    ask cows with [born-calf-male? and not any? my-links ] [ become-weaned-calf-male ]

    if (born-calf-female? = true) and (age >= weaned-calf-age-min) [become-weaned-calf-female ask my-out-links [die]]       ;; when the lactating calf moves on to the next age group (weaned-calf), the link (dependency) with its parent is terminated
    if (born-calf-male? = true) and (age >= weaned-calf-age-min) [become-weaned-calf-male ask my-out-links [die]]
    if (weaned-calf-female? = true) and (age >= heifer-age-min) [become-heifer]

    if (weaned-calf-male? = true) and (age >= heifer-age-min) [
      ifelse count cows with [bull?] > 0
      [if bull:cow-ratio > 0 [if count cows with [bull?] <= round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio) [ask up-to-n-of (round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio) - count cows with [bull?]) cows with [(weaned-calf-male? = true) and (age >= heifer-age-min)] [become-bull]]]]                 ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
      [ask n-of 1 cows with [(weaned-calf-male? = true) and (age >= heifer-age-min)] [become-bull]]]

    if (weaned-calf-male? = true) and (age >= heifer-age-min) [become-steer]

    if (heifer? = true) and (age >= cow-age-min) and (live-weight >= 280 ) [become-cow]
    if cow-with-calf? = true [set lactating-time lactating-time + days-per-tick]
    if lactating-time >= lactation-period [become-cow]
  ]
end


to grow-livestock-early-weaning                                                      ;;## EARLY/NATURAL WEANING MODULE ;; this procedure dictates the rules for the death or progression of animals to the next age class, as well as the lactation period of animals in a EARLY weaning scenario.

  ask cows with [weaning-calf? = true] [set weaning-calf? false]                                                                                ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ask cows [
    set age age + days-per-tick
    if age > cow-age-max [die]
    ifelse live-weight < min-weight
    [set mortality-rate except-mort-rate]
    [set mortality-rate natural-mortality-rate]
    if random-float 1 < mortality-rate [die]

    ifelse age / 368 > age-sell-old-cow/bull [set old? true] [set old? false]                                                       ;;OLDNEW###################################################

    if (cow-with-calf? = true and live-weight < early-weaning-threshold) [become-cow set weaning-calf? true ask my-out-links [die]]               ;; ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWW if the mother (an agent with a "cow-with-calf?" state) is below a certain weight, it will switch to the "cow?" state and will kill the link with its child (an agent with a "born-calf" state). This weight is determined by the "early-weaning-threshold" slider in the interface.

    ask cows with [cow-with-calf? and not any? my-links] [become-cow]                                                      ;; if the link with the child (an agent with the state "born-calf") is lost (this happens when the child dies), the mother changes from the state "cow-with-calf" to the state "cow".
    ask cows with [born-calf-female? and not any? my-links ] [ become-weaned-calf-female ]                                 ;; if the link with the mother (an agent with a "cow-with-calf?" state) is lost (this happens when the mother dies, or when the mother switches from a "cow-with-calf?" state to a "cow?" state), the calf weans prematurely.
    ask cows with [born-calf-male? and not any? my-links ] [ become-weaned-calf-male ]

    if (born-calf-female? = true) and (age >= weaned-calf-age-min) [become-weaned-calf-female ask my-out-links [die]]       ;; when the lactating calf moves on to the next age group (weaned-calf), the link (dependency) with its parent is terminated
    if (born-calf-male? = true) and (age >= weaned-calf-age-min) [become-weaned-calf-male ask my-out-links [die]]
    if (weaned-calf-female? = true) and (age >= heifer-age-min) [become-heifer]

    if (weaned-calf-male? = true) and (age >= heifer-age-min) [
      ifelse count cows with [bull?] > 0
      [if bull:cow-ratio > 0 [if count cows with [bull?] <= round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio) [ask up-to-n-of (round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio) - count cows with [bull?]) cows with [(weaned-calf-male? = true) and (age >= heifer-age-min)] [become-bull]]]]                 ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
      [ask n-of 1 cows with [(weaned-calf-male? = true) and (age >= heifer-age-min)] [become-bull]]]

    if (weaned-calf-male? = true) and (age >= heifer-age-min) [become-steer]

    if (heifer? = true) and (age >= cow-age-min) and (live-weight >= 280 ) [become-cow]
    if cow-with-calf? = true [set lactating-time lactating-time + days-per-tick]
    if lactating-time >= lactation-period [become-cow]
  ]
end


to uncontrolled-breeding                                                             ;;## CONTROLLED/NATURAL BREEDING MODULE ;; this procedure dictates the rules for which each of the reproductive age classes (i.e., heifer, cow, cow-with-calf) can become pregnant in an UNCONTROLLED breeding scenario, as well as the gestation period of animals
  ask cows [
    if (heifer? = true) or (cow? = true) or (cow-with-calf? = true) [set pregnancy-rate (1 / (1 + coefA * e ^ (- coefB * live-weight)))]
    ;;;if (heifer? = true) or (cow? = true) or (cow-with-calf? = true) [set pregnancy-rate (1 / (1 + coefA * e ^ (- coefB * live-weight))) / 368]  ;; alternative version, in which the PR is divided by 368.

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

    if bull? = true [set price item current-season bull-prices set value price * live-weight]       ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cattle sales: ordinary sales                                                      ;; Ordinary cattle sales are held on the first day of fall.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to ordinary-sale-males                                                                        ;;## ORDINARY SALES MODULE ;; Ordinary sale of weaned male calves and steers, determined by the maximum number of males the farmer wishes to keep in the system ("keep-n-steers" slider in the interface)

  if current-season = 3 and (season-days = 1) [

    if any? cows with [weaned-calf-male?] [

      if count cows with [bull?] >= 1 [
      if count cows with [weaned-calf-male?] > round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio) [

        while [any? cows with [weaned-calf-male? and sale? = false] and count cows with [weaned-calf-male? and sale? = false] > round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio)] [

          if (ordinary-sale-of-cows-with = "highest live weight") [
            ask max-n-of 1 cows with [weaned-calf-male? and sale? = false] [live-weight] [
              set sale? true
              set OS-males-weaned-calf sum [value] of cows with [weaned-calf-male? and sale?]]]

          if (ordinary-sale-of-cows-with = "lowest live weight") [
            ask min-n-of 1 cows with [weaned-calf-male? and sale? = false] [live-weight] [
              set sale? true
              set OS-males-weaned-calf sum [value] of cows with [weaned-calf-male? and sale?]]]]]]]]

  if current-season = 3 and (season-days = 1) [
    if any? cows with [steer?] [
            ask cows with [steer? and sale? = false] [
              set sale? true
              set OS-males-steer sum [value] of cows with [steer? and sale?]]]]


  if current-season = 3 and (season-days = 1) [                                ;;BULLNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

    if count cows with [bull?] > 1  [

      if count cows with [bull?] > round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio) [

        while [any? cows with [bull? and sale? = false] and count cows with [bull? and sale? = false] > round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio) and count cows with [bull? and sale? = false] > 1] [

          if (ordinary-sale-of-cows-with = "highest live weight") [
            ask max-n-of 1 cows with [bull? and sale? = false] [live-weight] [
              set sale? true
              set OS-bull sum [value] of cows with [bull? and sale?]]]

          if (ordinary-sale-of-cows-with = "lowest live weight") [
            ask min-n-of 1 cows with [bull? and sale? = false] [live-weight] [
              set sale? true
              set OS-bull sum [value] of cows with [bull? and sale?]]]]]]]

  set OS-males-effort count cows with [sale?] * sales-effort-time          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ask cows with [sale?] [die]

end



to ordinary-sale-old-cows                                                               ;;## ORDINARY SALES MODULE ;; Ordinary sale of old empty cows. The age at which a cow is considered old is determined by the "age-sell-old-cow" slider in the interface.

  if current-season = 3 and (season-days = 1) [
    if any? cows with [cow? and old? = true] [

      if count cows with [cow? and old? = true] > (count cows with [cow? and old? = true] - count cows with [heifer?]) [                            ;;FEMALESALESNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW  solo se venden old cows cuando hay heifers (futuras madres), y se vende el mismo número de old cows que heifers hay en el sistema
        ;while [any? cows with [cow? and old? = true and sale? = false and pregnant? = false] and count cows with [sale? = false] > keep-MIN-n-cattle] [      ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).

        while [any? cows with [cow? and old? = true and sale? = false] and count cows with [cow? and old? = true and sale? = false] > (count cows with [cow? and old? = true] - count cows with [heifer?])] [
          if (ordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? and old? = true and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).

            ask max-n-of 1 cows with [cow? and old? = true and sale? = false] [live-weight] [
              set sale? true
              set OS-old-cow sum [value] of cows with [cow? and old? = true and sale?]]]

          if (ordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? and old? = true and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).

            ask min-n-of 1 cows with [cow? and old? = true and sale? = false] [live-weight] [
              set sale? true
              set OS-old-cow sum [value] of cows with [cow? and old? = true and sale?]]]]]]]

  set OS-old-cow-effort count cows with [sale?] * sales-effort-time          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ask cows with [sale?] [die]

 end






to ordinary-sale-old-bulls                                                               ;;## ORDINARY SALES MODULE ;; Ordinary sale of old empty cows. The age at which a cow is considered old is determined by the "age-sell-old-cow" slider in the interface.

  if current-season = 3 and (season-days = 1) [
    if any? cows with [bull? and old? = true] [
      if count cows with [bull?] > 1 [
        ;while [any? cows with [cow? and old? = true and sale? = false and pregnant? = false] and count cows with [sale? = false] > keep-MIN-n-cattle] [      ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).

        ;while [any? cows with [bull? and old? = true and sale? = false] and count cows with [bull? and sale? = false] > 1] [
      while [any? cows with [bull? and old? = true and sale? = false] and round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio) < 1] [
          if (ordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? and old? = true and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).

            ask max-n-of 1 cows with [bull? and old? = true and sale? = false] [live-weight] [
              set sale? true
              set OS-old-bull sum [value] of cows with [bull? and old? = true and sale?]]]

          if (ordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? and old? = true and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).

            ask min-n-of 1 cows with [bull? and old? = true and sale? = false] [live-weight] [
              set sale? true
              set OS-old-bull sum [value] of cows with [bull? and old? = true and sale?]]]]]]]

  set OS-old-bull-effort count cows with [sale?] * sales-effort-time          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ask cows with [sale?] [die]

 end




to ordinary-sale-non-replacement-females                                           ;;## ORDINARY SALES MODULE ;; Ordinary sale of heifers and cows. The number of heifers and cows sold is determined by the maximum number of livestock the farmer wishes to keep in the system ("keep-n-cattle" slider in the interface). This is an early attempt to represent the maximum number of animals a farmer can manage.

  if current-season = 3 and (season-days = 1) [                                     ;;FEMALESALESNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW  De normal solo se venden hembras de no reposición correspondientes a weaned-calf-females y heifers

    if any? cows with [weaned-calf-female?] [

        while [any? cows with [weaned-calf-female? and sale? = false] and count cows with [weaned-calf-female? and sale? = false] > (keep-MAX-n-breeding-cows - count cows with [adult-cow?])] [

          if (ordinary-sale-of-cows-with = "highest live weight") [
            ask max-n-of 1 cows with [weaned-calf-female? and sale? = false] [live-weight] [
              set sale? true
              set OS-females-weaned-calf sum [value] of cows with [weaned-calf-female? and sale?]]]

          if (ordinary-sale-of-cows-with = "lowest live weight") [
            ask min-n-of 1 cows with [weaned-calf-female? and sale? = false] [live-weight] [
              set sale? true
              set OS-females-weaned-calf sum [value] of cows with [weaned-calf-female? and sale?]]]]]]



  if current-season = 3 and (season-days = 1) [

    if any? cows with [heifer?] [

        ;while [any? cows with [cow? or heifer? and pregnant? = false and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle] [         ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
        while [any? cows with [heifer? and sale? = false] and count cows with [heifer? and sale? = false] > (keep-MAX-n-breeding-cows - count cows with [adult-cow?])] [

          if (ordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask max-n-of 1 cows with [heifer? and sale? = false] [live-weight] [
            set sale? true
            set OS-heifer sum [value] of cows with [heifer? and sale?]]]


          if (ordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask min-n-of 1 cows with [heifer? and sale? = false] [live-weight] [
                set sale? true
                set OS-heifer sum [value] of cows with [heifer? and sale?]]]]]]




  if current-season = 3 and (season-days = 1) [

    if any? cows with [adult-cow?] [

        ;while [any? cows with [cow? or heifer? and pregnant? = false and sale? = false] and count cows with [sale? = false] > keep-MIN-n-cattle] [         ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
        while [any? cows with [adult-cow? and sale? = false] and count cows with [adult-cow? and sale? = false] > keep-MAX-n-breeding-cows] [

          if (ordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask max-n-of 1 cows with [adult-cow? and sale? = false] [live-weight] [           ;;FEMALESALESNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW   solo se venden las vacas NO preñadas
            set sale? true
            set OS-cow sum [value] of cows with [adult-cow? and sale?]]]


          if (ordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask min-n-of 1 cows with [adult-cow? and sale? = false] [live-weight] [
                set sale? true
                set OS-cow sum [value] of cows with [adult-cow? and sale?]]]]]]


    set OS-females-effort count cows with [sale?] * sales-effort-time          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


  ask cows with [sale?] [die]

end








;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cattle sales: extraordinary sales
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Extraordinary sales for the MARKET-ORIENTED FARMER


to extraordinary-sale-males-market-farmer                                           ;;## EXTRAORDINARY SALES MODULE ;; Extraordinary sale of male animals for the market-oriented farmer. If the market-oriented farmer profile is selected, the extraordinary sale of male animals takes place when the average live weight of all animals in the system is below a threshold (minimum weight set by the user, "ES-market-farmer-min-weight" slider in the interface).

  if any? cows with [weaned-calf-male?] [
    if mean [live-weight] of cows with [born-calf? = false] < market-farmer-ES-min-weight and count cows with [weaned-calf-male?] > round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio) [
      if (extraordinary-sale-of-cows-with = "highest live weight") [
        ask max-n-of 1 cows with [weaned-calf-male? and sale? = false] [live-weight] [
          set sale? true
          set ES-males-weaned-calf sum [value] of cows with [weaned-calf-male? and sale?]]]
      if (extraordinary-sale-of-cows-with = "lowest live weight") [
        ask min-n-of 1 cows with [weaned-calf-male? and sale? = false] [live-weight] [
          set sale? true
          set ES-males-weaned-calf sum [value] of cows with [weaned-calf-male? and sale?]]]]]

  if any? cows with [steer?] [
    if mean [live-weight] of cows with [born-calf? = false] < market-farmer-ES-min-weight [
      if (extraordinary-sale-of-cows-with = "highest live weight") [
        ask max-n-of 1 cows with [steer? and sale? = false] [live-weight] [
          set sale? true
          set ES-males-steer sum [value] of cows with [steer? and sale?]]]

      if (extraordinary-sale-of-cows-with = "lowest live weight") [
        ask min-n-of 1 cows with [steer? and sale? = false] [live-weight] [
          set sale? true
          set ES-males-steer sum [value] of cows with [steer? and sale?]]]]]

  set ES-males-effort count cows with [sale?] * sales-effort-time          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ask cows with [sale?] [die]

  end





to extraordinary-sale-old-cows-market-farmer                                                               ;;## EXTRAORDINARY SALES MODULE ;; Extrardinary sale of old cows for the market-oriented farmer. The age at which a cow is considered old is determined by the "age-sell-old-cow" slider in the interface.

  ;; when there are no more males available for the extraordinary sales (because the "keep-MAX-n-bulls" number is the maximum number of breeding males the farmer wants to have in the system), the farmer starts selling old cows
    if any? cows with [cow? and old? = true] [

      ;if any? cows with [cow? and old? = true and pregnant? = false] [  ;;       alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
      if mean [live-weight] of cows with [born-calf? = false] < market-farmer-ES-min-weight and count cows with [adult-cow?] > keep-MIN-n-breeding-cows [
        if (extraordinary-sale-of-cows-with = "highest live weight") [
          ;ask max-n-of 1 cows with [cow? and old? = true and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).

          ask max-n-of 1 cows with [cow? and old? = true and sale? = false] [live-weight] [
            set sale? true
            set ES-old-cow sum [value] of cows with [cow? and old? = true and sale?]]]

        if (extraordinary-sale-of-cows-with = "lowest live weight") [
          ;ask min-n-of 1 cows with [cow? and old? = true and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).

          ask min-n-of 1 cows with [cow? and old? = true and sale? = false] [live-weight] [
            set sale? true
              set ES-old-cow sum [value] of cows with [cow? and old? = true and sale?]]]]]

  set ES-old-cow-effort count cows with [sale?] * sales-effort-time          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ask cows with [sale?] [die]

 end






to extraordinary-sale-non-replacement-females-market-farmer                                           ;;## EXTRAORDINARY SALES MODULE ;; Extraordinary sale of heifers and cows for the market-oriented farmer

                                       ;;FEMALESALESNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW  De normal solo se venden hembras de no reposición correspondientes a weaned-calf-females y heifers

  if any? cows with [weaned-calf-female?] [

    if mean [live-weight] of cows with [born-calf? = false] < market-farmer-ES-min-weight and count cows with [adult-cow?] > keep-MIN-n-breeding-cows [

          if (ordinary-sale-of-cows-with = "highest live weight") [
            ask max-n-of 1 cows with [weaned-calf-female? and sale? = false] [live-weight] [
              set sale? true
              set ES-females-weaned-calf sum [value] of cows with [weaned-calf-female? and sale?]]]

          if (ordinary-sale-of-cows-with = "lowest live weight") [
            ask min-n-of 1 cows with [weaned-calf-female? and sale? = false] [live-weight] [
              set sale? true
              set ES-females-weaned-calf sum [value] of cows with [weaned-calf-female? and sale?]]]]]



    if any? cows with [heifer?] [

    if mean [live-weight] of cows with [born-calf? = false] < market-farmer-ES-min-weight and count cows with [adult-cow?] > keep-MIN-n-breeding-cows [

          if (ordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask max-n-of 1 cows with [heifer? and sale? = false] [live-weight] [
            set sale? true
            set ES-heifer sum [value] of cows with [heifer? and sale?]]]

          if (ordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask min-n-of 1 cows with [heifer? and sale? = false] [live-weight] [
                set sale? true
                set ES-heifer sum [value] of cows with [heifer? and sale?]]]]]



    if any? cows with [adult-cow?] [

    if mean [live-weight] of cows with [born-calf? = false] < market-farmer-ES-min-weight and count cows with [adult-cow?] > keep-MIN-n-breeding-cows [

          if (ordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask max-n-of 1 cows with [adult-cow? and sale? = false] [live-weight] [           ;;FEMALESALESNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW   solo se venden las vacas NO preñadas
            set sale? true
            set ES-cow sum [value] of cows with [adult-cow? and sale?]]]


          if (ordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask min-n-of 1 cows with [adult-cow? and sale? = false] [live-weight] [
                set sale? true
                set ES-cow sum [value] of cows with [adult-cow? and sale?]]]]]


  set ES-females-effort count cows with [sale?] * sales-effort-time          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ask cows with [sale?] [die]

end




;; Extraordinary sales for the ENVIRONMENTAL-ORIENTED FARMER


to extraordinary-sale-males-environmental-farmer                                           ;; ## EXTRAORDINARY SALES MODULE ;; Extraordinary sale of male animals for the environmental farmer. If the enviromental-oriented farmer profile is selected, the extraordinary sale of male animals takes place when the Stocking Rate (SR) of the farm is above the desirable SR ("ES-env-farmer-SR" slider in the interface).

  ;if season-days = 2 [

    if any? cows with [weaned-calf-male?] [
    if sum [animal-units] of cows with [born-calf? = false] > estimated-carrying-capacity and count cows with [weaned-calf-male?] > round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio) [


        while [any? cows with [weaned-calf-male? and sale? = false] and sum [animal-units] of cows with [born-calf? = false and sale? = false] > estimated-carrying-capacity and count cows with [weaned-calf-male? and sale? = false] > round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:cow-ratio)] [

          if (extraordinary-sale-of-cows-with = "highest live weight") [
            ask max-n-of 1 cows with [weaned-calf-male? and sale? = false] [live-weight] [
              set sale? true
              set ES-males-weaned-calf sum [value] of cows with [weaned-calf-male? and sale?]]]

          if (extraordinary-sale-of-cows-with = "lowest live weight") [
            ask min-n-of 1 cows with [weaned-calf-male? and sale? = false] [live-weight] [
              set sale? true
              set ES-males-weaned-calf sum [value] of cows with [weaned-calf-male? and sale?]]]]]]

    if any? cows with [steer?] [

      if sum [animal-units] of cows with [born-calf? = false] > estimated-carrying-capacity [

          while [any? cows with [steer? and sale? = false] and sum [animal-units] of cows with [born-calf? = false and sale? = false] > estimated-carrying-capacity] [

          if (extraordinary-sale-of-cows-with = "highest live weight") [
            ask max-n-of 1 cows with [steer? and sale? = false] [live-weight] [
              set sale? true
              set ES-males-steer sum [value] of cows with [steer? and sale?]]]

          if (extraordinary-sale-of-cows-with = "lowest live weight") [
            ask min-n-of 1 cows with [steer? and sale? = false] [live-weight] [
              set sale? true
                set ES-males-steer sum [value] of cows with [steer? and sale?]]]]]]



  ;]

  set ES-males-effort count cows with [sale?] * sales-effort-time          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ask cows with [sale?] [die]

  end












to extraordinary-sale-old-cows-environmental-farmer                                                               ;;## EXTRAORDINARY SALES MODULE ;; Extraordinary sale of old cows for the environmental farmer. The age at which a cow is considered old is determined by the "age-sell-old-cow" slider in the interface.


  ;if season-days = 2 [

    if any? cows with [cow? and old? = true] [
      if sum [animal-units] of cows with [born-calf? = false] > estimated-carrying-capacity and count cows with [adult-cow?] > keep-MIN-n-breeding-cows [
        ;while [any? cows with [cow? and old? = true and sale? = false and pregnant? = false] and sum [animal-units] of cows with [sale? = false] / count patches > ES-env-farmer-SR] [      ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).

        while [any? cows with [cow? and old? = true and sale? = false] and count cows with [adult-cow? and sale? = false] > keep-MIN-n-breeding-cows and sum [animal-units] of cows with [born-calf? = false and sale? = false] > estimated-carrying-capacity] [
          if (extraordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? and old? = true and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).

            ask max-n-of 1 cows with [cow? and old? = true and sale? = false] [live-weight] [
              set sale? true
              set ES-old-cow sum [value] of cows with [cow? and old? = true and sale?]]]

          if (extraordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? and old? = true and pregnant? = false and sale? = false] [live-weight] [          ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).

            ask min-n-of 1 cows with [cow? and old? = true and sale? = false] [live-weight] [
              set sale? true
                set ES-old-cow sum [value] of cows with [cow? and old? = true and sale?]]]]]]

  ;]

  set ES-old-cow-effort count cows with [sale?] * sales-effort-time          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ask cows with [sale?] [die]

 end








to extraordinary-sale-non-replacement-females-environmental-farmer                                           ;;## EXTRAORDINARY SALES MODULE ;; Extraordinary sale of heifers and cows for the environmental farmer.

    ;if season-days = 2 [

    if any? cows with [weaned-calf-female?] [

        if sum [animal-units] of cows with [born-calf? = false] > estimated-carrying-capacity and count cows with [adult-cow?] > keep-MIN-n-breeding-cows [

        while [any? cows with [weaned-calf-female? and sale? = false] and count cows with [adult-cow? and sale? = false] > keep-MIN-n-breeding-cows and sum [animal-units] of cows with [born-calf? = false and sale? = false] > estimated-carrying-capacity] [

          if (extraordinary-sale-of-cows-with = "highest live weight") [
            ask max-n-of 1 cows with [weaned-calf-female? and sale? = false] [live-weight] [
              set sale? true
              set ES-females-weaned-calf sum [value] of cows with [weaned-calf-female? and sale?]]]

          if (extraordinary-sale-of-cows-with = "lowest live weight") [
            ask min-n-of 1 cows with [weaned-calf-female? and sale? = false] [live-weight] [
              set sale? true
              set ES-females-weaned-calf sum [value] of cows with [weaned-calf-female? and sale?]]]]]]



    if any? cows with [heifer?] [

    if sum [animal-units] of cows with [born-calf? = false] > estimated-carrying-capacity and count cows with [adult-cow?] > keep-MIN-n-breeding-cows [

         while [any? cows with [heifer? and sale? = false] and count cows with [adult-cow? and sale? = false] > keep-MIN-n-breeding-cows and sum [animal-units] of cows with [born-calf? = false and sale? = false] > estimated-carrying-capacity] [

          if (extraordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask max-n-of 1 cows with [heifer? and sale? = false] [live-weight] [
            set sale? true
            set ES-heifer sum [value] of cows with [heifer? and sale?]]]

          if (extraordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask min-n-of 1 cows with [heifer? and sale? = false] [live-weight] [
                set sale? true
              set ES-heifer sum [value] of cows with [heifer? and sale?]]]]]]



    if any? cows with [adult-cow?] [

    if sum [animal-units] of cows with [born-calf? = false] > estimated-carrying-capacity and count cows with [adult-cow?] > keep-MIN-n-breeding-cows [

        while [any? cows with [adult-cow? and sale? = false] and count cows with [adult-cow? and sale? = false] > keep-MIN-n-breeding-cows and sum [animal-units] of cows with [born-calf? = false and sale? = false] > estimated-carrying-capacity] [

          if (extraordinary-sale-of-cows-with = "highest live weight") [
            ;ask max-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask max-n-of 1 cows with [adult-cow? and sale? = false] [live-weight] [           ;;FEMALESALESNEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW   solo se venden las vacas NO preñadas
            set sale? true
            set ES-cow sum [value] of cows with [adult-cow? and sale?]]]


          if (extraordinary-sale-of-cows-with = "lowest live weight") [
            ;ask min-n-of 1 cows with [cow? or heifer? and pregnant? = false and sale? = false] [live-weight] [                                                                           ;; alternative version where pregnant cows are not sold. This version only makes sense if PR is divided by 368 (not the case in this current version of the model, but I will keep this line in case we decide to return to the previous PR version in the future).
            ask min-n-of 1 cows with [adult-cow? and sale? = false] [live-weight] [
              set sale? true
              set ES-cow sum [value] of cows with [adult-cow? and sale?]]]]]]

  ;]

  set ES-females-effort count cows with [sale?] * sales-effort-time          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

  ask cows with [sale?] [die]

end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Farm balance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to farm-balance                                                                      ;;## ORDINARY SALES MODULE
  set ordinary-sales-income OS-males-weaned-calf + OS-males-steer + OS-old-cow + OS-heifer + OS-cow + OS-bull + OS-old-bull + OS-females-weaned-calf

  set extraordinary-sales-income ES-males-weaned-calf + ES-males-steer + ES-old-cow + ES-heifer + ES-cow + ES-bull + ES-females-weaned-calf

  set other-cost set-other-monthly-costs / (368 / 12)

  set income ordinary-sales-income + extraordinary-sales-income
  set cost supplement-cost + other-cost
  set balance income - cost

  set OS-males-weaned-calf 0 set OS-males-steer 0 set OS-old-cow 0 set OS-heifer 0 set OS-cow 0 set OS-bull 0 set OS-old-bull 0 set OS-females-weaned-calf 0
  set ES-males-weaned-calf 0 set ES-males-steer 0 set ES-old-cow 0 set ES-heifer 0 set ES-cow 0 set ES-bull 0 set ES-females-weaned-calf 0


  if balance-historyXticks < 0 [set balance-historyXticks 0]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; WELLBEING MODULE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to effort

  ;; Feed supplementation effort                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set supplement-effort count cows with [supplemented?] * supplement-effort-time

  ;; Weaning effort                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set weaning-effort count cows with [weaning-calf?] * weaning-effort-time

  ;; Ordinary sales effort                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set OS-total-effort OS-males-effort + OS-old-cow-effort + OS-females-effort + OS-old-bull-effort
  set OS-total-effort-history-season OS-males-effort-historyXticks-season + OS-old-cow-effort-historyXticks-season + OS-females-effort-historyXticks-season + OS-old-bull-effort-historyXticks-season
  set OS-total-effort-history-year OS-males-effort-historyXticks-year + OS-old-cow-effort-historyXticks-year + OS-females-effort-historyXticks-year

  ;; Extraordinary sales effort                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set ES-total-effort ES-males-effort + ES-old-cow-effort + ES-females-effort
  set ES-total-effort-history-season ES-males-effort-historyXticks-season + ES-old-cow-effort-historyXticks-season + ES-females-effort-historyXticks-season
  set ES-total-effort-history-year ES-males-effort-historyXticks-year + ES-old-cow-effort-historyXticks-year + ES-females-effort-historyXticks-year + OS-old-bull-effort-historyXticks-year

  ;; Controlled breeding effort                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if farmer-profile = "market" [if current-season = controlled-breeding-season and (season-days = 1) [set breeding-effort breeding-effort-time]]
  if farmer-profile = "environmental" [if current-season = controlled-breeding-season and (season-days = 1) [set breeding-effort breeding-effort-time]]

  ;, Other daily efforts
  set other-daily-effort other-daily-effort-time


  ;; Rotational grazing effort                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  if (spatial-management = "rotational grazing") [
    if farmer-profile = "traditional" [if season-days >= season-length [set rotational-effort rotational-effort-time]]
    if farmer-profile = "market" [if RG-market-farmer-live-weight-threshold > mean [live-weight] of cows and ticks-since-here >= RG-days-in-paddock [set rotational-effort rotational-effort-time]]
    if farmer-profile = "environmental" [if season-days >= season-length [set rotational-effort rotational-effort-time]]]







  ;; Total effort                                    ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  set total-effort supplement-effort + weaning-effort + OS-total-effort + ES-total-effort + breeding-effort + rotational-effort + other-daily-effort
  set total-effort-history supplement-effort-historyXticks + weaning-effort-historyXticks + OS-males-effort-historyXticks + OS-old-bull-effort-historyXticks + OS-females-effort-historyXticks + OS-old-cow-effort-historyXticks + ES-males-effort-historyXticks + ES-old-cow-effort-historyXticks + ES-females-effort-historyXticks + breeding-effort-historyXticks + rotational-effort-historyXticks + other-daily-effort-historyXticks ;; Accumulated effort over time
  set total-effort-history-season supplement-effort-historyXticks-season + weaning-effort-historyXticks-season + OS-total-effort-history-season + ES-total-effort-history-season + breeding-effort-historyXticks-season + rotational-effort-historyXticks-season + other-daily-effort-historyXticks-season
  set total-effort-history-year supplement-effort-historyXticks-year + weaning-effort-historyXticks-year + OS-total-effort-history-year + ES-total-effort-history-year + breeding-effort-historyXticks-year + rotational-effort-historyXticks-year + other-daily-effort-historyXticks-year

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
  ;report mean [live-weight-gain] of cows with [born-calf? = false]
end


to-report ILWG_ACUMMULATED
  report mean [live-weight-gain-historyXticks] of cows
end

to-report ILWG_SEASON                                                                ;; outputs the mean IWLG throughout the season
  report mean [live-weight-gain-historyXticks-season] of cows
end

to-report ILWG_YEAR                                                                  ;; outputs the mean IWLG throughout the year
  report mean [live-weight-gain-historyXticks-year] of cows
end

to-report crop-efficiency                                                            ;; outputs the crop eficiency (DM consumed / DM offered)
  report sum [DDMC] of cows / (DM-cm-ha * sum [grass-height] of patches) * 100
 end

to-report accumulated-cost                                                           ;;## SALES MODULE ;; outputs the accumulated balance of the system since the start of the simulation (USD)
  report cost-historyXticks
end

to-report accumulated-income                                                         ;;## SALES MODULE ;; outputs the accumulated balance of the system since the start of the simulation (USD)
  report income-historyXticks
end

to-report accumulated-balance                                                        ;;## SALES MODULE ;; outputs the accumulated balance of the system since the start of the simulation (USD)
  report balance-historyXticks
end

to-report accumulated-supplement-effort-season                                       ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  report supplement-effort-historyXticks-season
end

to-report accumulated-supplement-effort-year                                         ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  report supplement-effort-historyXticks-year
end

to-report accumulated-weaning-effort-season                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  report weaning-effort-historyXticks-season
end

to-report accumulated-weaning-effort-year                                            ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  report weaning-effort-historyXticks-year
end

to-report acummulated-OS-males-effort-season
  report OS-males-effort-historyXticks-season                                        ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to-report acummulated-OS-males-effort-year
  report OS-males-effort-historyXticks-year                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to-report acummulated-OS-old-cow-effort-season
  report OS-old-cow-effort-historyXticks-season                                      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to-report acummulated-OS-old-cow-effort-year
  report OS-old-cow-effort-historyXticks-year                                        ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to-report acummulated-OS-old-bull-effort-season
  report OS-old-bull-effort-historyXticks-season
end

to-report acummulated-OS-old-bull-effort-year
  report OS-old-bull-effort-historyXticks-year
end

to-report acummulated-OS-females-effort-season
  report OS-females-effort-historyXticks-season                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to-report acummulated-OS-females-effort-year
  report OS-females-effort-historyXticks-year                                     ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to-report acummulated-ES-males-effort-season
  report ES-males-effort-historyXticks-season                                        ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to-report acummulated-ES-males-effort-year
  report ES-males-effort-historyXticks-year                                          ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to-report acummulated-ES-old-cow-effort-season
  report ES-old-cow-effort-historyXticks-season                                      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to-report acummulated-ES-old-cow-effort-year
  report ES-old-cow-effort-historyXticks-year                                        ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to-report acummulated-ES-females-effort-season
  report ES-females-effort-historyXticks-season                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to-report acummulated-ES-females-effort-year
  report ES-females-effort-historyXticks-year                                      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end







to-report acummulated-breeding-effort-season
  report breeding-effort-historyXticks-season                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to-report acummulated-breeding-effort-year
  report breeding-effort-historyXticks-year                                      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end









to-report acummulated-rotational-effort-season
  report rotational-effort-historyXticks-season                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to-report acummulated-rotational-effort-year
  report rotational-effort-historyXticks-year                                      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end






to-report acummulated-other-daily-effort-season
  report other-daily-effort-historyXticks-season                                   ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end

to-report acummulated-other-daily-effort-year
  report other-daily-effort-historyXticks-year                                      ;;## WELLBEING MODULE ;; NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
end








to-report DDMC_SEASON                                                                ;; outputs the mean IWLG throughout the season
  report mean [DDMC-historyXticks-season] of cows ;with [adult-cow?]
end

to-report DDMC_YEAR                                                                  ;; outputs the mean IWLG throughout the year
  report mean [DDMC-historyXticks-year] of cows ;with [adult-cow?]
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
403
204
781
583
-1
-1
37.0
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
0
ticks
30.0

BUTTON
29
11
84
44
Setup
Setup\nset balance 1000
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
864
200
897
initial-num-cows
initial-num-cows
0
1000
15.0
1
1
NIL
HORIZONTAL

SLIDER
92
333
194
366
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
1414
671
1752
851
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
820
722
1278
983
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
"Cows" 1.0 0 -6459832 true "" "plot mean [live-weight] of cows with [adult-cow?]"
"Average LW (all age classes)" 1.0 0 -7500403 true "" "plot mean [live-weight] of cows"

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
405
108
531
153
Stoking rate (AU/ha)
stocking-rate
4
1
11

SLIDER
11
1304
148
1337
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
1124
818
1360
863
Average LW (all age classes) (kg/animal)
mean [live-weight] of cows
3
1
11

SLIDER
210
134
361
167
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
1753
670
2076
851
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
16
323
86
379
0 = winter\n1 = spring\n2 = summer\n3 = fall
11
0.0
1

MONITOR
1416
854
1542
899
Average GH (cm)
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
1069
202
1102
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
1103
201
1136
initial-weight-heifers
initial-weight-heifers
100
1500
220.0
1
1
kg
HORIZONTAL

MONITOR
404
61
530
106
Area (ha)
;count patches ;grassland-area, 1 patch = 1 ha\n; Other option:\n; sum [animal-units] of cows / count patches\ncount patches
3
1
11

PLOT
822
984
1280
1210
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
"Cows" 1.0 0 -6459832 true "" "plot mean [live-weight-gain] of cows with [adult-cow?] + mean [live-weight-gain-feed] of cows with [adult-cow?] + mean [live-weight-gain-feed-breeding] of cows with [adult-cow?]"
"Average LWG (all age classes)" 1.0 0 -7500403 true "" "plot mean [live-weight-gain] of cows + mean [live-weight-gain-feed] of cows + mean [live-weight-gain-feed-breeding] of cows"

MONITOR
1754
900
1903
945
Total DDMC (kg)
sum [DDMC] of cows
3
1
11

MONITOR
1903
900
2077
945
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
897
200
930
initial-weight-cows
initial-weight-cows
100
750
260.0
1
1
kg
HORIZONTAL

PLOT
3157
1186
3499
1380
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
3157
1139
3287
1184
BCS of cows (points)
;(mean [live-weight] of cows with [cow?] - mean [min-weight] of cows with [cow?]) / 40\n;(mean [live-weight] of cows with [cow?] - (((mean [live-weight] of cows with [cow?]) * set-MW-1-AU) / set-1-AU)) / 40\n(mean [live-weight] of cows with [cow?] - set-MW-1-AU) / 40
2
1
11

PLOT
3511
1186
3921
1379
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
3512
1138
3644
1183
PR of cows (%)
mean [pregnancy-rate] of cows with [cow?] * 100
2
1
11

MONITOR
3643
1138
3786
1183
PR of cows-with-calf (%)
mean [pregnancy-rate] of cows with [cow-with-calf?] * 100
2
1
11

MONITOR
3786
1138
3923
1183
PR of heifers (%)
mean [pregnancy-rate] of cows with [heifer?] * 100
2
1
11

MONITOR
1754
855
1903
900
Total DM (kg)
dmgr
7
1
11

MONITOR
3288
1139
3443
1184
BCS of cows-with-calf (points)
;(mean [live-weight] of cows with [cow-with-calf?] - mean [min-weight] of cows with [cow-with-calf?]) / 40\n;(mean [live-weight] of cows with [cow-with-calf?] - (((mean [live-weight] of cows with [cow-with-calf?]) * set-MW-1-AU) / set-1-AU)) / 40\n\n(mean [live-weight] of cows with [cow-with-calf?] - set-MW-1-AU) / 40
2
1
11

MONITOR
1124
775
1368
820
Average LW (only adult cows) (kg/animal)
mean [live-weight] of cows with [adult-cow?]
3
1
11

MONITOR
1115
1036
1397
1081
Average ILWG (only adult cows) (kg/animal/day)
mean [live-weight-gain] of cows with [adult-cow?] + mean [live-weight-gain-feed] of cows with [adult-cow?] + mean [live-weight-gain-feed-breeding] of cows with [adult-cow?]
3
1
11

SLIDER
10
1150
202
1183
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
10
1181
202
1214
initial-weight-steers
initial-weight-steers
100
1500
220.0
1
1
kg
HORIZONTAL

SLIDER
7
115
144
148
set-X-size
set-X-size
2
100
10.0
2
1
hm
HORIZONTAL

SLIDER
7
154
143
187
set-Y-size
set-Y-size
2
100
10.0
2
1
hm
HORIZONTAL

TEXTBOX
11
96
102
116
GRAZING AREA
12
0.0
1

SLIDER
5127
209
5225
242
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
5228
209
5349
242
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
816
1215
1349
1388
Stocking rate
Days
AU/ha
0.0
92.0
0.0
0.0
true
true
"" ""
PENS
"SR total area" 1.0 0 -16777216 true "" "plot stocking-rate"
"SR paddock area (only for RG)" 1.0 0 -7500403 true "" "plot paddock-SR"

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
setup_seed\nset balance 1000
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
5103
855
5405
900
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
1903
855
2077
900
Total DM per ha (kg/ha)
;(DM-cm-ha * mean [grass-height] of patches) / DM-available-for-cattle\n(dmgr) / count patches
7
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
50.0
1
1
years
HORIZONTAL

CHOOSER
210
208
361
253
soil-quality-distribution
soil-quality-distribution
"homogeneus" "uniform" "normal" "exponential_low" "exponential_high"
0

PLOT
5087
500
5422
714
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
5088
716
5235
761
min grass-height of patches
min [grass-height] of patches
17
1
11

MONITOR
5254
717
5425
762
max grass-height of patches
max [grass-height] of patches
17
1
11

CHOOSER
9
671
127
716
spatial-management
spatial-management
"free grazing" "rotational grazing"
1

CHOOSER
10
722
128
767
starting-paddock
starting-paddock
"paddock a" "paddock b" "paddock c" "paddock d"
0

MONITOR
537
61
656
106
Paddock area (ha)
paddock-size
3
1
11

SLIDER
209
170
361
203
set-DM-cm-ha
set-DM-cm-ha
1
180
180.0
1
1
kg/cm/ha
HORIZONTAL

SLIDER
11
1227
202
1260
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
1262
202
1295
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
5
416
195
449
winter-length
winter-length
2
368 - spring-length - summer-length - fall-length
92.0
1
1
days
HORIZONTAL

SLIDER
209
414
389
447
spring-length
spring-length
2
368 - winter-length - summer-length - fall-length
92.0
1
1
days
HORIZONTAL

SLIDER
6
530
196
563
summer-length
summer-length
2
368 - spring-length - winter-length - fall-length
92.0
1
1
days
HORIZONTAL

SLIDER
206
530
389
563
fall-length
fall-length
2
368 - spring-length - winter-length - summer-length
92.0
1
1
days
HORIZONTAL

SLIDER
5
449
195
482
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
209
447
389
480
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
6
563
196
596
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
206
563
389
596
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
14
304
164
322
SEASONS AND CLIMATE
12
0.0
1

TEXTBOX
211
96
409
126
INITIAL GRASS HEIGHT \nAND SOIL QUALITY
12
0.0
1

PLOT
833
64
1127
200
climacoef
NIL
NIL
0.0
92.0
0.0
1.5
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot climacoef"

TEXTBOX
13
636
178
666
RESOURCE MANAGEMENT STRATEGIES
12
0.0
1

TEXTBOX
10
823
186
853
INITIAL LIVESTOCK NUMBERS\nAND WEIGHT
12
0.0
1

CHOOSER
210
333
391
378
climacoef-distribution
climacoef-distribution
"homogeneus" "uniform" "normal" "exponential_low" "exponential_high" "historic-climacoef" "direct-climacoef-control"
6

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
1328
221
1511
266
Ordinary sales (OS) income (USD)
ordinary-sales-income
3
1
11

PLOT
1329
269
1676
419
Daily income
Days
USD
0.0
92.0
0.0
10.0
true
true
"" ""
PENS
"OS income" 1.0 0 -13840069 true "" "plot ordinary-sales-income"
"ES income" 1.0 0 -2674135 true "" "plot extraordinary-sales-income"

PLOT
1690
101
2053
228
Daily balance
Days
USD
0.0
92.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot balance"

SLIDER
235
784
437
817
keep-MAX-n-breeding-cows
keep-MAX-n-breeding-cows
0
500
100.0
1
1
NIL
HORIZONTAL

SLIDER
237
743
427
776
age-sell-old-cow/bull
age-sell-old-cow/bull
2
15
10.0
1
1
years
HORIZONTAL

CHOOSER
237
682
389
727
farmer-profile
farmer-profile
"none" "traditional" "market" "market-fsb" "environmental"
4

TEXTBOX
238
643
388
673
LIVESTOCK MANAGEMENT STRATEGIES
12
0.0
1

SLIDER
210
295
392
328
set-direct-climacoef-control
set-direct-climacoef-control
0.1
1.5
1.0
0.01
1
NIL
HORIZONTAL

MONITOR
2063
49
2241
94
meat production (kg/ha)
sum [live-weight] of cows / count patches
3
1
11

PLOT
2064
101
2429
251
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
4542
1499
4731
1532
early-weaning-threshold
early-weaning-threshold
180
800
230.0
1
1
kg
HORIZONTAL

SLIDER
4933
210
5116
243
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
406
590
592
635
ordinary-sale-of-cows-with
ordinary-sale-of-cows-with
"highest live weight" "lowest live weight"
1

MONITOR
1330
49
1509
94
Accumulated balance (USD)
accumulated-balance
17
1
11

PLOT
1330
95
1674
215
Accumulated balance
Days
USD
0.0
92.0
0.0
10.0
true
false
"" ""
PENS
"Balance" 1.0 0 -16777216 true "" "plot accumulated-balance"

MONITOR
1513
221
1673
266
Extraordinary sales (ES) income (USD)
extraordinary-sales-income
3
1
11

CHOOSER
598
590
782
635
extraordinary-sale-of-cows-with
extraordinary-sale-of-cows-with
"highest live weight" "lowest live weight"
1

SLIDER
511
984
733
1017
market-farmer-ES-min-weight
market-farmer-ES-min-weight
0
1000
225.0
1
1
kg
HORIZONTAL

SLIDER
234
823
438
856
keep-MIN-n-breeding-cows
keep-MIN-n-breeding-cows
0
500
10.0
1
1
NIL
HORIZONTAL

SLIDER
234
985
487
1018
RG-market-farmer-live-weight-threshold
RG-market-farmer-live-weight-threshold
180
300
245.0
1
1
kg
HORIZONTAL

MONITOR
538
109
657
154
SR paddock (AU/ha)
paddock-SR
4
1
11

SLIDER
234
951
423
984
RG-days-in-paddock
RG-days-in-paddock
0
368
31.0
1
1
days
HORIZONTAL

MONITOR
1688
424
1907
469
Total daily kg-supplement-DM (kg)
sum [kg-supplement-DM] of cows + sum [kg-supplement-DM-breeding] of cows
7
1
11

MONITOR
1690
227
1859
272
Daily supplement cost (USD)
supplement-cost
7
1
11

SLIDER
517
655
711
688
feed-sup-conversion-ratio
feed-sup-conversion-ratio
1
8
7.0
1
1
NIL
HORIZONTAL

SLIDER
4749
1389
5004
1422
cow-min-weight-for-feed-sup
cow-min-weight-for-feed-sup
0
350
240.0
1
1
kg
HORIZONTAL

SLIDER
490
729
746
762
cow-with-calf-min-weight-for-feed-sup
cow-with-calf-min-weight-for-feed-sup
0
400
240.0
1
1
kg
HORIZONTAL

SLIDER
491
801
748
834
heifer/steer-min-weight-for-feed-sup
heifer/steer-min-weight-for-feed-sup
0
400
220.0
1
1
kg
HORIZONTAL

SLIDER
491
837
748
870
weaned-calf-min-weight-for-feed-sup
weaned-calf-min-weight-for-feed-sup
0
200
150.0
1
1
kg
HORIZONTAL

PLOT
1689
274
2055
423
Daily costs
Days
USD
0.0
92.0
0.0
4.0
true
true
"" ""
PENS
"Supplements" 1.0 0 -2674135 true "" "plot supplement-cost   "
"Other" 1.0 0 -13791810 true "" "plot other-cost"

BUTTON
1137
53
1257
87
free 1000 USD
set balance 1000
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
403
12
473
57
Climacoef
climacoef
17
1
11

MONITOR
659
61
816
106
Total number of cattle
count cows
3
1
11

TEXTBOX
819
696
1130
740
LIVESTOCK RELATED OUTPUTS
18
34.0
1

TEXTBOX
1329
10
1633
54
ECONOMIC RELATED OUTPUTS
18
0.0
1

TEXTBOX
1416
465
1714
500
RESOURCE RELATED OUTPUTS
18
64.0
1

MONITOR
1690
50
1828
95
Daily balance (USD)
balance
17
1
11

SLIDER
5125
297
5328
330
set-other-monthly-costs
set-other-monthly-costs
0
10000
0.0
50
1
USD
HORIZONTAL

MONITOR
5333
289
5475
334
Daily other costs (USD)
other-cost
17
1
11

MONITOR
1845
49
1994
94
Accumulated cost (USD)
accumulated-cost
17
1
11

TEXTBOX
5082
333
5440
482
Slider to simulate other costs related to the livestock system (maintenance, veterinary, vehicles, gas, etc.) and/or the farmer's personal (non-work related) costs (such as family costs, etc.).\n\nRight now, the only cost associated with the livestock system is feed supplementing.
13
0.0
1

MONITOR
4750
1210
4863
1255
NIL
supplement-effort
17
1
11

SLIDER
851
566
1047
599
sales-effort-time
sales-effort-time
1
200
5.0
1
1
min/animal
HORIZONTAL

MONITOR
4750
1254
4924
1299
SUPP-EFFORT-SEASON
accumulated-supplement-effort-season
17
1
11

MONITOR
4750
1299
4924
1344
SUPP-EFFORT-YEAR
accumulated-supplement-effort-year
17
1
11

MONITOR
4538
1213
4634
1258
NIL
weaning-effort
17
1
11

MONITOR
4538
1256
4707
1301
WEAN-EFFORT-SEASON
accumulated-weaning-effort-season
17
1
11

MONITOR
4538
1301
4707
1346
WEAN-EFFORT-YEAR
accumulated-weaning-effort-year
17
1
11

MONITOR
1068
210
1164
255
Total effort (h)
total-effort / 60
3
1
11

MONITOR
1068
253
1238
298
TOTAL-EFFORT-SEASON (h)
total-effort-history-season / 60
3
1
11

MONITOR
1068
296
1222
341
TOTAL-EFFORT-YEAR (h)
total-effort-history-year / 60
3
1
11

MONITOR
4599
988
4701
1033
NIL
OS-males-effort
17
1
11

MONITOR
4574
944
4676
989
n steers
count cows with [steer?]
17
1
11

MONITOR
4599
1032
4756
1077
OS-MALES-EFFORT-SEASON
acummulated-OS-males-effort-season
17
1
11

MONITOR
4599
1075
4756
1120
OS-MALES-EFFORT-YEAR
OS-males-effort-historyXticks-year
17
1
11

MONITOR
4431
988
4544
1033
NIL
OS-old-cow-effort
17
1
11

MONITOR
4431
1031
4599
1076
OS-OLD-COW-EFFORT-SEASON
acummulated-OS-old-cow-effort-season
17
1
11

MONITOR
4431
1075
4599
1120
OS-OLD-COW-EFFORT-YEAR
acummulated-OS-old-cow-effort-year
17
1
11

MONITOR
4431
944
4502
989
n old cow
count cows with [cow? and age / 368 > age-sell-old-cow/bull]
17
1
11

MONITOR
4401
898
4458
943
n cow
count cows with [cow?]
17
1
11

MONITOR
4285
988
4404
1033
NIL
OS-females-effort
17
1
11

MONITOR
4285
1031
4432
1076
OS-HEIFER-COW-SEASON
acummulated-OS-females-effort-season
17
1
11

MONITOR
4285
1075
4432
1120
OS-HEIFER-COW-YEAR
acummulated-OS-females-effort-year
17
1
11

MONITOR
4285
943
4362
988
n heifer cow
count cows with [cow? or heifer?]
17
1
11

MONITOR
4345
898
4402
943
n heifer
count cows with [heifer?]
17
1
11

MONITOR
4132
988
4228
1033
NIL
OS-total-effort
17
1
11

MONITOR
4132
1031
4287
1076
OS-TOTAL-EFFORT-SEASON
OS-total-effort-history-season
17
1
11

MONITOR
4132
1075
4287
1120
OS-TOTAL-EFFORT-YEAR
OS-total-effort-history-year
17
1
11

MONITOR
4675
760
4775
805
NIL
ES-males-effort
17
1
11

MONITOR
4675
803
4827
848
ES-MALES-EFFORT-SEASON
acummulated-ES-males-effort-season
17
1
11

MONITOR
4675
847
4827
892
ES-MALES-EFFORT-YEAR
acummulated-ES-males-effort-year
17
1
11

MONITOR
4675
716
4733
761
n steers
count cows with [steer?]
17
1
11

MONITOR
4505
759
4618
804
NIL
ES-old-cow-effort
17
1
11

MONITOR
4505
803
4675
848
ES-OLD-COW-EFFORT-SEASON
acummulated-ES-old-cow-effort-season
17
1
11

MONITOR
4505
847
4675
892
ES-OLD-COW-EFFORT-YEAR
acummulated-ES-old-cow-effort-year
17
1
11

MONITOR
4505
715
4570
760
n old cow
count cows with [cow? and age / 368 > age-sell-old-cow/bull]
17
1
11

MONITOR
4474
671
4527
716
n cow
count cows with [cow?]
17
1
11

MONITOR
4362
760
4482
805
NIL
ES-females-effort
17
1
11

MONITOR
4362
803
4506
848
ES-HEIFER-COW-SEASON
acummulated-ES-females-effort-season
17
1
11

MONITOR
4362
847
4506
892
ES-HEIFER-COW-YEAR
acummulated-ES-females-effort-year
17
1
11

MONITOR
4362
716
4443
761
n heifer cow
count cows with [cow? or heifer?]
17
1
11

MONITOR
4421
671
4475
716
n heifer
count cows with [heifer?]
17
1
11

MONITOR
4205
759
4299
804
NIL
ES-total-effort
17
1
11

MONITOR
4205
803
4363
848
ES-TOTAL-EFFORT-SEASON
ES-total-effort-history-season
17
1
11

MONITOR
4205
847
4363
892
ES-TOTAL-EFFORT-YEAR
ES-total-effort-history-year
17
1
11

MONITOR
4332
1221
4430
1266
NIL
breeding-effort
17
1
11

MONITOR
4333
1266
4493
1311
BREEDING-EFFORT-SEASON
acummulated-breeding-effort-season
17
1
11

MONITOR
4333
1311
4494
1356
BREEDING-EFFORT-YEAR
acummulated-breeding-effort-year
17
1
11

MONITOR
4130
1220
4233
1265
NIL
rotational-effort
17
1
11

MONITOR
4130
1264
4297
1309
ROTATIONAL-EFFORT-SEASON
acummulated-rotational-effort-season
17
1
11

MONITOR
4130
1308
4297
1353
ROTATIONAL-EFFORT-YEAR
acummulated-rotational-effort-year
17
1
11

PLOT
851
347
1234
504
total-effort (h)
Days
Effort (h)
0.0
92.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot total-effort / 60"

MONITOR
866
295
1060
340
Accumulated effort over time (h)
total-effort-history / 60
3
1
11

TEXTBOX
822
263
1071
296
EFFORT RELATED OUTPUTS
18
135.0
1

SLIDER
851
526
1047
559
rotational-effort-time
rotational-effort-time
1
200
30.0
1
1
min
HORIZONTAL

SLIDER
1055
526
1279
559
breeding-effort-time
breeding-effort-time
1
200
15.0
1
1
min
HORIZONTAL

SLIDER
852
607
1050
640
weaning-effort-time
weaning-effort-time
1
200
5.0
1
1
min/calf
HORIZONTAL

SLIDER
1055
565
1279
598
supplement-effort-time
supplement-effort-time
1
200
2.0
1
1
min/animal
HORIZONTAL

SLIDER
527
926
711
959
min-weight-for-breeding
min-weight-for-breeding
0
460
380.0
1
1
NIL
HORIZONTAL

SLIDER
11
1020
201
1053
initial-weight-bulls
initial-weight-bulls
0
1000
260.0
1
1
kg
HORIZONTAL

SLIDER
490
763
747
796
bull-min-weight-for-feed-sup
bull-min-weight-for-feed-sup
0
400
240.0
1
1
kg
HORIZONTAL

SLIDER
10
944
158
977
bull:cow-ratio
bull:cow-ratio
0
100
30.0
1
1
cows
HORIZONTAL

MONITOR
10
976
158
1021
initial-num-bulls
;round ((count cows with [adult-cow?] + count cows with [heifer?]) / bull:female-ratio)\nround ((initial-num-cows + initial-num-heifers) / bull:cow-ratio)
17
1
11

MONITOR
4537
1354
4727
1399
NIL
count cows with [weaning-calf?]
17
1
11

MONITOR
4538
1404
4708
1449
NIL
count cows with [born-calf?]
17
1
11

MONITOR
4739
1501
4986
1546
NIL
mean [live-weight] of cows with [cow-with-calf?]
3
1
11

MONITOR
5011
1389
5239
1434
NIL
mean [live-weight] of cows with [cow?]
17
1
11

MONITOR
4755
942
4827
987
n old bull
count cows with [bull? and old?]
17
1
11

MONITOR
4675
944
4733
989
n bull
count cows with [bull?]
17
1
11

MONITOR
4755
986
4865
1031
NIL
OS-old-bull-effort
17
1
11

MONITOR
4755
1031
4923
1076
OS-OLD-BULL-EFFORT-SEASON
acummulated-OS-old-bull-effort-season
17
1
11

MONITOR
4755
1074
4923
1119
OS-OLD-BULL-EFFORT-YEAR
acummulated-OS-old-bull-effort-year
17
1
11

SLIDER
233
878
422
911
early-weaning-threshold
early-weaning-threshold
0
800
230.0
1
1
kg
HORIZONTAL

SLIDER
490
695
747
728
cow-min-weight-for-feed-sup
cow-min-weight-for-feed-sup
0
400
240.0
1
1
kg
HORIZONTAL

SLIDER
4783
297
4979
330
other-daily-effort-time
other-daily-effort-time
0
480
0.0
1
1
min
HORIZONTAL

MONITOR
4994
1211
5104
1256
NIL
other-daily-effort
17
1
11

MONITOR
4994
1255
5146
1300
OTHER-EFFORT-SEASON
acummulated-other-daily-effort-season
17
1
11

MONITOR
4993
1299
5129
1344
OTHER-EFFORT-YEAR
acummulated-other-daily-effort-year
17
1
11

MONITOR
660
108
816
153
Animal Units Equivalent (AU)
sum [animal-units] of cows
3
1
11

MONITOR
4195
452
4351
497
NIL
DDMC_SEASON
17
1
11

MONITOR
4195
496
4350
541
NIL
DDMC_YEAR
17
1
11

SLIDER
5
384
195
417
K-winter
K-winter
7.4
22.2
7.4
0.1
1
cm
HORIZONTAL

SLIDER
209
382
389
415
K-spring
K-spring
7.4
22.2
22.2
0.1
1
cm
HORIZONTAL

SLIDER
6
498
196
531
K-summer
K-summer
7.4
22.2
15.6
0.1
1
cm
HORIZONTAL

SLIDER
206
498
389
531
K-fall
K-fall
7.4
22.2
11.1
0.1
1
cm
HORIZONTAL

MONITOR
4195
407
4350
452
DDMC_MONTH
DDMC_SEASON / 3
17
1
11

MONITOR
4195
363
4421
408
NIL
sum [DDMC] of cows
3
1
11

PLOT
1414
494
1976
668
Carrying capacity vs Livestock population
Days
Animal Units (AU)
0.0
92.0
0.0
10.0
true
true
"" ""
PENS
"REAL Carrying capacity" 1.0 0 -2674135 true "" "plot carrying-capacity"
"EST. Carrying capacity (for Env. farmer)" 1.0 0 -5825686 true "" "plot estimated-carrying-capacity"
"Livestock population" 1.0 0 -13791810 true "" "plot sum [animal-units] of cows"

SLIDER
514
1074
739
1107
daily-DM-consumed-by-cattle
daily-DM-consumed-by-cattle
0.1
20
8.5
0.1
1
kg/head
HORIZONTAL

MONITOR
661
156
817
201
EST Carrying capacity (AU)
estimated-carrying-capacity
3
1
11

TEXTBOX
514
1045
738
1071
Parameter used by the environmental farmer to estimate the carrying capacity
11
0.0
1

MONITOR
486
156
657
201
REAL Carrying capacity (AU)
carrying-capacity
3
1
11

SLIDER
514
1106
739
1139
%-DM-available-for-cattle
%-DM-available-for-cattle
0
100
50.0
1
1
%
HORIZONTAL

MONITOR
1115
1080
1365
1125
Average ILWG (all age classes) (kg/animal/day)
mean [live-weight-gain] of cows + mean [live-weight-gain-feed] of cows + mean [live-weight-gain-feed-breeding] of cows
17
1
11

SLIDER
5127
247
5350
280
set-live-weight-gain-max
set-live-weight-gain-max
0
1.5
0.6
0.01
1
kg/day
HORIZONTAL

MONITOR
4948
160
5112
205
NIL
days-until-breeding-season
17
1
11

TEXTBOX
4767
340
5025
407
Slider to simulate the time dedicated to other activities related to the livestock system.
13
0.0
1

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
  <experiment name="OS_ES_LOW_LW" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3680"/>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MIN-n-cattle">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-min-weight-for-feed-sup">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weaned-calf-min-weight-for-feed-sup">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extraordinary-sale-of-cows-with">
      <value value="&quot;lowest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heifer/steer-min-weight-for-feed-sup">
      <value value="175"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="feed-sup-conversion-ratio">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-farmer-ES-min-weight">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-with-calf-min-weight-for-feed-sup">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-ES-SR">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;traditional&quot;"/>
      <value value="&quot;environmental&quot;"/>
      <value value="&quot;market&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RG-days-in-paddock">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-RG-SR-threshold">
      <value value="0.6"/>
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
    <enumeratedValueSet variable="ordinary-sale-of-cows-with">
      <value value="&quot;lowest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-other-monthly-costs">
      <value value="0"/>
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
    <enumeratedValueSet variable="market-farmer-RG-live-weight-threshold">
      <value value="255"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="50"/>
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
    <enumeratedValueSet variable="keep-MAX-n-cattle">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-direct-climacoef-control">
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
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MAX-n-steers">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;direct-climacoef-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="controlled-breeding-season">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="OS_ES_HIGH_LW" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3680"/>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MIN-n-cattle">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-min-weight-for-feed-sup">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weaned-calf-min-weight-for-feed-sup">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extraordinary-sale-of-cows-with">
      <value value="&quot;highest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heifer/steer-min-weight-for-feed-sup">
      <value value="175"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="feed-sup-conversion-ratio">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-farmer-ES-min-weight">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-with-calf-min-weight-for-feed-sup">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-ES-SR">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;traditional&quot;"/>
      <value value="&quot;environmental&quot;"/>
      <value value="&quot;market&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RG-days-in-paddock">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-RG-SR-threshold">
      <value value="0.6"/>
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
    <enumeratedValueSet variable="ordinary-sale-of-cows-with">
      <value value="&quot;highest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-other-monthly-costs">
      <value value="0"/>
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
    <enumeratedValueSet variable="market-farmer-RG-live-weight-threshold">
      <value value="255"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="50"/>
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
    <enumeratedValueSet variable="keep-MAX-n-cattle">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-direct-climacoef-control">
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
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MAX-n-steers">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;direct-climacoef-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="controlled-breeding-season">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="ES_LW vs HW" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="7360"/>
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
    <enumeratedValueSet variable="keep-MIN-n-cattle">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-min-weight-for-feed-sup">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weaned-calf-min-weight-for-feed-sup">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extraordinary-sale-of-cows-with">
      <value value="&quot;lowest live weight&quot;"/>
      <value value="&quot;highest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heifer/steer-min-weight-for-feed-sup">
      <value value="175"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="feed-sup-conversion-ratio">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-farmer-ES-min-weight">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-with-calf-min-weight-for-feed-sup">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;market&quot;"/>
      <value value="&quot;traditional&quot;"/>
      <value value="&quot;environmental&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-ES-SR">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RG-days-in-paddock">
      <value value="31"/>
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
    <enumeratedValueSet variable="env-farmer-RG-SR-threshold">
      <value value="0.6"/>
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
    <enumeratedValueSet variable="ordinary-sale-of-cows-with">
      <value value="&quot;lowest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-other-monthly-costs">
      <value value="0"/>
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
    <enumeratedValueSet variable="market-farmer-RG-live-weight-threshold">
      <value value="255"/>
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
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MAX-n-cattle">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-direct-climacoef-control">
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
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MAX-n-steers">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;direct-climacoef-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="controlled-breeding-season">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SR in different CC (0 a 0.8)" repetitions="25" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="9200"/>
    <metric>stocking-rate</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>count cows</metric>
    <enumeratedValueSet variable="initial-weight-bulls">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MAX-n-breeding-cows">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-min-weight-for-feed-sup">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-weight-for-breeding">
      <value value="420"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extraordinary-sale-of-cows-with">
      <value value="&quot;lowest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heifer/steer-min-weight-for-feed-sup">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-farmer-ES-min-weight">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-with-calf-min-weight-for-feed-sup">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
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
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-other-monthly-costs">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sales-effort-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bull-min-weight-for-feed-sup">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="set-direct-climacoef-control" first="0" step="0.01" last="0.8"/>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MIN-n-breeding-cows">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rotational-effort-time">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;direct-climacoef-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow/bull">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="controlled-breeding-season">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="other-daily-effort-time">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="supplement-effort-time">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weaned-calf-min-weight-for-feed-sup">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="feed-sup-conversion-ratio">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-ES-SR">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RG-days-in-paddock">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-RG-SR-threshold">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ordinary-sale-of-cows-with">
      <value value="&quot;lowest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="breeding-effort-time">
      <value value="15"/>
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
    <enumeratedValueSet variable="market-farmer-RG-live-weight-threshold">
      <value value="255"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weaning-effort-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bull:cow-ratio">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="supplement-cows-before-breeding-season?">
      <value value="&quot;No&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SR in different CC (0.8 a 1.5)" repetitions="25" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="9200"/>
    <metric>stocking-rate</metric>
    <metric>mean [live-weight] of cows</metric>
    <metric>count cows</metric>
    <enumeratedValueSet variable="initial-weight-bulls">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MAX-n-breeding-cows">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-min-weight-for-feed-sup">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-weight-for-breeding">
      <value value="420"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extraordinary-sale-of-cows-with">
      <value value="&quot;lowest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heifer/steer-min-weight-for-feed-sup">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-farmer-ES-min-weight">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-with-calf-min-weight-for-feed-sup">
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
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
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-other-monthly-costs">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sales-effort-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bull-min-weight-for-feed-sup">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="set-direct-climacoef-control" first="0.8" step="0.01" last="1.5"/>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MIN-n-breeding-cows">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rotational-effort-time">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;direct-climacoef-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow/bull">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="controlled-breeding-season">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="other-daily-effort-time">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="supplement-effort-time">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weaned-calf-min-weight-for-feed-sup">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="feed-sup-conversion-ratio">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-ES-SR">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RG-days-in-paddock">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="env-farmer-RG-SR-threshold">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ordinary-sale-of-cows-with">
      <value value="&quot;lowest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="breeding-effort-time">
      <value value="15"/>
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
    <enumeratedValueSet variable="market-farmer-RG-live-weight-threshold">
      <value value="255"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weaning-effort-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bull:cow-ratio">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="supplement-cows-before-breeding-season?">
      <value value="&quot;No&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="250"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="FINAL_experiment" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="9200"/>
    <metric>accumulated-balance</metric>
    <metric>grass-height-report</metric>
    <metric>mean [live-weight] of cows with [adult-cow?]</metric>
    <metric>count cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-bulls">
      <value value="260"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MAX-n-breeding-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-min-weight-for-feed-sup">
      <value value="240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-weight-for-breeding">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RG-market-farmer-live-weight-threshold">
      <value value="245"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extraordinary-sale-of-cows-with">
      <value value="&quot;lowest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heifer/steer-min-weight-for-feed-sup">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-farmer-ES-min-weight">
      <value value="225"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-with-calf-min-weight-for-feed-sup">
      <value value="240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="daily-DM-consumed-by-cattle">
      <value value="8.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-weaning-threshold">
      <value value="230"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="260"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-other-monthly-costs">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sales-effort-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="K-winter">
      <value value="7.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bull-min-weight-for-feed-sup">
      <value value="240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-direct-climacoef-control">
      <value value="1"/>
      <value value="0.27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MIN-n-breeding-cows">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rotational-effort-time">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;direct-climacoef-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow/bull">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="controlled-breeding-season">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="other-daily-effort-time">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="supplement-effort-time">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-DM-available-for-cattle">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weaned-calf-min-weight-for-feed-sup">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="feed-sup-conversion-ratio">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;traditional&quot;"/>
      <value value="&quot;market&quot;"/>
      <value value="&quot;environmental&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RG-days-in-paddock">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ordinary-sale-of-cows-with">
      <value value="&quot;lowest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="breeding-effort-time">
      <value value="15"/>
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
    <enumeratedValueSet variable="weaning-effort-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bull:cow-ratio">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="supplement-cows-before-breeding-season?">
      <value value="&quot;No&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="K-summer">
      <value value="15.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="K-spring">
      <value value="22.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-live-weight-gain-max">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="K-fall">
      <value value="11.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="FINAL_experiment_MARKET FSB_Yes" repetitions="200" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="9200"/>
    <metric>accumulated-balance</metric>
    <metric>grass-height-report</metric>
    <metric>mean [live-weight] of cows with [adult-cow?]</metric>
    <metric>count cows</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-bulls">
      <value value="260"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MAX-n-breeding-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-min-weight-for-feed-sup">
      <value value="240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-weight-for-breeding">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RG-market-farmer-live-weight-threshold">
      <value value="245"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extraordinary-sale-of-cows-with">
      <value value="&quot;lowest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heifer/steer-min-weight-for-feed-sup">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-farmer-ES-min-weight">
      <value value="225"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-with-calf-min-weight-for-feed-sup">
      <value value="240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="daily-DM-consumed-by-cattle">
      <value value="8.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-weaning-threshold">
      <value value="230"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="260"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-other-monthly-costs">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sales-effort-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="K-winter">
      <value value="7.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bull-min-weight-for-feed-sup">
      <value value="240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-direct-climacoef-control">
      <value value="1"/>
      <value value="0.27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MIN-n-breeding-cows">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rotational-effort-time">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;direct-climacoef-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow/bull">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="controlled-breeding-season">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="other-daily-effort-time">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="supplement-effort-time">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-DM-available-for-cattle">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weaned-calf-min-weight-for-feed-sup">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="feed-sup-conversion-ratio">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;market&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RG-days-in-paddock">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ordinary-sale-of-cows-with">
      <value value="&quot;lowest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="breeding-effort-time">
      <value value="15"/>
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
    <enumeratedValueSet variable="weaning-effort-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bull:cow-ratio">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="supplement-cows-before-breeding-season?">
      <value value="&quot;Yes&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="K-summer">
      <value value="15.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="K-spring">
      <value value="22.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-live-weight-gain-max">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="K-fall">
      <value value="11.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="How-many-runs" repetitions="400" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="18400"/>
    <metric>count turtles</metric>
    <metric>simulation-time / 368</metric>
    <enumeratedValueSet variable="initial-num-heifers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MAX-n-breeding-cows">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-bulls">
      <value value="260"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-weaned-calves">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-min-weight-for-feed-sup">
      <value value="240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RG-market-farmer-live-weight-threshold">
      <value value="245"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-1-AU">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-weight-for-breeding">
      <value value="380"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extraordinary-sale-of-cows-with">
      <value value="&quot;lowest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heifer/steer-min-weight-for-feed-sup">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="market-farmer-ES-min-weight">
      <value value="225"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cow-with-calf-min-weight-for-feed-sup">
      <value value="240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="daily-DM-consumed-by-cattle">
      <value value="8.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-steers">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-steers">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-weaning-threshold">
      <value value="230"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-cows">
      <value value="260"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-other-monthly-costs">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-Y-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sales-effort-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="K-winter">
      <value value="7.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bull-min-weight-for-feed-sup">
      <value value="240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fall-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-direct-climacoef-control">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-DM-cm-ha">
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-grass-height">
      <value value="7.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="keep-MIN-n-breeding-cows">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rotational-effort-time">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STOP-SIMULATION-AT">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climacoef-distribution">
      <value value="&quot;direct-climacoef-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-sell-old-cow/bull">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="summer-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="controlled-breeding-season">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="other-daily-effort-time">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="supplement-effort-time">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-X-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-DM-available-for-cattle">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weaned-calf-min-weight-for-feed-sup">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-climacoef-homogeneus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-management">
      <value value="&quot;free grazing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="feed-sup-conversion-ratio">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-profile">
      <value value="&quot;none&quot;"/>
      <value value="&quot;traditional&quot;"/>
      <value value="&quot;market&quot;"/>
      <value value="&quot;environmental&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RG-days-in-paddock">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-season">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ordinary-sale-of-cows-with">
      <value value="&quot;lowest live weight&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="breeding-effort-time">
      <value value="15"/>
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
    <enumeratedValueSet variable="initial-num-weaned-calves">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weaning-effort-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-cows">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="winter-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-MW-1-AU">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bull:cow-ratio">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="K-summer">
      <value value="15.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spring-length">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="K-spring">
      <value value="22.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-weight-heifers">
      <value value="220"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-live-weight-gain-max">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="K-fall">
      <value value="11.1"/>
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
