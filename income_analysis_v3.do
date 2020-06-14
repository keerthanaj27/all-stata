* This file:* convert income into income per capita 
            * checks correlation between income | logincome on HFIASS score 
            * runs regression on log_income with hfiap categories, and outputs regression table
* Author: Keerthana J.
* Date: April 15th, 2019


* set the working directory 
  cd "C:\Users\kjagadeesh\Dropbox\hungry cities survey\year1"

* import the food security data dataset
  use "data\hcp04082017_merged.dta", clear
  
* convert income to income per capita
  gen income_capita = sum_income/surveysectionCQ12ahousehold_numb
  sum income_capita, d
  drop if income_capita == 0

* inspect the income variable
  sum income_capita, d
  * describe the date
  inspect income_capita
  * quantile look
  quantile income_capita
  quantile sum_income
  * box plot
  graph hbox income_capita
  // many many outliers 
  
   * tab all of it 
   tabstat income_capita, stat(n mean cv q)
   * let's create quantiles for income
   xtile income_quart = income_capita, nq(5)
  
   tab income_quart, m  
   tab income_quart, sum(income_capita)
   
   *histogram
   histogram income_capita
 
   // right skewed data - positive skewness, heavy tailed
 
   * scatterplot income with HFIASS
   twoway (scatter HFIASS income_capita) 
  
   ** this shows how high HFIASS has lower income
   ** but not convincingly a linear relationship between income and HFIASS, since there are fewer households of low income and high HFIASS
  
   * let us log income to deal with the skewness
   gen log_income = ln(income_capita)
   
   * histogram 
   histogram log_income, width (0.5)
   
   twoway (scatter HFIASS log_income)
   
   * create dummies of HFIAP categories to regress on income 
   tab HFIAP, m
   
   decode HFIAP, gen(HFIAP_d)
  
   gen hfiap_new = 1 if HFIAP_d == "Food Secure"
   replace hfiap_new = 2 if HFIAP_d == "Mildly Food Insecure" | HFIAP_d == "Moderately Food Insecure"
   replace hfiap_new = 3 if HFIAP_d == "Severely Food Insecure"
   tab hfiap_new, m
   
   * Creating dummies for new hfiap to use in regression
   tab hfiap_new, generate(dum)
   rename dum1 hfiap_secure
   rename dum2 hfiap_mm_insec
   rename dum3 hfiap_severe
   //assert hfiap_secure + hfiap_mm_insec + hfiap_severe == 1 
   // 39 missing values already in the data 
   
   ** Removing variable labels of hfiap status

    foreach var in hfiap_secure hfiap_severe hfiap_mm_insec{
        label var `var' ""
    }
	
	 * convert HFIASS to a binary variable (as done in the Maithra paper)
   gen hfiass_binary = 0 if HFIASS!=  0
   replace hfiass_binary = 1 if HFIASS == 0
   * food secure == 1 & any kind of insecurtiy == 0
	
	* running regressions
	* running regression where the independent variable is log_income and dependent variable is binary hfiass 
    logit hfiass_binary log_income, 
    estimates store hfiass_by_log_income, title(Income-PC_HFIASS)
	predict yhat1
	twoway scatter yhat1 hfiass_binary log_income, connect(l i) msymbol(i O) sort ylabel(0 1)
	
	* printing stored estimates to file
    xml_tab *, save("output\income_pc_hfiass_binary_nozero") below stats(N control_mean) cblanks() format((nccr2)) replace
   
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
  
  * running logit for hfiass binary, income and room and informal
  logit hfiass_binary log_income room flat informal
  estimates store hfiass_by_log_income_other, title(Income_HFIASS_others)
  
  //predict yhat1
 //twoway scatter yhat1 hfiass_binary log_income indi_houses flat informal, connect(l i) msymbol(i O) sort ylabel(0 1)
	
	* printing stored estimates to file
    xml_tab *, save("output\income_pc_hfiass_binary_hhtype_nozero") below stats(N control_mean) cblanks() format((nccr2)) replace
	  estimates clear
    
     * begin log
   log using "output\correlations_income-pc_hfiass_nozero.log", replace
    
	* correlations
       * set up the correlation between income and HFIASS
   correlate income_capita HFIASS 
   correlate log_income HFIASS 
   pwcorr income_capita HFIASS, star(.04) 
   
     * close log of your work
    log close
