# journal-analysis

A repository for exploring and identifying the best journals in which to publish a paper.

## Installation

This package is only available on GitHub.
```r
install.packages("devtools")
library(devtools)
install_github("vallenderlab/JournalAnalysis")
```

## Usage

  * Choose an Impact Factor dataset (`scimago` or `incities`).  
  * Create EUPMC style string queries in the _analysis.R_ script.  Multiple queries will produce article information that will be added together.  
  * Adjust the limit in order to get all of the data you want or to test out your query.  
  * Adjust the filtering parameters, and change the names of the files that will be produced.
  
### Example

Below is a simple example. You can also view our example vignette.

```R
> library(JournalAnalysis)
> pub_data <- get_publication_data(journal_source = "scimago", queries = c(query1, query2), limit = 1000, min_citations = 20)
14588 records found, returning 1000
(-) [=================================================] 100%
4005 records found, returning 1000
(/) [=================================================] 100%
Removed records published before 2008.
Removed records published after 2018.
Removed records with less than 20 citations.
Removed records with NA values for pmid, doi, and authors.
30 records passed the filter.
There were 30 warnings (use warnings() to see them)
>
>
>
> pub_data$journals

# A tibble: 22 x 18
    Rank Title          Type     SJR SJR.Best.Quarti~ H.index Total.Docs...20~ Total.Docs...3ye~ Total.Refs.
   <int> <fct>          <fct>  <dbl> <fct>              <int>            <int>             <int>       <int>
 1     6 Cell           journ~ 26.9  Q1                   655              693              1885       29440
 2    20 Nature         journ~ 18.1  Q1                  1011             2661              8198       43004
 3    30 Nature Immuno~ journ~ 14.5  Q1                   323              224               707        9749
 4    38 Science        journ~ 13.5  Q1                   978             2079              6670       36734
 5   138 Trends in Neu~ journ~  7.27 Q1                   254               84               264        6905
 6   147 American Jour~ journ~  7.14 Q1                   266              245               616        9620
 7   154 Molecular Psy~ journ~  6.92 Q1                   180              328               652       13379
 8   189 Biological Ps~ journ~  6.04 Q1                   273              382               982       14362
 9   256 Nature Review~ journ~  5.03 Q1                   104              225               867        8184
10   381 European Jour~ journ~  4.01 Q1                    87              126               322        5231
# ... with 12 more rows, and 9 more variables: Total.Cites..3years. <int>, Citable.Docs...3years. <int>,
#   Cites...Doc...2years. <dbl>, Ref....Doc. <dbl>, Country <fct>, Categories <fct>, ISSN <chr>,
#   ISSN.1 <fct>, ISSN.2 <fct>
>
>
>
> pub_data$articles

# A tibble: 30 x 29
   id     source pmid  doi   title authorString journalTitle pubYear journalIssn pubType isOpenAccess inEPMC
   <chr>  <chr>  <chr> <chr> <chr> <chr>        <chr>        <chr>   <chr>       <chr>   <chr>        <chr> 
 1 25815~ MED    2581~ 10.1~ Prom~ Fontana L, ~ Cell         2015    "00928674;~ "resea~ N            Y     
 2 27981~ MED    2798~ 10.1~ The ~ Rea K, Dina~ Neurobiol S~ 2016    23522895    "revie~ Y            Y     
 3 26912~ MED    2691~ 10.1~ Grow~ Luczynski P~ Int J Neuro~ 2016    "14611457;~ "resea~ Y            Y     
 4 27641~ MED    2764~ 10.1~ Gut ~ Dinan TG, C~ J Physiol    2017    "00223751;~ "revie~ N            N     
 5 28242~ MED    2824~ 10.1~ Targ~ Burokas A, ~ Biol Psychi~ 2017    "00063223;~ journa~ N            N     
 6 27090~ MED    2709~ 10.1~ From~ Rogers GB, ~ Mol Psychia~ 2016    "13594184;~ "revie~ Y            Y     
 7 28186~ MED    2818~ 10.1~ The ~ Simon DW, M~ Nat Rev Neu~ 2017    "17594758;~ "resea~ N            Y     
 8 28686~ MED    2868~ 10.1~ 10 Y~ Visscher PM~ Am J Hum Ge~ 2017    "00029297;~ "revie~ N            Y     
 9 27793~ MED    2779~ 10.1~ Psyc~ Sarkar A, L~ Trends Neur~ 2016    "01662236;~ "resea~ Y            Y     
10 28475~ MED    2847~ 10.1~ Meta~ Buck MD, So~ Cell         2017    "00928674;~ "resea~ N            Y     
# ... with 20 more rows, and 17 more variables: inPMC <chr>, hasPDF <chr>, hasBook <chr>,
#   citedByCount <int>, hasReferences <chr>, hasTextMinedTerms <chr>, hasDbCrossReferences <chr>,
#   hasLabsLinks <chr>, hasTMAccessionNumbers <chr>, firstPublicationDate <chr>, pageInfo <chr>,
#   pmcid <chr>, issue <chr>, journalVolume <chr>, hasSuppl <chr>, ISSN.1 <fct>, ISSN.2 <fct>
>
>
>
> pub_data$combined

# A tibble: 30 x 48
   id     source pmid  doi   title authorString journalTitle pubYear journalIssn pubType isOpenAccess inEPMC
   <chr>  <chr>  <chr> <chr> <chr> <chr>        <chr>        <chr>   <chr>       <chr>   <chr>        <chr> 
 1 25815~ MED    2581~ 10.1~ Prom~ Fontana L, ~ Cell         2015    "00928674;~ "resea~ N            Y     
 2 27981~ MED    2798~ 10.1~ The ~ Rea K, Dina~ Neurobiol S~ 2016    23522895    "revie~ Y            Y     
 3 26912~ MED    2691~ 10.1~ Grow~ Luczynski P~ Int J Neuro~ 2016    "14611457;~ "resea~ Y            Y     
 4 27641~ MED    2764~ 10.1~ Gut ~ Dinan TG, C~ J Physiol    2017    "00223751;~ "revie~ N            N     
 5 28242~ MED    2824~ 10.1~ Targ~ Burokas A, ~ Biol Psychi~ 2017    "00063223;~ journa~ N            N     
 6 27090~ MED    2709~ 10.1~ From~ Rogers GB, ~ Mol Psychia~ 2016    "13594184;~ "revie~ Y            Y     
 7 28186~ MED    2818~ 10.1~ The ~ Simon DW, M~ Nat Rev Neu~ 2017    "17594758;~ "resea~ N            Y     
 8 28686~ MED    2868~ 10.1~ 10 Y~ Visscher PM~ Am J Hum Ge~ 2017    "00029297;~ "revie~ N            Y     
 9 27793~ MED    2779~ 10.1~ Psyc~ Sarkar A, L~ Trends Neur~ 2016    "01662236;~ "resea~ Y            Y     
10 28475~ MED    2847~ 10.1~ Meta~ Buck MD, So~ Cell         2017    "00928674;~ "resea~ N            Y     
# ... with 20 more rows, and 36 more variables: inPMC <chr>, hasPDF <chr>, hasBook <chr>,
#   citedByCount <int>, hasReferences <chr>, hasTextMinedTerms <chr>, hasDbCrossReferences <chr>,
#   hasLabsLinks <chr>, hasTMAccessionNumbers <chr>, firstPublicationDate <chr>, pageInfo <chr>,
#   pmcid <chr>, issue <chr>, journalVolume <chr>, hasSuppl <chr>, ISSN.1 <chr>, ISSN.2.x <fct>, Rank <int>,
#   Title <fct>, Type <fct>, SJR <dbl>, SJR.Best.Quartile <fct>, H.index <int>, Total.Docs...2016. <int>,
#   Total.Docs...3years. <int>, Total.Refs. <int>, Total.Cites..3years. <int>, Citable.Docs...3years. <int>,
#   Cites...Doc...2years. <dbl>, Ref....Doc. <dbl>, Country <fct>, Categories <fct>, ISSN <chr>,
#   ISSN.2.y <fct>, ISSN.2 <fct>, ISSN.1.y <fct>
```

## Important resources

* [Scimago Journal and Country Rank](https://www.scimagojr.com/aboutus.php)
* [InCities Journal Citation Reports]( http://jcr.incites.thomsonreuters.com/JCRJournalHomeAction.action?wsid=5Aa4jbtfC2lQdEGIwCT&Init=Yes&SrcApp=IC2LS&SID=H6-gdiAea4KogIEbyxx7iUr4obA2S2omDx2BTz-18x2dDOuJZ4XsZ6keA24DqhpckAx3Dx3Dw1c6x2Bx2BP7NHfVnpg6nSkZqAx3Dx3D-9vvmzcndpRgQCGPd1c2qPQx3Dx3D-wx2BJQh9GKVmtdJw3700KssQx3Dx3D)
* [Europe PMC](https://europepmc.org/Help#whatserachingEPMC)