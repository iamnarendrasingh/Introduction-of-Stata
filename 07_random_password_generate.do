clear
set obs 1000
local c2use ABCDEFGHIJKLMNPQRSTUVWXYZ

gen random_string = substr("`c2use'", runiformint(1,length("`c2use'")),1) + ///
    string(runiformint(0,9)) + ///
    char(runiformint(65,90)) + ///
    char(runiformint(65,90)) + ///
    string(runiformint(0,9)) + ///
    char(runiformint(65,90))

bysort random_string: keep if _n == 1
gen mixitup = runiform()
sort mixitup
keep in 1/600
drop mixitup
