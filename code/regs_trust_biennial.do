


	set seed  12345

	use ${out}trust-biennial, clear

	
	
	gen log_trust = ln(trust)
	
	reghdfe d.pcincome l.log_trust l.pcincome  i.year [pw = sample_size], a(division_code) cl(division_code)
	
	boottest l.log_trust,  boottype(wild) weight(webb) nogr small
	
	eststo clear
	
	local growth 
	
	local spec1	l.log_trust 
	local spec2	l.log_trust	l.pcincome
		
	local fxd1	i.year
	local fxd2	division_code#c.year
	
	forval j = 1/2 {
	
		forval i = 1/2 {

			eststo reg_`i'`j': reghdfe d.pcincome `spec`j'' `fxd`i'', a(division_code) cl(division_code)
		
			local indep_vars `spec`j''
								

			local indep_hypotheses
			foreach var in `spec`j''{
				local indep_hypotheses = "`indep_hypotheses' {`var'}"
			}	
				
			
			boottest `indep_hypotheses',  boottype(wild) weight(webb) nogr
			
			local n_vars = 2
			
			matrix boot_pval  = J(1,`n_vars',.)
			matrix boot_ci_lb = J(1,`n_vars',.)
			matrix boot_ci_ub = J(1,`n_vars',.)
				
			forval k = 1/`n_vars' { //Loop through predictors, aka matrix columns
				matrix boot_pval[1,`k'] = r(p_`k')
				matrix CI_temp = r(CI_`k')
				matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
				matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
			}
			if (`j' == 1) {
				matrix boot_pval[1,2] = .
				matrix boot_ci_lb[1,2] = .
				matrix boot_ci_ub[1,2] = .
			}
			
			foreach mat in "boot_pval" "boot_ci_lb" "boot_ci_ub" {
				matrix colnames `mat' = `spec2'
				estadd matrix `mat' = `mat': reg_`i'`j'
			}
		
		}
		
	}
	
	#delim ;
	
	
	estout 
		using ${out}regs-biennial.tex,
		label 
		style(tex) 
		keep(*.pcincome *.log_trust)
		ml(, noti)
		collabels(none) 
		varlabels() 
		num
		cells(	b(fmt(3))
				boot_pval(fmt(3) par)
				boot_ci_lb(fmt(a3) par(`"["' `","'))
				& boot_ci_ub(fmt(a3) par(`""' `"]"')))
		stats(	r2_a
				N_clust
				N,
				fmt(3 %9.0gc %9.0gc)
				l(	"Adj. R-Sq." 
					"Divisions"
					"\(N\)")
				)
		prehead( 
			\begin{table}[h]
			\refstepcounter{table}            
			
			\label{table:regs-biennial}            
			
			\centering
			
			\textbf{Table \ref{table:}. Trust and Growth, Biennial Data} \\
			
			\begin{tabular}{@{\extracolsep{4pt}}l*{@M}{c}@{}} 
			\hline \hline 
		)
		posthead(\hline) 
		prefoot() 
		postfoot(
			\noalign{\smallskip} \hline \hline 
			\end{tabular}
			\medskip
			\begin{minipage}{0.9\textwidth}
			\footnotesize \justify Notes: \( @starlegend \). 
			\end{minipage}        
		\end{table}
		)
		replace;
	#delim cr

	
	
	
	
	
	
	
	
	
