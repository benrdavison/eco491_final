*cd "C:/Users/ben/Dropbox/courses/eco491/eco491_final/ws"
cd "/Users/user/Dropbox (Personal)/courses/eco491/eco491_final/ws"

log using "project.txt", text replace

clear
use "data/feb21_transit.dta"

gen trips_per_person = unlinked_trips / sa_pop
gen log_trips_per_person = log(trips_per_person)
gen log_average_fare = log(average_fare)
replace log_average_fare = 0 if missing(log_average_fare)

replace mode = "MB" if mode == "CB"
replace mode = "MB" if mode == "RB"
replace mode = "LR" if mode == "SR"
replace mode = "LR" if mode == "YR"
replace mode = "LR" if mode == "CR"
replace mode = "LR" if mode == "HR"
replace mode = "LR" if mode =="TR"
replace mode = "MB" if mode == "TB"
replace mode = "LR" if mode == "MG"

drop if mode == "PB"
drop if mode == "AR"
drop if mode == "CC"
drop if mode == "IP"
drop if mode == "FB"
drop if mode == "VP"

drop if tos == "TN"
drop if tos == "TX"

drop if unlinked_trips < 100
drop if unlinked_trips < 1000
drop if average_fare > 50
drop if trips_per_person > 100

outreg2 using "summaries.doc", replace sum(log)

hist trips_per_person, kdensity
graph export "trips_per_person_dist.png", as(png) name("Graph") replace

hist average_fare, kdensity
graph export "average_fare_dist.png", as(png) name("Graph") replace

twoway scatter log_trips_per_person log_average || lfit log_trips_per_person log_average ||, by(mode, total row(1)) ytitle("log_trips_per_person") leg(off)
graph export "fits_by_mode.png", as(png) name("Graph") replace

twoway scatter log_trips_per_person log_average || lfit log_trips_per_person log_average ||, by(tos, total row(1)) ytitle("log_trips_per_person") leg(off)
graph export "fits_by_tos.png", as(png) name("Graph") replace

bysort mode: outreg2 using "bysort_sum_mode.doc", replace sum(log) keep (trips_per_person log_trips_per_person average_fare log_average_fare) eqkeep(N mean)
bysort tos: outreg2 using "bysort_sum_tos.doc", replace sum(log) keep (trips_per_person log_trips_per_person average_fare log_average_fare) eqkeep(N mean)

reg trips_per_person average_fare, robust
outreg2 using "trips_fares.doc", replace ctitle("trips_per_person")

reg log_trips_per_person log_average_fare, robust
outreg2 using "trips_fares.doc", append ctitle("log_trips_per_person")
predict yhat
scatter log_trips_per_person log_average_fare || line yhat log_average_fare, ytitle("log_trips_per_person") leg(off)
graph export "ltrips_lwage_scatter.png", as(png) name("Graph") replace

reg log_trips_per_person log_average_fare if tos=="PT", robust
outreg2 using "ltrip_lfare_tos.doc", replace ctitle("PT")
reg log_trips_per_person log_average_fare if tos=="DO", robust
outreg2 using "ltrip_lfare_tos.doc", append ctitle("DO")

reg log_trips_per_person log_average_fare if mode=="LR", robust
outreg2 using "ltrip_lfare_mode.doc", replace ctitle("LR")
reg log_trips_per_person log_average_fare if mode=="MB", robust
outreg2 using "ltrip_lfare_mode.doc", append ctitle("MB")
reg log_trips_per_person log_average_fare if mode=="DR", robust
outreg2 using "ltrip_lfare_mode.doc", append ctitle("DR")


log close


