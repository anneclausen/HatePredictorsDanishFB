*************************************
**** Merging topics onto data_final_cleaned.csv
*************************************

version 19
clear all
set more off

* Loading data_final_cleaned.csv
import delimited "data_final_cleaned.csv", encoding(utf8) bindquote(strict) clear

* Save as tmp-file for merge
save "tmp1.dta", replace

* Loading posts_topic_ids.csv
import delimited "posts_topic_ids.csv", encoding(utf8) bindquote(strict) clear

* Merge onto new_post_id
merge 1:m new_post_id using "tmp1.dta"

* Check merge result
tab _merge

// 1051 in _merge==2, because post_text is missing

// 163,724 matches in _merge==3

keep if _merge==3

drop _merge

* How many rows does each post-id have?
duplicates report new_post_id

* Count unique posts pr. topic
egen post_tag = tag(new_post_id)
tab topic_id if post_tag==1

*Topic-labels 
label define topic_lbl ///
	-1 "Outlier" ///
	0 "Generic captions/reactions" ///
	1 "Danish politics" ///
	2 "Children and parenting" ///
    3 "Police and crime" ///
    4 "Football" ///
	5 "Gender equality" ///
	6 "Romantic relationships" ///
    7 "Russia-Ukraine war" ///
	8 "Children's TV" ///
    9 "Islam/muslims" ///
	10 "Refugees and immigration" ///
	11 "TV series and movies" ///
	12 "Economy and government spending" ///
	13 "Racism" ///
    14 "Electric cars" ///
	15 "Sexuality and body image" ///
	16 "Sexual and gender minorities" ///
    17 "Israel-Palestine war" ///
	18 "Disease and vaccines" ///
	19 "Food, meat and diet" ///
	20 "National church and priests" ///
	21 "Agriculture and climate" ///
	22 "Copenhagen Pride" ///
	23 "Animals and nature" ///
	24 "Danish royal house"
	
label values topic_id topic_lbl

drop post_tag

* Export analysis dataset for regression analyses  
export delimited using "data_final_topics.csv", replace


