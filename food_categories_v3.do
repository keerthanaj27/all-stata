* This file: creates food categories by income and mpce
* author: Keerthana J 
* Last update: April 16th 

* set the working directory 
  cd "C:\Users\kjagadeesh\Dropbox\hungry cities survey\year1"

* import the food security
  use "data\hcp04082017_merged.dta", clear
   
    decode surveysectionAQ2_HDDS1, gen(surveysectionAQ2_HDDS1_d)
decode surveysectionAQ2_HDDS2, gen(surveysectionAQ2_HDDS2_d)
decode surveysectionAQ2_HDDS3, gen(surveysectionAQ2_HDDS3_d)
decode surveysectionAQ2_HDDS4, gen(surveysectionAQ2_HDDS4_d)
decode surveysectionAQ2_HDDS5, gen(surveysectionAQ2_HDDS5_d)
decode surveysectionAQ2_HDDS6, gen(surveysectionAQ2_HDDS6_d)
decode surveysectionAQ2_HDDS7, gen(surveysectionAQ2_HDDS7_d)
decode surveysectionAQ2_HDDS8, gen(surveysectionAQ2_HDDS8_d)
decode surveysectionAQ2_HDDS9, gen(surveysectionAQ2_HDDS9_d)
decode surveysectionAQ2_HDDS10, gen(surveysectionAQ2_HDDS10_d)
decode surveysectionAQ2_HDDS11, gen(surveysectionAQ2_HDDS11_d)
decode surveysectionAQ2_HDDS12, gen(surveysectionAQ2_HDDS12_d)
  
  * tab by HFIAP
   decode HFIAP, gen(HFIAP_d)
  
   gen hfiap_new = 1 if HFIAP_d == "Food Secure"
   replace hfiap_new = 2 if HFIAP_d == "Mildly Food Insecure" | HFIAP_d == "Moderately Food Insecure"
   replace hfiap_new = 3 if HFIAP_d == "Severely Food Insecure"
   tab hfiap_new, m
   
   * mpce   
  foreach x of varlist surveysectionDQ16b1_food_and_gro surveysectionDQ16b2_housing_rent surveysectionDQ16b3_clothing surveysectionDQ16b4_transportati surveysectionDQ16b5_telecommunic  surveysectionDQ16b6_furniture_to  surveysectionDQ16b7_medical_care  surveysectionDQ16b8_education  surveysectionDQ16b9_entertainmen  surveysectionDQ16b10_insurance  surveysectionDQ16b11_debt_repaym  surveysectionDQ16b12_donations_g  surveysectionDQ16b13_publically_  surveysectionDQ16b14_informally_ surveysectionDQ16b15_fuel surveysectionDQ16b16_cash_remitt surveysectionDQ16b17_savings surveysectionDQ16b18_other_expen{
  replace `x' = 0 if(`x' == .) 
  replace `x' = 0 if(`x' == 97)
  }
  * generate consumption exp at houshold level 
  generate consumpt = surveysectionDQ16b1_food_and_gro +  surveysectionDQ16b2_housing_rent + surveysectionDQ16b3_clothing  + surveysectionDQ16b4_transportati +  surveysectionDQ16b5_telecommunic + surveysectionDQ16b6_furniture_to + surveysectionDQ16b7_medical_care + surveysectionDQ16b8_education + surveysectionDQ16b9_entertainmen + surveysectionDQ16b10_insurance + surveysectionDQ16b11_debt_repaym + surveysectionDQ16b12_donations_g +  surveysectionDQ16b13_publically_ + surveysectionDQ16b14_informally_ + surveysectionDQ16b15_fuel + surveysectionDQ16b16_cash_remitt + surveysectionDQ16b17_savings + surveysectionDQ16b18_other_expen
  * gen monthly per capita consumption expenditure
  generate mpce = consumpt /  surveysectionCQ12ahousehold_numb

  * drop  extreme values & 0s
  replace consumpt = . if consumpt == 193498
  * drop zeros 
  replace mpce =. if mpce == 0
  replace consumpt =. if consumpt == 0
  * drop mpce < 100
  replace mpce =. if mpce < 100
  
   * tab all of it 
   tabstat mpce, stat(n mean cv q)
   * let's create quantiles for income
   xtile mpce_quart = mpce, nq(5)
  
   tab mpce_quart, m  
   tab mpce_quart, sum(mpce)
   
   * sum to get the min and max of each group
   sum mpce if mpce_quart == 1,d
   sum mpce if mpce_quart == 2,d
   sum mpce if mpce_quart == 3,d
   sum mpce if mpce_quart == 4,d 
   sum mpce if mpce_quart == 5,d

   * create mpce quintiles
   gen mpce_quintiles = 1 if mpce <= 2225 & mpce!=.
   replace mpce_quintiles = 2 if mpce > 2225 & mpce <= 3166.667 & mpce!=.
   replace mpce_quintiles = 3 if mpce > 3166.667 & mpce <= 4412.5 & mpce!=.
   replace mpce_quintiles = 4 if mpce > 4412.5 & mpce <= 6434 & mpce!=.
   replace mpce_quintiles = 5 if mpce > 6434 & mpce!=.
   
   tab mpce_quart, m
   tab mpce_quintiles, m
   vfdfvd
   * d
   
   keep Bangalore__index surveysectionAQ2_HDDS1_d surveysectionAQ2_HDDS2_d surveysectionAQ2_HDDS3_d surveysectionAQ2_HDDS4_d surveysectionAQ2_HDDS5_d surveysectionAQ2_HDDS6_d surveysectionAQ2_HDDS7_d surveysectionAQ2_HDDS8_d surveysectionAQ2_HDDS9_d surveysectionAQ2_HDDS10_d surveysectionAQ2_HDDS11_d surveysectionAQ2_HDDS12_d HDDS mpce_quintiles surveysectionDQ16b1_food_and_gro
   export excel using "C:\Users\kjagadeesh\Dropbox\hungry cities survey\year1\output\food_cats_mpce.xls", firstrow(variables) replace

   vfsd


   * begin log
   //log using "output\food_hdds_mpce_income.log", replace
tab mpce_quintiles surveysectionAQ2_HDDS1_d
tab mpce_quintiles surveysectionAQ2_HDDS2_d
tab mpce_quintiles surveysectionAQ2_HDDS3_d
tab mpce_quintiles surveysectionAQ2_HDDS4_d
tab mpce_quintiles surveysectionAQ2_HDDS5_d
tab mpce_quintiles surveysectionAQ2_HDDS6_d
tab mpce_quintiles surveysectionAQ2_HDDS7_d
tab mpce_quintiles surveysectionAQ2_HDDS8_d
tab mpce_quintiles surveysectionAQ2_HDDS9_d
tab mpce_quintiles surveysectionAQ2_HDDS10_d
tab mpce_quintiles surveysectionAQ2_HDDS11_d
tab mpce_quintiles surveysectionAQ2_HDDS12_d
   
tab mpce_quintiles surveysectionAQ2_HDDS1_d,row
tab mpce_quintiles surveysectionAQ2_HDDS2_d,row
tab mpce_quintiles surveysectionAQ2_HDDS3_d,row
tab mpce_quintiles surveysectionAQ2_HDDS4_d,row
tab mpce_quintiles surveysectionAQ2_HDDS5_d,row
tab mpce_quintiles surveysectionAQ2_HDDS6_d,row
tab mpce_quintiles surveysectionAQ2_HDDS7_d,row
tab mpce_quintiles surveysectionAQ2_HDDS8_d,row
tab mpce_quintiles surveysectionAQ2_HDDS9_d,row
tab mpce_quintiles surveysectionAQ2_HDDS10_d,row
tab mpce_quintiles surveysectionAQ2_HDDS11_d,row
tab mpce_quintiles surveysectionAQ2_HDDS12_d,row





  * close log of your work
    //log close
		


  



 

