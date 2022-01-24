/**************************************************************************
	
	clean-accts-state.do
	
	AC Forrester
	
	Last update: 12.23.2019
	
	Clean the BEA accounts data st the state level (SAINC50).
	
**************************************************************************/	
	
	* Project params
	loc	main	general-social
	loc	subd	gss-data
	
	* Main directories
	gl	raw	${build}`main'/`subd'/raw/
	gl	zip	${build}`main'/`subd'/zip/
	gl	dta	${build}`main'/`subd'/dta/
	
	* URL
	loc	url	https://gss.norc.org/documents/stata/
	
/**************************************************************************
	
	fetch the data if necessary
	
**************************************************************************/	
	
	cap confirm file ${zip}GSS_stata.zip
	if _rc {
		
		cd ${raw}
		copy https://gss.norc.org/documents/stata/GSS_stata.zip ${zip}
		unzipfile ${zip}GSS_stata.zip
		
		cd ${home}
		
	}
	
/**************************************************************************
	
	clean the GSS data for three variables (TRUST, FAIR, HELPFUL)
	
**************************************************************************/	
		
	* Open the GSS flat file
	use ${raw}GSS7218_R1, clear
	
	* Subset
	keep year id region wtssall trust helpful fair
	
	* Recode
	recode trust helpful fair (2 = 0) (3 = 0.5)
	
	* Save in merge directory
	save ${merge}gss-trust, replace
	
/**************************************************************************
	
	GSS 1: 5-year buckets (1975 - 2015)
	
**************************************************************************/	
	
	* open the subset data
	use ${merge}gss-trust, clear
	
	* loop over intervals
	forval i = 1975(5)2010 {
		recode year (`i'/`=`i'+4' = `i')
	}
	drop if (year > 2015 | year < 1975)
	
	* Gen ones
	gen sample_size = 1
	
	* Wgt average over divisions
	collapse (mean) trust helpful fair ///
		(rawsum) sample_size [pw = wtssall], by(region year)
	
	* Rescale (0-100)
	foreach var in trust helpful fair {
		replace `var' = `var'*100
	}
		
	* Sort
	sort region year
	
	* Rename region
	ren region division_code
		
	* Save in merge
	save ${merge}gss-trust-5yr, replace
	
/**************************************************************************
	
	GSS 2: annual (1972 - 2018)
	
**************************************************************************/	
	
	* open the subset data
	use ${merge}gss-trust, clear
	
	* Gen ones
	gen sample_size = 1
	
	* Wgt average over divisions
	collapse (mean) trust helpful fair (rawsum) sample_size [pw = wtssall], by(region year)
	
	* Fill in
	tsset region year, yearly
	tsfill	
	
	* Sort
	sort region year
	
	* Rename region
	ren region division_code
	
	* non-interpolated values
	gen imputed_vals = (trust != .)
	
	* Rescale (0-100) and interpolate (linear)
	foreach var in trust helpful fair {
		replace `var' = `var'*100
		by division_code: ipolate `var' year, gen(i`var')
	}
		
	* Save in merge
	save ${merge}gss-trust-1yr, replace
	
/**************************************************************************
	
	GSS 3: biennial (1972 - 2018)
	
**************************************************************************/	
	
	* open the subset data
	use ${merge}gss-trust, clear
	
	* Gen ones
	gen sample_size = 1
	
	* keep even years
	keep if mod(year,2) == 0
	
	* Wgt average over divisions
	collapse (mean) trust helpful fair (rawsum) sample_size [pw = wtssall], by(region year)
	
	* non-interpolated values
	gen imputed_vals = (trust != .)
	
	* Rescale (0-100) and interpolate (linear for 1974/1992)	
	foreach var in trust helpful fair {
		replace `var' = `var'*100
		by region: ipolate `var' year, gen(i`var')
	}
	
	* Sort
	sort region year
	
	* Rename region
	ren region division_code
		
	* Save in merge
	save ${merge}gss-trust-2yr, replace
	
/**************************************************************************
	
	clean the GSS data to compare with WVS
	
**************************************************************************/	
		
	* Open the GSS flat file
	use ${raw}GSS7218_R1, clear
	
	* Subset
	keep year id region wtssall trust
	
	* Recode
	recode trust (2 = 0) (3 = 0.5)
	
	* wvs wave
	gen wave = .
	replace wave = 1 if inrange(year, 1981, 1984)
	replace wave = 2 if inrange(year, 1989, 1993)
	replace wave = 3 if inrange(year, 1994, 1998)
	replace wave = 4 if inrange(year, 1999, 2004)
	replace wave = 5 if inrange(year, 2005, 2009)
	replace wave = 6 if inrange(year, 2010, 2014)
	
	* drop missing
	drop if wave == .
	
	* Wgt average over divisions
	collapse (mean) trust [pw = wtssall], by(wave)
	
	* Replace
	replace trust = trust*100
				
	* Rename
	ren trust gss_trust
		
	* Save in merge
	save ${merge}gss-trust-compare, replace
	
***************************************************************************	
	
*	End of file
