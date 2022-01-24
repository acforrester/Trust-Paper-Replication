/**************************************************************************
	
	Program:  main_trust_codes.do
	Authors:  AC Forrester
	
	Purpose: Main file to set directories for the Nowrasteh & Forrester (2019) 
	paper on generalized trust.
	
**************************************************************************/	
	
	* set main directory
	if (c(username) == "aforrester"){
		cd "..\"
	}
	else if (c(username) == "anowrasteh") {
		cd "..\"
	} 
	else {
		di as error "can't identify user --- abort!"
	}
	
	* set stuff
	set more off
	set scheme s1mono
	
	* main directories
	gl build	${dir}/build/
	gl output	${dir}/output/
	gl merge	${dir}/merge/
	gl code 	${dir}/code/
	
***************************************************************************	
	
*	End of file	
