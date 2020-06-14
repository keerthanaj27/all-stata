* This file:* merges the ward file with the main food security data 
            * 
            * 
* Author: Keerthana J.
* Date: April 16th, 2019

* set the working directory 
  cd "C:\Users\kjagadeesh\Dropbox\hungry cities survey\year1"
  
  * import the wards file 
  import excel "data\wards for analysis.xlsx", sheet("Sheet1") firstrow clear

  *remove space
  gen f_ward = strltrim(rtrim(name))
  gen t_ward = itrim(f_ward)
  tab t_ward 

  * tempfile
  tempfile ward_file
  save `ward_file'

  * import the food security + HHM merged dataset
  //use "data\HHS+HHM13092017.dta", clear
  * this is the food security only dataset
  use "data\hcp04082017_merged.dta", clear
  drop _merge
  decode ward, gen(ward_m)
  gen f_ward = rtrim(ward_m)
  gen t_ward = itrim(f_ward)
  tab t_ward
 
  * let's merge the two files
  merge m:1 t_ward using `ward_file', force
  assert _m !=2
  * rajaji nagar not there in shriy'as ward file
  //br name ward t_ward f_ward hhs samplesward coreperiphery G H I J _merge if _m == 1
  
  * manually assign core peri status to koramangala and hanumath nagar
  replace coreperiphery = "c" if t_ward == "Koramangala"
  replace coreperiphery = "c" if t_ward == "Rajaji Nagar" 
  gen c_p = 1 if coreperiphery == "c"
  replace c_p = 0 if coreperiphery == "p"
  tab coreperiphery, m
  tab c_p, m

  * clean 
  drop _merge
  
  * Income
  * convert income to income per capita
  gen income_capita = sum_income/surveysectionCQ12ahousehold_numb
  sum income_capita, d
  replace income_capita =. if income_capita == 0
  
  * let us log income to deal with the skewness
   gen log_income = ln(income_capita)
   
   * MPCE   
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
  
    * begin log
   log using "output\correlations_income-pc_mpce_core-peri.log", replace
  
  * tab core/peri core == 1 & peri == 0
  tab c_p, m
  
  * tab c-p by means of income capita
  tab c_p, sum(income_capita)
  tab c_p, sum(log_income)
  
  * tab c-p by means of mpce
  tab c_p, sum(mpce)
  
  * do annova for c-p and income capita
  oneway income_capita c_p, tabulate
  pwmean income_capita, over(c_p) mcompare(tukey) effects
  
   * do annova for c-p and income capita
  oneway log_income c_p, tabulate
  pwmean log_income, over(c_p) mcompare(tukey) effects
  
  * do annova for c-p and income capita
  oneway mpce c_p, tabulate
  pwmean mpce, over(c_p) mcompare(tukey) effects
  
  * correlations for income
       * set up the correlation between income and c_p
   correlate income_capita c_p 
   correlate log_income c_p 
   pwcorr income_capita c_p, star(.04)
   pwcorr log_income c_p, star(.04)
   
    * set up the correlation between mpce and c_p
   correlate mpce c_p 
   pwcorr mpce c_p, star(.04)
   
    * set up the correlation between mpce and hfiass for core (1)
   correlate HFIASS mpce if c_p == 1 
   pwcorr HFIASS mpce if c_p == 1, star(.05)
   
    * set up the correlation between mpce and hfiass for peri (0)
   correlate HFIASS mpce if c_p == 0 
   pwcorr HFIASS mpce if c_p == 0, star(.05)
     
     * close log of your work
    log close
   
