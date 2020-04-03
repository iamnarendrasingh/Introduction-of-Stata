***CODE FILE FOR UCLA IDRE STATA DATA MANAGEMENT SEMINAR***

***PRELIMINARY ADVICE***

*help files
help describe

*comments start with * (or can be enclosed in /* and */ )
/* a
   multi-line
   comment
*/
*a comment won't be run by Stata

*break up command across multiple lines
describe ///
  age using ///
  http://stats.idre.ucla.edu/stat/data/patient_pt2_stata_dm.dta
  
*describe can be abbreviated to d
d
  
***INPUTTING DATA INTO STATA***

*any data in memory must be cleared before loading new data
clear

*Also try the File menu to import files!
*import excel
import excel "http://www.ats.ucla.edu/stat/data/hsb2.xls", firstrow clear

*import csv
import delimited "http://www.ats.ucla.edu/stat/data/hsb2.csv", clear

*Getting data in
*From keyboard with input
input age weight
8 11
9 12
8 10
9 11
10 15
end

*get in strings by putting strxxx before variable name
input str10 words
"These"
"are"
"words."
end


*Stata data files have .dta extension, which can be omitted for use
use "http://stats.idre.ucla.edu/stat/data/hsb2", clear

***LOAD IN FIRST DATASET***

use http://stats.idre.ucla.edu/stat/data/patient_pt1_stata_dm, clear

***VIEWING THE DATASET***

*print variables to screen
list hospital-pain

*open the browser
browse


***CHARACTERIZING VARIABLES***

*describe how variables are stored
describe

*describe the values of a variable
codebook


***SELECTING OBSERVATIONS***
*in operator to select range of obs
list age in 1/10

*can use negative for distance from end, and L or l for end
list age in -10/L

*if to select by condition
li age if sex == "female" & pain > 8, clean


***APPENDING FILES***

*files to be appended follow using
append using http://stats.idre.ucla.edu/stat/data/patient_pt2_stata_dm

*check appended datasets
describe

*variables not in both datasets will have missing where absent
tab nmorphine, miss


***MERGING FILES***

*look at doctor file (using file, or file to be merged)
describe using http://stats.idre.ucla.edu/stat/data/doctor_stata_dm

*check if docid is repeated -- it is
tab docid

*merge the files
merge m:1 docid using http://stats.idre.ucla.edu/stat/data/doctor_stata_dm

*drop unmatched doctor
drop if _merge == 2

***DUPLICATES START***
*duplicates suite
help duplicates

*count how many duplicated observations there are
duplicates report 

*the keyword _all
duplicates report _all

*list observations duplicated on hospid
duplicates report hospid 


*maybe we can check on them later
duplicates tag, gen(dup)
tab dup

*drop all but the first copy of each observation
duplicates drop 



***MISSING VALUES***

**all nonmissing numbers < . < .a < .b < ... < .z

*codebook reports missing
codebook

*summarize to detect missing data codes
summarize

*boxplots to detect missing data codes
graph box co2 lungcapacity test1 test2


*checking categorical variables
tab smokinghx, miss
tab familyhx, miss


*change -99 codes to missing
mvdecode _all, mv(-99)

*mvdecode does not work for string variables -- this doesn't work
mvdecode _all, mv("-99")

*use replace to change user missing to Stata missing for strings
replace familyhx = "" if familyhx == "-99"
replace smokinghx = "" if smokinghx == "-99"

*missing for strings is empty string
tab familyhx, miss
tab smokinghx, miss

*now use a special missing value .a to mean refused to answer
mvdecode lungcapacity co2, mv(-98=.a)

*seting any out of range ages to missing value .b to mean data error
summ age
replace age = .b if age > 120 | age < 18

*count missing values
misstable summarize lungcapacity test1 test2 

*profile missing data patterns
misstable patterns 


***CREATING and TRANSFORMING VARIABLES***
*generate an average and check missing
gen average = (test1 + test2)/2
misstable patterns average test1 test2
*be careful when using logical comparisons with missing values
*this is wrong
gen above50_wrong = 0
replace above50_wrong = 1 if age > 50
misstable summarize age above50_wrong
*correct way to handle if missing
gen above50 = age > 50
replace above50 = age if age >= .
misstable summarize age above50


*useful functions with generate
help functions
*functions
*running sum
gen marsum=sum(married)
*random uniform
gen random=runiform()
list married marsum random in 1/10


**egen**
*egen functions
help egen

*sum across variables
egen total = rowtotal(test1 test2)
*average across variables
egen mean = rowmean(test1 test2)
*notice that mean only missing if both test1 and test2 missing
misstable patterns test1 test2 average mean total

*count number of missing values across variables
egen nummiss = rowmiss(lungcapacity test1 test2 familyhx smokinghx)
li lungcapacity test1 test2 familyhx smokinghx nummiss in 1/10

*cut continuous variable into categorical variable
egen bmi_cat = cut(bmi), at(0, 15, 16, 18.5, 25, 30, 35, 40, 500) label
tab bmi_cat, miss
tab bmi_cat, nolabel

*cross grouping variables
egen family_smoking = group(familyhx smokinghx), label
tab family_smoking, miss

***RECODING VARIABLES***

*recoding variables
*recode -- consolidate some categories together
tab bmi_cat, nolabel
recode bmi_cat (0 1 2=3) (6 7 = 5) 
tab bmi_cat, nolabel
*labels change too!
tab bmi_cat


***RENAME

*rename 
rename test1 il6
rename test2 crp

*rename group
help rename group
*apply prefix "doc" to experience and school
rename (experience school) d_=
desc d_*
*replace doc prefix with d_
rename d_* doc_*
desc doc_*

**STRINGS
*string variables
tab sex, miss
replace sex = "" if sex == "12.2"
tab sex, miss

*trim variables
tab hospital
replace hospital = strtrim(hospital)
tab hospital

*extract doctor id
tab docid 
gen doc_id = substr(docid, 3, 3)
tab doc_id 

*remake the old docid from parts (and string function)

gen newdocid = string(hospid) + "-" + doc_id
li newdocid hospid doc_id in 1/10

*regular expressions 
*use regexm to match and regexs to extract capture group
gen regxdocid = regexs(1) if regexm(docid, "[0-9]-([0-9]+)")
list docid regxdocid in 1/10

*encoding string categorical variables into numeric variables with labels
encode cancerstage, gen(stage)
tab cancerstage stage
desc stage
tab cancerstage stage, nolab

*destring number variables stored as strings
tab wbc
replace wbc = "" if wbc == "not assessed"
destring wbc, replace
describe wbc

*****LABELS*****

*variable labels
label var il6 "Concentration of interleukin 6"
hist il6

*value labels
*see existing labels
label list

*create labels
label define other_miss .a "refused" .b "error"

*labeling turns a variable blue
label values lungcapacity co2 age other_miss
tab lungcapacity, miss


***BY-GROUP PROCESSING***
*usually need to sort first
sort docid

**stats by group (doctor)
by docid: egen mean_age = mean(age)
by docid: egen max_age = max(age)
by docid: egen sd_age = sd(age)
li docid age mean_age max_age sd_age in 1/10

**counting within group
*first generate a 0/1 variable for female
gen female = sex == "female"
replace female = . if sex == ""
*then create within-group running sum of females
by docid: gen num_female = sum(female)
li docid sex female num_female in 1/10
*replace all values of num_female, with final value from its group,
*  its group's sum
*_N is number of last observation (within group when used with by)
by docid: replace num_female = num_female[_N] 
li docid sex female num_female in 1/10


**lagging within group
*sort by docid and time first
sort docid dis_date
*_n is number of current observation (within group when used with by)
*lag dis_date by setting lag_date to previous dis_date (within docid)
by docid: gen lag_date = dis_date[_n-1]
*format number to appear as date
format lag_date %td
*create a time lag variable
gen time_lag = dis_date - lag_date
li docid dis_date lag_date time_lag in 1/10


***MACROS START***
*globals
global greeting Hello world!
*this becomes display "Hello world!"
display "$greeting"
*this becomes display Hello world! and doesn't work
display $greeting

*use macros to group variables together
global demographics age married female
summ $demographics

*local macros are deleted after code is run if declared in do-file
local outcomes tumorsize pain lungcapacity
summ `outcomes'

*use = to set local equal to expression
*expression is evaluated and result stored
local add_us = 2 + 3
display "sum = `add_us'"
*compare to without =
local print_us 2 + 3
display "sum = `print_us'"


***LOOPING***

*forvalues loops over numbers
forvalues i = 1/5 {
display "Hello world!" 
}
*the loop control variable is a local macro
*let's access its contents
forvalues i = 1/5 {
display "i = `i'" 
}

*loop over variables with numbered names
forvalues i = 50(10)70 {
gen age`i' = age > `i'
replace age`i' = age if missing(age)
label values age`i' other_miss
tab age`i', miss
}

*foreach loops over generic list of items
*looping across list of variables
*create standardized versions of variables
foreach var of varlist wbc rbc il6 crp {
egen std_`var' = std(`var')
}
summ std_*


*we can also loop across elements of locals and globals
foreach var of global demographics {
tabstat `var', by(stage)
}


*use the keyword in to loop across a generic list
gen fixed_docid = docid
foreach id in "1-11" "1-21" "1-57" {
replace fixed_docid = docid + "0" if docid == "`id'"
list fixed_docid docid if docid == "`id'"
}
