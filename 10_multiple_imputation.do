*dataset import 
clear

use https://stats.idre.ucla.edu/wp-content/uploads/2017/05/hsb2_mar.dta, clear

sum

regress read write i.female math ib3.prog
