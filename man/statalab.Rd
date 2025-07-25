% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generate_labels.R
\name{statalab}
\alias{statalab}
\title{Generate a Stata .do file to prepare a dataset exported from KoboToolbox}
\usage{
statalab(data_path, xlsform_path = NULL, output_path = "statalab.do")
}
\arguments{
\item{data_path}{Path to the Excel file containing the exported data (typically from KoboToolbox).}

\item{xlsform_path}{Path to the XLSForm file used to generate the survey (optional).}

\item{output_path}{Path to save the generated `.do` file (default: `"statalab.do"`).}
}
\value{
No R object is returned. The function writes a `.do` Stata file to disk.
}
\description{
This function creates a Stata `.do` file that automates the import of an Excel file,
variable renaming, adding variable labels, defining value labels (`label define`),
and applying those labels to variables (`label values`) using an exported dataset
and an associated XLSForm.
}
\examples{
\dontrun{
statalab(
  data_path = "data.xlsx",
  xlsform_path = "questionnaire.xlsx",
  output_path = "prepare_data.do"
)
}

}
