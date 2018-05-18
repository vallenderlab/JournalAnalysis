required_cran_packages <- c(
  "ggplot2",
  "readxl",
  "tibble",
  "dplyr",
  "magrittr",
  "extrafont",
  "europepmc",
  "ggthemes"
)

required_bioconductor_packages <- c(
  "BiocParallel"
)

cran_packages_to_install <- required_cran_packages[!(required_cran_packages %in% installed.packages()[, 1])]

bioconductor_packages_to_install <- required_bioconductor_packages[!(required_bioconductor_packages %in% installed.packages()[, 1])]

if (length(cran_packages_to_install) > 0) {
  install.packages(cran_packages_to_install, repos = "https://cran.rstudio.com")
}

if (length(bioconductor_packages_to_install) > 0) {
  source("https://bioconductor.org/biocLite.R")
  biocLite()
  biocLite(bioconductor_packages_to_install)
}