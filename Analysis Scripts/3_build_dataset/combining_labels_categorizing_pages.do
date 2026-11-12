********************************************************************************
*** In this do-file, the manually coded and BERT-predicted observations are combined into a single dataset.
*** The categorization of page_names into post_sender and news_type is also performed here.
*** The dataset is saved as data_final_cleaned.csv.
*** A dataset containing the necessary information for topic modeling of post is saved as posts_for_topic_modelling.csv
********************************************************************************

version 19
clear all
set more off

// Loading hand-coded data
import delimited "manual_codings.csv", encoding(utf8) bindquote(strict) clear

// Identifying manually annotated observations
gen label_source = 1

// Saving as temp-file
tempfile manual
save `manual'

// loads BERT-predicted observations for hs/no-hs
import delimited "all_labelled.csv", encoding(utf8) bindquote(strict) clear

gen label_source = 2

// Appends to the manually coded observations
append using `manual'

// Merge explicit hate speech variable onto
preserve
import delimited "all_labelled_exp.csv", encoding(utf8) bindquote(strict) clear
keep global_id exp_pred exp_prob  
tempfile exp
save `exp'
restore

merge 1:1 global_id using `exp'
tab _merge          
drop _merge

// Merge implicit hate speech variable onto
preserve
import delimited "all_labelled_imp.csv", encoding(utf8) bindquote(strict) clear
keep global_id imp_pred imp_prob
tempfile imp
save `imp'
restore

merge 1:1 global_id using `imp'
tab _merge
drop _merge

// Merge negative stereotyping variable onto
preserve
import delimited "all_labelled_imp_nstereo.csv", encoding(utf8) bindquote(strict) clear
keep global_id imp_nstereo_pred imp_nstereo_prob
tempfile imp_nstereo
save `imp_nstereo'
restore

merge 1:1 global_id using `imp_nstereo'
tab _merge
drop _merge

tab label_source
count
duplicates report global_id

label define label_source_lbl ///
    1 "Manual annotation" ///
    2 "BERT classification"

label values label_source label_source_lbl

tab label_source

codebook post_id
codebook post_text
codebook page_name

// Codes one hate speech variable
gen hs_total=.
replace hs_total=1 if hs==1 | hs_pred==1
replace hs_total=0 if hs==0 | hs_pred==0

// Codes one explicit hate speech variable
gen exp_total=.
replace exp_total=1 if exp==1| exp_pred==1
replace exp_total=0 if exp==0| exp_pred==0

// Codes one implicit hate speech variable
gen imp_total=.
replace imp_total=1 if imp==1| imp_pred==1
replace imp_total=0 if imp==0| imp_pred==0

// Codes one negative stereotyping variable
gen imp_nstereo_total=.
replace imp_nstereo_total=1 if imp_nstereo==1| imp_nstereo_pred==1
replace imp_nstereo_total=0 if imp_nstereo==0| imp_nstereo_pred==0

*******************************************
*** Categorizes page_names into the post_sender variable
*******************************************

gen post_sender = .

replace post_sender = 1 if page_name == "112alarm.dk" | page_name == "180Grader" | page_name == "24syv" | page_name == "A4" | page_name == "ALT for damerne" | page_name == "ANR" | page_name == "Adresseavisen / Lokalavisen Syddjurs" | page_name == "Aftenshowet - DR" | page_name == "Altinget.dk" | page_name == "Amager LIV" | page_name == "Amtsavisen.dk" | page_name == "Atlas Magasin" | page_name == "Avisen Danmark" | page_name == "Avisen.dk" | page_name == "B.T." | page_name == "BO BEDRE" | page_name == "Berlingske" | page_name == "Bil Magasinet" | page_name == "Billed-Bladet" | page_name == "BoligLiv" | page_name == "Bornholms Tidende" | page_name == "Brønderslev LigeHer.nu" | page_name == "Bådmagasinet" | page_name == "Børsen" | page_name == "DEN KORTE AVIS" | page_name == "DR LYD" | page_name == "DR Nyheder" | page_name == "DR P1" | page_name == "DR P2" | page_name == "DR P3" | page_name == "DR P4 Fyn" | page_name == "DR P4 København" | page_name == "DR P4 Midt & Vest" | page_name == "DR P4 Nordjylland" | page_name == "DR P4 Sjælland" | page_name == "DR P4 Syd og Esbjerg" | page_name == "DR P4 Østjylland" | page_name == "DR Politik" | page_name == "DR Sporten" | page_name == "DR1" | page_name == "DR2" | page_name == "Dagbladet / Stevns" | page_name == "Dagbladet Arbejderen"  | page_name == "Dagbladet Holstebro-Struer" | page_name == "Dagbladet Information" | page_name == "Dagbladet Køge" | page_name == "Dagbladet Ringkøbing-Skjern" | page_name == "Dagbladet Ringsted" | page_name == "Dagbladet Roskilde" | page_name == "Dagens Medicin" | page_name == "Dagens Nyheder" | page_name == "Dagens.dk" | page_name == "Dansk Markedsføring" | page_name == "Danwatch" | page_name == "Deadline - DR" | page_name == "Debatten - DR" | page_name == "Del efterlysningen" | page_name == "Der Nordschleswiger" | page_name == "Detektor - DR" | page_name == "Din Avis Aarhus Onsdag" | page_name == "DitOverblik" | page_name == "ELLE DK" | page_name == "Ekstra Bladet" | page_name == "Ekstra Bladet Sport" | page_name == "En Uafhængig Morgen" | page_name == "Euroman" | page_name == "Eurowoman DK" | page_name == "FIT Living" | page_name == "Fagavisen Søfart" | page_name == "Fagbladet 3F" | page_name == "Fagbladet Dansk Politi" | page_name == "Familie Journal" | page_name == "Faxe Nyheder" | page_name == "Feltet.dk" | page_name == "Filmmagasinet Ekko" | page_name == "Filmz.dk" | page_name == "Finans" | page_name == "Fiskeri Tidende" | page_name == "Folkebladet Lemvig" | page_name == "Folkeskolen" | page_name == "Forbrugerrådet Tænk" | page_name == "Forsvaret" | page_name == "Fredericia Dagblad" | page_name == "Frederiksberg LIV" | page_name == "Frederiksborg Amts Avis" | page_name == "Frederiksborg Amts Avis Gribskov" | page_name == "Free Observer" | page_name == "Frihedens Stemme" | page_name == "Frihedsbrevet" | page_name == "Friktion" | page_name == "Fyens Stiftstidende Assens" | page_name == "Fyens.dk" | page_name == "Føljeton" | page_name == "GAFFA Danmark" | page_name == "Globalnyt" | page_name == "Go' morgen Danmark og Go' aften Live" | page_name == "HER & NU" | page_name == "Hafnia 1992" | page_name == "Heartbeats" | page_name == "Helsingør Dagblad" | page_name == "Hendes Verden" | page_name == "Herlev Bladet" | page_name == "Herning Folkeblad" | page_name == "Hjemmet" | page_name == "Horsens Folkeblad" | page_name == "Ibyen" | page_name == "Illustreret Videnskab" | page_name == "Indblik.dk" | page_name == "Ingeniøren" | page_name == "Jammerbugt LigeHer.nu" | page_name == "Journalisten" | page_name == "JydskeVestkysten" | page_name == "JydskeVestkysten Aabenraa" | page_name == "JydskeVestkysten Billund" | page_name == "JydskeVestkysten Esbjerg" | page_name == "JydskeVestkysten Haderslev" | page_name == "JydskeVestkysten Kolding" | page_name == "JydskeVestkysten Sønderborg" | page_name == "JydskeVestkysten Tønder" | page_name == "JydskeVestkysten Varde" | page_name == "JydskeVestkysten Vejen" | page_name == "Jyllands-Posten" | page_name == "Kalundborg Nyheder" | page_name == "Kforum" | page_name == "Kirke.dk" | page_name == "Kolding Netavis" | page_name == "Kongerækken" | page_name == "Kontrast" | page_name == "Krigeren.dk" | page_name == "Krimi Fyn" | page_name == "Kristeligt Dagblad" | page_name == "Kristendom.dk" | page_name == "Kulturmonitor" | page_name == "LOCAL EYES - nyheder fra forreste linje" | page_name == "LandbrugsAvisen" | page_name == "Liv" | page_name == "Lokalavisen Egedal" | page_name == "Lokalavisen Favrskov" | page_name == "Lokalavisen Frederikssund" | page_name == "Lokalavisen Taastrup" | page_name == "Lokalavisen.dk" | page_name == "MagaCin.dk" | page_name == "Magasinet KBH" | page_name == "Mandag Morgen" | page_name == "Midtjyllands Avis" | page_name == "MigogAalborg" | page_name == "MigogAarhus" | page_name == "NORDJYSKE" | page_name == "NOVA" | page_name == "Natholdet" | page_name == "Nattevagten - RADIO IIII" | page_name == "Netavisen Pio" | page_name == "Nordjyske Morsø" | page_name == "Nordjyske Thy" | page_name == "NordsøPosten" | page_name == "Nordvest LIV" | page_name == "Nordvestnyt" | page_name == "Nyt om Midtfyn" | page_name == "Næstved Nyheder" | page_name == "Nørrebro LIV" | page_name == "OLFI" | page_name == "Odder Avis" | page_name == "P3 x DRTV" | page_name == "P4 - DR" | page_name == "P6 BEAT - DR" | page_name == "POV International" | page_name == "Politiken" | page_name == "Politiken Foto" | page_name == "Politikens Poptillæg" | page_name == "Politirapporten.nu" | page_name == "Presse-fotos.dk" | page_name == "RADIO IIII" | page_name == "RUC Paper" | page_name == "Radio ABC" | page_name == "Radio Alfa" | page_name == "Radio SLR" | page_name == "Radio Skive" | page_name == "Radio VLR" | page_name == "Radio Viborg" | page_name == "Randersidag.dk" | page_name == "Religion.dk" | page_name == "Researchkollektivet Redox" | page_name == "Ridehesten" | page_name == "Roskilde Avis" | page_name == "RÆSON" | page_name == "Rødovre Lokal Nyt" | page_name == "SE og HØR" | page_name == "SN.DK/Hørsholm" | page_name == "Samvirke" | page_name == "Sjællandske Nyheder" | page_name == "Sjællandske Slagelse" | page_name == "Skive Folkeblad" | page_name == "Skolemonitor" | page_name == "Slagelse News" | page_name == "Solidaritet" | page_name == "Sorø sn.dk" | page_name == "Soundvenue" | page_name == "Sydhavnen LIV" | page_name == "Sydkysten" | page_name == "Sæby Avisen - www.saebyavis.dk" | page_name == "Sønderborg NYT - gratis lokale nyheder fra Sønderborg" | page_name == "TIPSBLADET" | page_name == "TV 2" | page_name == "TV 2 Echo" | page_name == "TV 2 Fyn" | page_name == "TV 2 Kosmopol" | page_name == "TV 2 NEWS" | page_name == "TV 2 Nyheder" | page_name == "TV 2 ZULU" | page_name == "TV 2/Bornholm" | page_name == "TV MIDTVEST" | page_name == "TV SYD" | page_name == "TV2 Nord" | page_name == "TV2 ØST" | page_name == "TV2 Østjylland" | page_name == "The Copenhagen Post" | page_name == "TjekDet" | page_name == "Transportmagasinet" | page_name == "Ude og Hjemme" | page_name == "Udfordringen" | page_name == "Uge-Bladet Skanderborg" | page_name == "Ugeavisen Aabenraa" | page_name == "Ugeavisen Esbjerg" | page_name == "Ugeavisen Kolding" | page_name == "Ugeavisen Odense" | page_name == "Ugeavisen Svendborg" | page_name == "Ugeavisen Sønderborg" | page_name == "Ugeskrift for Læger" | page_name == "Uniavisen" | page_name == "Valby LIV" | page_name == "Vanløse LIV" | page_name == "Vejle Amts Folkeblad" | page_name == "Verdens Bedste Nyheder" | page_name == "Version2" | page_name == "Vestegnen" | page_name == "Viborg Stifts Folkeblad" | page_name == "Videnskab.dk" | page_name == "Villabyerne" | page_name == "Vordingborg sn.dk" | page_name == "Vordingborg.in" | page_name == "Vores Børn" | page_name == "Vores Faaborg" | page_name == "Vores Kerteminde" | page_name == "Vores Middelfart" | page_name == "Vores Nordfyn" | page_name == "Vores Nyborg" | page_name == "Vores Odense" | page_name == "Weekendavisen" | page_name == "Zetland" | page_name == "aalborg.nu" | page_name == "bold.dk" | page_name == "femina" | page_name == "fiskerforum.dk" | page_name == "folkekirken.dk" | page_name == "folketidende.dk" | page_name == "idenyt" | page_name == "iform.dk" | page_name == "ikast-brandenyt.dk" | page_name == "newsbreak.dk" | page_name == "stiften.dk" | page_name == "Østbirk Avis Østjydsk Avis" | page_name == "Østerbro LIV" | page_name == "Omnibus" | page_name == "Flyvevåbnet" | page_name == "Ældre Sagen" | page_name == "Art Matter - former kunsten.nu" |  page_name == "Dansk Aktionærforening" | page_name == "Dansk Psykolog Forening" | page_name == "Dansk Socialrådgiverforening" | page_name == "Danske Døves Landsforbund" | page_name == "Danske Seniorer" | page_name == "HKKF - Soldaternes Fagforening" | page_name == "Københavns Lærerforening" | page_name == "Lederforeningen i DSR" 
 

replace post_sender = 2 if page_name == "Aaja Chemnitz, Inuit Ataqatigiit" | page_name == "Aki-Matilda Høegh-Dam" | page_name == "Alex Vanopslagh" | page_name == "Alexander Ryle" | page_name == "Anders Kronborg" | page_name == "Ane Halsboe-Jørgensen" | page_name == "Anne Hegelund" | page_name == "Anne Valentina Berthelsen" | page_name == "Annette Lind" | page_name == "Anni Matthiesen" | page_name == "Astrid Carøe" | page_name == "Astrid Krag" | page_name == "Benny Engelbrecht" | page_name == "Betina Kastbjerg - Danmarksdemokraterne" | page_name == "Birgitte Vind" | page_name == "Bjarne Laustsen" | page_name == "Bjørn Brandenborg" | page_name == "Brigitte Klintskov Jerkel Politiker" | page_name == "Camilla Fabricius" | page_name == "Carl Valentin" | page_name == "Carsten Bach" | page_name == "Charlotte Broman Mølbæk" | page_name == "Charlotte Munch - Danmarksdemokraterne" | page_name == "Christian Friis Bach" | page_name == "Christian Rabjerg Madsen" | page_name == "Christina Olumeko - Alternativet" | page_name == "Christoffer Aagaard Melson" | page_name == "Dan Jørgensen" | page_name == "Dennis Flydtkjær" | page_name == "Erling Bonnesen" | page_name == "Fie Hækkerup" | page_name == "Flemming Møller Mortensen" | page_name == "Franciska Rosenkilde" | page_name == "Frederik Vad" | page_name == "Gunvor Wibroe" | page_name == "Hans Andersen" | page_name == "Hans Christian Schmidt" | page_name == "Hans Kristian Skibby" | page_name == "Helene Liliendahl Brydensholt" | page_name == "Helle  Bonnesen" | page_name == "Henrik Dahl" | page_name == "Henrik Møller" | page_name == "Ida Auken" | page_name == "Inger Støjberg" | page_name == "Jacob Jensen" | page_name == "Jacob Mark" | page_name == "Jakob Engel-Schmidt" | page_name == "Jan E. Jørgensen" | page_name == "Jens Joel" | page_name == "Jens Meilvang" | page_name == "Jeppe Bruus" | page_name == "Jeppe Søe" | page_name == "Jesper Petersen" | page_name == "Kaare Dybvad Bek" | page_name == "Karina Adsbøl" | page_name == "Karina Lorentzen Dehnhardt" | page_name == "Karsten Hønge" | page_name == "Katrine Daugaard - Liberal Alliance" | page_name == "Katrine Robsøe" | page_name == "Kenneth Fredslund Petersen - Danmarksdemokraterne" | page_name == "Kim Edberg Andersen" | page_name == "Kim Valentin" | page_name == "Kirsten Normann Andersen" | page_name == "Kris Jensen Skriver FT" | page_name == "Lars Boje Mathiesen" | page_name == "Lars Chr. Lilleholt" | page_name == "Lars Løkke Rasmussen" | page_name == "Lars-Christian Brask, Liberal Alliance" | page_name == "Lea Wermelin" | page_name == "Leif Lahn Jensen" | page_name == "Linea Søgaard-Lidell" | page_name == "Lisbeth Bech-Nielsen" | page_name == "Lise Bech" | page_name == "Lotte Rod" | page_name == "Louise Brown" | page_name == "Louise Schack Elholm" | page_name == "Mads Fuglede" | page_name == "Magnus Heunicke" | page_name == "Mai Mercado" | page_name == "Mai Villadsen" | page_name == "Malte Larsen" | page_name == "Maria Durhuus" | page_name == "Marie Bjerre" | page_name == "Marlene Harpsøe" | page_name == "Martin Lidegaard" | page_name == "Matilde Powers" | page_name == "Merete Scheelsbeck" | page_name == "Mette Abildgaard" | page_name == "Mette Frederiksen" | page_name == "Mette Reissmann - Folketingsmedlem, Socialdemokratiet" | page_name == "Mette Thiesen" | page_name == "Michael Aastrup Jensen" | page_name == "Mike Villa Fonseca" | page_name == "Mikkel Bjørn" | page_name == "Mogens Jensen" | page_name == "Mohammad Rona - MF for Moderaterne" | page_name == "Mona Juul" | page_name == "Monika Rubin" | page_name == "Morten Bødskov" | page_name == "Morten Dahlin" | page_name == "Morten Messerschmidt" | page_name == "Nanna W. Gotfredsen///Moderaterne - MF" | page_name == "Nick Zimmermann - Dansk Folkeparti" | page_name == "Nicolai Wammen" | page_name == "Niels Flemming Hansen" | page_name == "Ole Birk Olesen" | page_name == "Peder Hvelplund" | page_name == "Pelle Dragsted" | page_name == "Per Larsen" | page_name == "Pernille Rosenkrantz-Theil" | page_name == "Pernille Vermund" | page_name == "Peter Hummelgaard" | page_name == "Peter Kofod - Dansk Folkeparti" | page_name == "Peter Skaarup" | page_name == "Pia Kjærsgaard" | page_name == "Pia Olsen Dyhr" | page_name == "Rasmus Horn Langhoff" | page_name == "Rasmus Jarlov" | page_name == "Rasmus Lund-Nielsen - Moderaterne" | page_name == "Rasmus Prehn" | page_name == "Rasmus Stoklund" | page_name == "Rosa Bechmann Eriksen" | page_name == "Rosa Lund" | page_name == "Samira Nawa" | page_name == "Signe Munk" | page_name == "Simon Kollerup" | page_name == "Sjúrður Skaale" | page_name == "Sofie Lippert" | page_name == "Sophie Løhde" | page_name == "Steffen Larsen" | page_name == "Steffen W. Frølund" | page_name == "Susie Jessen - Danmarksdemokraterne" | page_name == "Sólbjørg Jakobsen" | page_name == "Søren Espersen" | page_name == "Søren Gade" | page_name == "Søren Pape Poulsen" | page_name == "Søren Søndergaard" | page_name == "Tanja Larsson-Socialdemokratiet" | page_name == "Theresa Berg Andersen" | page_name == "Theresa Scavenius" | page_name == "Thomas Danielsen" | page_name == "Thomas Skriver Jensen" | page_name == "Torsten Gejl" | page_name == "Torsten Schack Pedersen" | page_name == "Trine Bramsen" | page_name == "Trine Mach" | page_name == "Troels Lund Poulsen" | page_name == "Victoria Velásquez" | page_name == "Zenia Stampe" 

replace post_sender = 3 if page_name == "Alternativet" | page_name == "Danmarksdemokraterne" | page_name == "Dansk Folkeparti" | page_name == "Det Konservative Folkeparti" | page_name == "Enhedslisten" | page_name == "Frie Grønne - Danmarks Nye Venstrefløjsparti" | page_name == "Kristendemokraterne" | page_name == "Liberal Alliance" | page_name == "Moderaterne" | page_name == "Nye Borgerlige" | page_name == "Radikale Venstre" | page_name == "SF" | page_name == "Socialdemokratiet" | page_name == "Venstre, Danmarks Liberale Parti" 


label define post_sender_lbl ///
    1 "News" ///
    2 "Politicians" ///
    3 "Parties" ///

label values post_sender post_sender_lbl

tab post_sender, missing

*******************************************
*** Categorizes page_names into the variable news_type
*******************************************
codebook page_name
codebook page_name if post_sender==1
tab page_name if post_sender==1
levelsof page_name if post_sender==1, local(names) clean
di "`names'"

codebook page_name if post_sender==2
tab page_name if post_sender==2
levelsof page_name if post_sender==2, local(names) clean
di "`names'"

codebook page_name if post_sender==3
tab page_name if post_sender==3
levelsof page_name if post_sender==3, local(names) clean
di "`names'"

// Subdivides 'News' into 11 types: news_type
gen news_type=.
replace news_type=1 if page_name=="Avisen Danmark" | page_name=="Avisen.dk" | page_name=="Berlingske" | page_name=="Børsen" | page_name=="Dagbladet Information" | page_name=="Dagens.dk" | page_name=="Finans" | page_name=="Jyllands-Posten" | page_name=="Kristeligt Dagblad" | page_name=="Politiken" | page_name=="Politiken Foto" | page_name=="The Copenhagen Post" | page_name=="Weekendavisen" | page_name=="Zetland" | page_name=="DR Nyheder" | page_name=="TV 2 Nyheder"

replace news_type=2 if page_name=="Adresseavisen / Lokalavisen Syddjurs" | page_name=="Amager LIV" | page_name=="Amtsavisen.dk" | page_name=="Bornholms Tidende" | page_name=="Brønderslev LigeHer.nu" | page_name=="Dagbladet / Stevns" | page_name=="Dagbladet Holstebro-Struer" | page_name=="Dagbladet Køge" | page_name=="Dagbladet Ringkøbing-Skjern" | page_name=="Dagbladet Ringsted" | page_name=="Dagbladet Roskilde" | page_name=="Der Nordschleswiger" | page_name=="Din Avis Aarhus Onsdag" | page_name=="Faxe Nyheder" | page_name=="Folkebladet Lemvig" | page_name=="Fredericia Dagblad" | page_name=="Frederiksberg LIV" | page_name=="Frederiksborg Amts Avis" | page_name=="Frederiksborg Amts Avis Gribskov" | page_name=="Fyens Stiftstidende Assens" | page_name=="Fyens.dk" | page_name=="Helsingør Dagblad" | page_name=="Herlev Bladet" | page_name=="Herning Folkeblad" | page_name=="Horsens Folkeblad" | page_name=="Jammerbugt LigeHer.nu" | page_name=="JydskeVestkysten" | page_name=="JydskeVestkysten Aabenraa" | page_name=="JydskeVestkysten Billund" | page_name=="JydskeVestkysten Esbjerg" | page_name=="JydskeVestkysten Haderslev" | page_name=="JydskeVestkysten Kolding" | page_name=="JydskeVestkysten Sønderborg" | page_name=="JydskeVestkysten Tønder" | page_name=="JydskeVestkysten Varde" | page_name=="JydskeVestkysten Vejen" | page_name=="Kalundborg Nyheder" | page_name=="Kolding Netavis" | page_name=="Lokalavisen Egedal" | page_name=="Lokalavisen Favrskov" | page_name=="Lokalavisen Frederikssund" | page_name=="Lokalavisen Taastrup" | page_name=="Lokalavisen.dk" | page_name=="Magasinet KBH" | page_name=="Midtjyllands Avis" | page_name=="MigogAalborg" | page_name=="MigogAarhus" | page_name=="NORDJYSKE" | page_name=="Nordjyske Morsø" | page_name=="Nordjyske Thy" | page_name=="NordsøPosten" | page_name=="Nordvest LIV" | page_name=="Nordvestnyt" | page_name=="Nyt om Midtfyn" | page_name=="Næstved Nyheder" | page_name=="Nørrebro LIV" | page_name=="Odder Avis" | page_name=="Randersidag.dk" | page_name=="Roskilde Avis" | page_name=="Rødovre Lokal Nyt" | page_name=="SN.DK/Hørsholm" | page_name=="Sjællandske Nyheder" | page_name=="Sjællandske Slagelse" | page_name=="Skive Folkeblad" | page_name=="Slagelse News" | page_name=="Sorø sn.dk" | page_name=="Sydhavnen LIV" | page_name=="Sydkysten" | page_name=="Sæby Avisen - www.saebyavis.dk" | page_name=="Sønderborg NYT - gratis lokale nyheder fra Sønderborg" | page_name=="Uge-Bladet Skanderborg" | page_name=="Ugeavisen Aabenraa" | page_name=="Ugeavisen Esbjerg" | page_name=="Ugeavisen Kolding" | page_name=="Ugeavisen Odense" | page_name=="Ugeavisen Svendborg" | page_name=="Ugeavisen Sønderborg" | page_name=="Valby LIV" | page_name=="Vanløse LIV" | page_name=="Vejle Amts Folkeblad" | page_name=="Vestegnen" | page_name=="Viborg Stifts Folkeblad" | page_name=="Villabyerne" | page_name=="Vordingborg sn.dk" | page_name=="Vordingborg.in" | page_name=="Vores Faaborg" | page_name=="Vores Kerteminde" | page_name=="Vores Middelfart" | page_name=="Vores Nordfyn" | page_name=="Vores Nyborg" | page_name=="Vores Odense" | page_name=="aalborg.nu" | page_name=="folketidende.dk" | page_name=="ikast-brandenyt.dk" | page_name=="stiften.dk" | page_name=="Østbirk Avis Østjydsk Avis" | page_name=="Østerbro LIV"

replace news_type=3 if page_name=="24syv" | page_name=="DR LYD" | page_name=="DR P1" | page_name=="DR P2" | page_name=="DR P3" | page_name=="DR P4 Fyn" | page_name=="DR P4 København" | page_name=="DR P4 Midt & Vest" | page_name=="DR P4 Nordjylland" | page_name=="DR P4 Sjælland" | page_name=="DR P4 Syd og Esbjerg" | page_name=="DR P4 Østjylland" | page_name=="NOVA" | page_name=="Nattevagten - RADIO IIII" | page_name=="P4 - DR" | page_name=="P6 BEAT - DR" | page_name=="RADIO IIII" | page_name=="Radio ABC" | page_name=="Radio Alfa" | page_name=="Radio SLR" | page_name=="Radio Skive" | page_name=="Radio VLR" | page_name=="Radio Viborg" | page_name=="ANR"

replace news_type=4 if page_name=="Aftenshowet - DR" | page_name=="DR Politik" | page_name=="DR1" | page_name=="DR2" | page_name=="Deadline - DR" | page_name=="Debatten - DR" | page_name== "Go' morgen Danmark og Go' aften Live" | page_name=="Natholdet" | page_name=="TV 2" | page_name=="TV 2 Echo" | page_name=="TV 2 Fyn" | page_name=="TV 2 Kosmopol" | page_name=="TV 2 NEWS" | page_name=="TV 2 ZULU" | page_name=="TV 2/Bornholm" | page_name=="TV MIDTVEST" | page_name=="TV SYD" | page_name=="TV2 Nord" | page_name=="TV2 ØST" | page_name=="TV2 Østjylland" | page_name=="Detektor - DR" | page_name=="P3 x DRTV"

replace news_type=5 if page_name=="DR Sporten" | page_name=="Ekstra Bladet Sport" | page_name=="TIPSBLADET" | page_name=="bold.dk" | page_name=="Hafnia 1992" | page_name=="Feltet.dk"

replace news_type=6 if page_name=="B.T." | page_name=="Ekstra Bladet" | page_name=="Presse-fotos.dk" | page_name=="newsbreak.dk" | page_name=="SE og HØR" | page_name=="Dagens Nyheder"

replace news_type=7 if page_name=="Filmmagasinet Ekko" | page_name=="Filmz.dk" | page_name=="GAFFA Danmark" | page_name=="Heartbeats" | page_name=="Ibyen" | page_name=="Politikens Poptillæg" | page_name=="Soundvenue"

replace news_type=8 if page_name=="ALT for damerne" | page_name=="Atlas Magasin" | page_name=="BO BEDRE" | page_name=="Bil Magasinet" | page_name=="Billed-Bladet" | page_name=="BoligLiv" | page_name=="Bådmagasinet" | page_name=="ELLE DK" | page_name=="Euroman" | page_name=="Eurowoman DK" | page_name=="FIT Living" | page_name=="Familie Journal" | page_name=="HER & NU" | page_name=="Hendes Verden" | page_name=="Hjemmet" | page_name=="Liv" | page_name=="Ridehesten" | page_name=="Ude og Hjemme" | page_name=="Vores Børn" | page_name=="femina" | page_name=="idenyt" | page_name=="iform.dk" | page_name=="MagaCin.dk"

replace news_type=9 if page_name=="A4" | page_name=="Dagens Medicin" | page_name=="Dansk Markedsføring" | page_name=="Fagavisen Søfart" | page_name=="Fagbladet 3F" | page_name=="Fagbladet Dansk Politi" | page_name=="Fiskeri Tidende" | page_name=="Folkeskolen" | page_name=="Ingeniøren" | page_name=="Journalisten" | page_name=="Kforum" | page_name=="LandbrugsAvisen" | page_name=="Transportmagasinet" | page_name=="Ugeskrift for Læger" | page_name=="fiskerforum.dk" | page_name=="Illustreret Videnskab" | page_name=="Videnskab.dk" | page_name=="Kulturmonitor" | page_name=="Danwatch" | page_name=="Globalnyt" | page_name=="OLFI" | page_name=="TjekDet" | page_name=="Forsvaret" | page_name=="Krigeren.dk" | page_name=="Kirke.dk" | page_name=="Kristendom.dk" | page_name=="Religion.dk" | page_name=="folkekirken.dk" | page_name=="Udfordringen" | page_name=="Kongerækken"| page_name=="RUC Paper" | page_name=="Uniavisen" | page_name=="Verdens Bedste Nyheder" | page_name=="Skolemonitor" | page_name=="Version2" | page_name=="En Uafhængig Morgen" | page_name=="Frihedsbrevet" | page_name=="Friktion" | page_name=="Mandag Morgen" | page_name=="Føljeton" | page_name=="POV International" | page_name=="Omnibus" | page_name=="Flyvevåbnet" | page_name=="Ældre Sagen" | page_name=="Art Matter - former kunsten.nu" | page_name=="Dansk Aktionærforening" | page_name=="Dansk Psykolog Forening" | page_name=="Dansk Socialrådgiverforening" | page_name=="Danske Døves Landsforbund" | page_name=="Danske Seniorer" | page_name=="HKKF - Soldaternes Fagforening" | page_name=="Københavns Lærerforening" | page_name=="Lederforeningen i DSR" | page_name=="Samvirke" | page_name=="Forbrugerrådet Tænk"

replace news_type=10 if page_name=="RÆSON"  | page_name=="180Grader" | page_name=="Altinget.dk" | page_name=="DEN KORTE AVIS" | page_name=="Dagbladet Arbejderen" | page_name=="Frihedens Stemme" | page_name=="Indblik.dk" | page_name=="Kontrast" | page_name=="Netavisen Pio" | page_name=="Solidaritet" | page_name=="Researchkollektivet Redox" | page_name=="DitOverblik" | page_name=="Free Observer"

replace news_type=11 if page_name=="Del efterlysningen" | page_name=="Politirapporten.nu" | page_name=="LOCAL EYES - nyheder fra forreste linje" | page_name=="112alarm.dk" | page_name=="Krimi Fyn"

label define news_lbl 1 "National" ///
    2 "Regional/local" ///
    3 "Radio" ///
    4 "TV/broadcast" ///
    5 "Sport" ///
    6 "Tabloid" ///
    7 "Culture" ///
    8 "Magazine" ///
    9 "Niche media" ///
    10 "Politics" ///
    11 "Emergency/crime"

label values news_type news_lbl


// inspection of posts (ids and text)
bysort page_name post_text post_id: gen byte unik_id = (_n==1)
bysort page_name post_text: egen n_ids = total(unik_id)
browse page_name post_text post_id n_ids if n_ids>1 & post_text!=""

egen new_post_id = group(page_name post_text)
codebook post_text if new_post_id==.
// 1,022 new_post_id values ​​are missing because post_text is empty
codebook new_post_id
// 46,359 uniquw id's
codebook post_text 
// 46,058 uniquw post texts

bysort post_text new_post_id: gen byte unik_id2 = (_n==1)
bysort post_text: egen n_pids = total(unik_id2)
browse page_name post_text new_post_id n_pids if n_pids>1 & post_text!=""


* How many unique post_texts has n_pids>1?
egen tag_text = tag(post_text) if post_text!=""
count if tag_text==1 & n_pids>1
// 241 unique texts appear under more than one new_post_id

egen sum_check = total((n_pids-1)*tag_text) if tag_text==1
su sum_check
// sum_check = 301 (constant for all 46,058 texts, because the `total()` function—without a `by()` clause—sums across the entire dataset and "broadcasts" the value to all rows; this is why the standard deviation is 0)
// And 301 is exactly the difference we expected (46,359 − 46,058 = 301). The calculation checks out:
// The 301 "extra" groups are due to the fact that 241 distinct `post_text` values ​​have been posted by more than one `page_name`.

keep global_id comment_text created_time page_name post_text label_source post_sender hs_total exp_total imp_total imp_nstereo_total news_type new_post_id

export delimited using "data_final_cleaned.csv", replace

************************
*** Extracts a dataset containing only the information necessary for topic modeling
************************

preserve
keep if new_post_id!=.
keep post_text page_name post_sender new_post_id
duplicates drop
export delimited using "posts_for_topic_modelling.csv", replace // 46,359 rows
restore




