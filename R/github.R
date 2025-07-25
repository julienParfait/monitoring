#' Import a CSV or Excel file from GitHub
#'
#' This function allows importing a CSV or Excel file from a GitHub repository, using the raw file URL.
#'
#' @param github_raw_url The direct "raw" URL to the file in the GitHub repository
#' @param file_type File type: either "csv" or "xlsx"
#' @param sheet Excel sheet name to read (optional, only for .xlsx files)
#'
#' @return A `data.frame` containing the imported data
#' @export
#' @importFrom utils download.file
#' @import readr
#' @import readxl
#'
#' @examples
#' \dontrun{
#'   githb(
#'     "https://raw.githubusercontent.com/user/repo/branch/data.csv",
#'     file_type = "csv"
#'   )
#'   githb(
#'     "https://raw.githubusercontent.com/user/repo/branch/data.xlsx",
#'     file_type = "xlsx",
#'     sheet = "Sheet1"
#'   )
#' }
githb <- function(github_raw_url, file_type = c("csv", "xlsx"), sheet = NULL) {
  file_type <- match.arg(file_type)

  temp_file <- tempfile(fileext = paste0(".", file_type))
  download.file(github_raw_url, destfile = temp_file, mode = "wb")

  if (file_type == "csv") {
    data <- readr::read_csv(temp_file)
  } else {
    data <- readxl::read_excel(temp_file, sheet = sheet)
  }

  return(data)
}
