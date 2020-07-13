*** UC Analysis

** Run variable file

** Figure 1: Binned scatterplot

binscatter vouch_hh HHUC_hh if hh_extremelow!=1 & monthvar>693 & monthvar<696 & _merge9==3, ///
	xtitle("Households on Universal Credit (%)") ytitle("Households receiving food parcels (%)") ///
	msymbol(Oh) mcolor(black) ylabel(0(0.1)0.7) nquantiles(100) line(none)

xtset newid monthvar

** Table 1: Fixed-effects models
eststo clear
eststo: xtreg vouch_hh HHUC_hh monthvar i.month2 claimWA_no_uc if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , fe cluster(newid)
eststo: xtreg vouch_hh l.HHUC_hh monthvar i.month2 claimWA if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , fe cluster(newid)
eststo: xtreg vouch_hh l.vouch_hh l.HHUC_hh monthvar i.month2 claimWA if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , fe cluster(newid)
esttab



	
** Figure 2 and Web Appendix 2: How long has UC been active?
xtreg vouch_hh c.HHUC_hh##c.nmonths i.month2 claimWA if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , fe cluster(newid)
margins , dydx(HHUC_hh) at(nmonths=(0(1)29))
marginsplot, xlabel(0(5)30) xtitle(Number of months UC has been active) ///
	ytitle("Change in proportion of households receiving" ///
	"food voucher for every 1ppt increase in the" "proportion of households on UC") ///
	title(" ") text(0.015 5 "{it: p interaction} = 0.002") 

	
	
** Table 2: MLM - change and levels
eststo clear
eststo: mixed vouch_hh L.vouch_hh cD.HHUC_hh cL.HHUC_hh i.fb_present claimWA monthvar population ///
	i.month2 i.gor_v1 || jcpid: || oslaua:   if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , mle

eststo: mixed vouch_hh L.vouch_hh (cD.HHUC_hh cL.HHUC_hh)##i.fb_present claimWA monthvar population ///
	i.month2 i.gor_v1 || jcpid: || oslaua:   if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , mle
esttab 

	
** Figure 3 and Web Appendix 3: MLM- graph	
qui mixed vouch_hh L.vouch_hh (cD.HHUC_hh cL.HHUC_hh)##i.fb_present claimWA monthvar population ///
	i.month2 i.gor_v1 || jcpid: || oslaua:   if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , mle
margins fb_present, dydx(D.HHUC_hh) force post
eststo m1
coefplot, vertical ytitle("Percentage point increase in the" "number of vouchers distributed") ///
	xlabel(1 "No Food Banks Present" 2 "1 or more Food Banks Present")


qui mixed vouch_hh L.vouch_hh (cD.HHUC_hh cL.HHUC_hh)##i.fb_present claimWA monthvar population ///
	i.month2 i.gor_v1 || jcpid: || oslaua:   if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , mle
	
qui margins fb_present, dydx(L.HHUC_hh) force post
eststo m2
coefplot, vertical ytitle("Percentage point increase in the" "number of vouchers distributed") ///
	xlabel(1 "No Food Banks Present" 2 "1 or more Food Banks Present")
 
coefplot m1, bylabel("Change in UC claimants")  || ///
	m2, bylabel("Lagged level of UC claimants") ||, vertical ///
	ytitle("Percentage point increase in the" "number of vouchers distributed") ///
	xlabel(1 "No Food Banks Present" 2 "1 or more Food Banks Present") ylabel(0(0.01)0.05)





*** Beneficiaries results:
eststo: xtreg fbben HHUC monthvar i.month2 claimWA if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , fe cluster(newid)

eststo clear
eststo: xtreg fbben HHUC monthvar i.month2 claimWA if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , fe cluster(newid)
eststo: xtreg fbben l.HHUC monthvar i.month2 claimWA if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , fe cluster(newid)
eststo: xtreg fbben l.fbben l.HHUC monthvar i.month2 claimWA if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , fe cluster(newid)
esttab




eststo clear
eststo: mixed fbben L.fbben cD.HHUC cL.HHUC i.fb_present claimWA monthvar population ///
	i.month2 i.gor_v1 || jcpid: || oslaua:   if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , mle

eststo: mixed fbben L.fbben (cD.HHUC cL.HHUC)##i.fb_present claimWA monthvar population ///
	i.month2 i.gor_v1 || jcpid: || oslaua:   if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , mle
esttab 



*** using three wave panel	


keep if vouch!=.
keep if monthvar!=.
drop if households<33
keep if monthvar>667 & monthvar<696
drop if Lvouch_hh==.
keep if match3wave==1
keep if _merge9==3

** whether it is active or not
imb Lvouch_hh monthvar fbcentre_sum population  LclaimWA gor_v1 , tr(active) 


cem Lvouch_hh monthvar(#0) fbcentre_sum(#0) population  LclaimWA gor_v1(#0) , tr(active) 
 
	
reg vouch_3mo i.active [iweight=cem_weights]
margins active, noweights post
eststo m1
coefplot, vertical ylabel(0(0.01)0.1) ytitle("Proportion of households receiving food vouchers") ///
	xlabel(1 "UC not implemented" 2 "UC implemented")


*** Full Service analysis
eststo clear 
eststo: xtreg vouch_hh FullActive monthvar i.month2 claimWA if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , fe cluster(newid)
eststo: xtreg vouch_hh FullActive HHUC_hh monthvar i.month2 claimWA if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , fe cluster(newid)
eststo: xtreg vouch_hh L.FullActive L.HHUC_hh L.vouch_hh monthvar i.month2 claimWA if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , fe cluster(newid)
esttab 

	
*** Full service interaction
xi: mixed vouch_hh L.vouch_hh (cD.HHUC_hh cL.HHUC_hh)##i.FullActive##i.fb_present claimWA monthvar population ///
	i.month2 i.gor_v1 || jcpid: || oslaua:   if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 , mle
margins FullActive, dydx(D.HHUC_hh) at(fb_present=(0 1)) force post
eststo m1
coefplot, vertical ytitle("Percentage point increase in the" "number of vouchers distributed") ///
	xlabel(1 `""Full UC not active" "and no Foodbank""' 2 `""Full UC active" "and no Foodbank""' ///
	3 `""Full UC not active" "with a Foodbank""' 4 `""Full UC active" "with a Foodbank""')

 	
*** full service matching
*** major matching
 
keep if vouch!=.
keep if monthvar!=.
drop if households<33
keep if monthvar>667 & monthvar<696
drop if Lvouch_hh==.
keep if match3waveFA==1

keep if _merge9==3

** whether it is active or not
imb Lvouch_hh monthvar fbcentre_sum population LclaimWA gor_v1 HHUC_hh, tr(FullActive)
cem Lvouch_hh monthvar(#0) fbcentre_sum(#0) population LclaimWA gor_v1(#0) HHUC_hh, tr(FullActive)


reg vouch_3mo i.FullActive [iweight=cem_weights]
margins FullActive, noweights post
eststo m1
coefplot, vertical ylabel(0(0.02)0.14) ytitle("Proportion of households receiving food vouchers") ///
	xlabel(1 "Full Active UC not implemented" 2 "Full Active UC implemented")

	
	
	
*** web appendix 1
recode startmonths (-1=0) (0/1=1) (2/3=2) (4/6=3) (7/12=4) (13/27=5) (28=6), g(months_recoded)
xtreg HHUC_hh i.noccur if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 & active==1 & months_recoded==1, fe cluster(newid)
margins noccur, post
eststo m2
xtreg HHUC_hh i.noccur if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 & active==1 & months_recoded==2, fe cluster(newid)
margins noccur, post
eststo m3
xtreg HHUC_hh i.noccur if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 & active==1 & months_recoded==3, fe cluster(newid)
margins noccur, post
eststo m4
xtreg HHUC_hh i.noccur if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 & active==1 & months_recoded==4, fe cluster(newid)
margins noccur, post
eststo m5
xtreg HHUC_hh i.noccur if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 & active==1 & months_recoded==5, fe cluster(newid)
margins noccur, post
eststo m6



coefplot m2 m3 m4 m5 m6, vertical ytitle(Proportion of households on Universal Credit) ///
	xtitle(Number of months UC has been active) xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" ///
	12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 ///
	"25" 26 "26" 27 "27" 28 "28" 29 "29") plotlabels("Active in September/October 2015" "Active in November/December 2015" ///
	"Active in January/March in 2016" "Active in April/September 2016" "Active in October 2016/December 2017") legend(position(6) row(2))	

	
	
xtreg HHUC_hh i.noccur if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 & active==1 & imd_4cat==0, fe cluster(newid)
margins noccur, post
eststo m1
xtreg HHUC_hh i.noccur if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 & active==1 & imd_4cat==1, fe cluster(newid)
margins noccur, post
eststo m2
xtreg HHUC_hh i.noccur if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 & active==1 & imd_4cat==2, fe cluster(newid)
margins noccur, post
eststo m3
xtreg HHUC_hh i.noccur if hh_extremelow!=1 & monthvar>666 & monthvar<696 & _merge9==3 & active==1 & imd_4cat==3, fe cluster(newid)
margins noccur, post
eststo m4

coefplot (m1, label("Most deprived quartile"))  m2 m3 m4 , vertical ytitle(Proportion of households on Universal Credit) ///
	xtitle(Number of months UC has been active) xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" ///
	12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 ///
	"25" 26 "26" 27 "27" 28 "28" 29 "29") plotlabels("Most deprived quartile" "2nd quartile of deprivation" ///
	"3rd quartile of deprivation" "Least deprived quartile") legend(position(6) row(2))	
