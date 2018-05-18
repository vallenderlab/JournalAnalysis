required_cran_packages <- c(
  "europepmc",
  "dplyr",
  "tibble",
  "magrittr",
  "stringr",
  "readxl",
  "ggplot2",
  "ggthemes"
)
required_bioconductor_packages <- c(
  "BiocParallel"
)
required_github_packages <- c()


# Install needed packages --------------------------------------------------------------------
# Create a list of packages to install.
cran_packages_to_install <- required_cran_packages[!(required_cran_packages %in% installed.packages()[, 1])]
bioconductor_packages_to_install <- required_bioconductor_packages[!(required_bioconductor_packages %in% installed.packages()[, 1])]
github_packages_to_install <- required_github_packages[!(gsub(".*/", "", required_github_packages) %in% installed.packages()[, 1])]

# Install packages from lists.
if (length(cran_packages_to_install) > 0) {
  install.packages(cran_packages_to_install, repos = "https://cran.rstudio.com")
}
if (length(bioconductor_packages_to_install) > 0) {
  source("https://bioconductor.org/biocLite.R")
  biocLite(bioconductor_packages_to_install)
}
if (length(github_packages_to_install) > 0) {
  devtools::install_github(github_packages_to_install)
}

# Remove unnecessary environment variables.
remove(required_cran_packages)
remove(required_bioconductor_packages)
remove(required_github_packages)
remove(bioconductor_packages_to_install)
remove(cran_packages_to_install)
remove(github_packages_to_install)