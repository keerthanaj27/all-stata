* This file:* creates mpce variable
            * checks correlation between mpce | logincome on HFIASS score 
            * runs regression on mpce with hfiap categories, and outputs regression table
* Author: Keerthana J.
* Date: April 16th, 2019


* set the working directory 
  cd "C:\Users\kjagadeesh\Dropbox\hungry cities survey\year1"

* import the food security data dataset
  use "data\hcp04082017_merged.dta", clear

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
  
* inspect the income variable
  sum mpce, d
  * describe the date
  inspect mpce 
  * quantile look
  quantile mpce
  quantile consumpt
  
  * box plot
  graph hbox mpce
  // many many outliers 

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

   *histogram
   histogram mpce
   
   * correlate mpce
   correlate mpce HFIASS 
   pwcorr mpce HFIASS, star(.04) 
   
   /* scatterplot income with HFIASS
   twoway (scatter HFIASS mpce) 
   
   * let us log mpce to deal with the skewness
   gen log_mpce = ln(mpce)
   
   * histogram 
   histogram log_mpce, width (0.5)
   
   twoway (scatter HFIASS log_mpce)*/
   
   * create dummies of HFIAP categories to regress on income 
   tab HFIAP, m
   
   decode HFIAP, gen(HFIAP_d)
  
   gen hfiap_new = 1 if HFIAP_d == "Food Secure"
   replace hfiap_new = 2 if HFIAP_d == "Mildly Food Insecure" | HFIAP_d == "Moderately Food Insecure"
   replace hfiap_new = 3 if HFIAP_d == "Severely Food Insecure"
   tab hfiap_new, m
	vfdvfdbsd
	 * convert HFIASS to a binary variable (as done in the Maithra paper)
   gen hfiass_binary = 0 if HFIASS!=  0
   replace hfiass_binary = 1 if HFIASS == 0
   * food secure == 1 & any kind of insecurtiy == 0
	
	* running regressions
	/* For mpce alone: running regression where the independent variable is log_income and dependent variable is binary hfiass 
    logistic hfiass_binary mpce, 
    estimates store hfiass_by_mpce, title(MPCE_HFIASS)
	
	predict yhat1
	twoway scatter yhat1 hfiass_binary log_mpce, connect(l i) msymbol(i O) sort ylabel(0 1)*/
	
	* printing stored estimates to file
    //xml_tab *, save("output\mpce_hfiass_binary") below stats(N control_mean) cblanks() format((nccr2)) replace
	
	 * Housing type logistic
  * convert the hh member from double to string
  decode surveysectionDQ13_housing_types, gen(hh_str_type)
  tab hh_str_type , m
  
  * define the new clubbed together housing type  
  gen housing_type = 1 if substr(hh_str_type, 1, 4) == "Inde" | substr(hh_str_type, 1, 4) == "Indi"
  replace housing_type = 2 if substr(hh_str_type, 1, 4) == "Flat"
  replace housing_type = 3 if substr(hh_str_type, 1, 4) == "Shac" | substr(hh_str_type, 1, 4) == "Pucc" | substr(hh_str_type, 1, 4) == "Mobi" | substr(hh_str_type, 1, 4) == "Back"
  replace housing_type = 4 if substr(hh_str_type, 1, 4) == "Room"
  
  * create dummies for hh type
  tab housing_type, gen(dum)
  rename dum1 indi_houses
  rename dum2 flat
  rename dum3 informal
  rename dum4 room
  
  * 
  
  
  
  * running logit for hfiass binary, mpce and room and informal
  logit hfiass_binary mpce room flat informal
  
  VIF
  
  vsdfvsf
  estimates store hfiass_by_mpce_other, title(mpce_HFIASS_others)
  
  predict yhat3
  twoway scatter yhat3 hfiass_binary mpce indi_houses flat informal, connect(l i) msymbol(i O) sort ylabel(0 1)
	
	* printing stored estimates to file
    xml_tab *, save("output\mpce_hfiass_binary_hhtype") below stats(N control_mean) cblanks() format((nccr2)) replace
	  estimates clear
    
     * begin log
   log using "output\correlations_mpce_hfiass_hfiap.log", replace
    
   * summarize mpce 
	sum mpce, d
	
   * correlations
       * set up the correlation between income and HFIASS
   correlate mpce HFIASS 
   pwcorr mpce HFIASS, star(.04) 
   
   * do annova for mpce quintiles and HFIASS
    oneway HFIASS mpce_quintiles, tabulate
    pwmean HFIASS, over(mpce_quintiles) mcompare(tukey) effects
	
	* do annovva for mpce with hfiap categoris
	oneway mpce hfiap_new, tabulate
    pwmean mpce, over(hfiap_new) mcompare(tukey) effects
	
	* chi square of mpce quintiles and hfiap 
	tab mpce_quintiles hfiap_new, chi2 row
	
	* mpce quintiles by food expenditure
	oneway surveysectionDQ16b1_food_and_gro mpce_quintiles, tabulate
	pwmean surveysectionDQ16b1_food_and_gro, over(mpce_quintiles) mcompare(tukey) effects
	
	* mpce quintiles by food expenditure
	oneway HDDS mpce_quintiles, tabulate
	pwmean HDDS, over(mpce_quintiles) mcompare(tukey) effects
	
	* tab water
	tab surveysectionDsectonCM2piped_wa2,m
	
	* water by HFIASS
	oneway HFIASS surveysectionDsectonCM2piped_wa2, tabulate
    pwmean HFIASS, over(surveysectionDsectonCM2piped_wa2) mcompare(tukey) effects
	
	* chi square of water and hfiap 
	tab surveysectionDsectonCM2piped_wa2 hfiap_new, chi2 row
	
	* tab sanitation
	tab surveysectionDsectonCM2BANdr_dra, m
	
	* sanitation by HFIASS
	oneway HFIASS surveysectionDsectonCM2BANdr_dra, tabulate
    pwmean HFIASS, over(surveysectionDsectonCM2BANdr_dra) mcompare(tukey) effects
	
	* chi square of sanitation and hfiap 
	tab surveysectionDsectonCM2BANdr_dra hfiap_new, chi2 row
	
	
     * close log of your work
    log close
