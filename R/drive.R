#' Import a CSV or Excel file from Google Drive (by name or URL)
#'
#' This function allows importing a file from Google Drive using either its exact name or a shared URL.
#'
#' @param file_name Exact name of the file on Google Drive (optional if `file_url` is provided)
#' @param file_url Shared Google Drive URL (optional if `file_name` is provided)
#' @param file_type File type: either "csv" or "xlsx"
#' @param sheet Excel sheet name to read (optional, only used for .xlsx files)
#'
#' @return A `data.frame` containing the imported data
#' @export
#'
#' @import googledrive
#' @import readr
#' @import readxl
#'
#' @examples
#' \dontrun{
#'   gdrive(file_name = "data.csv", file_type = "csv")
#'   gdrive(
#'     file_url = "https://drive.google.com/file/d/XYZ/view",
#'     file_type = "xlsx",
#'     sheet = "Sheet1"
#'   )
#' }
gdrive <- function(file_name = NULL, file_url = NULL, file_type = c("csv", "xlsx"), sheet = NULL) {
  file_type <- match.arg(file_type)

  if (is.null(file_name) && is.null(file_url)) {
    stop("You must provide either 'file_name' or 'file_url'.")
  }

  googledrive::drive_auth()

  if (!is.null(file_url)) {
    # Extract file ID from URL
    file_id <- googledrive::as_id(file_url)
  } else {
    file <- googledrive::drive_get(file_name)
    if (nrow(file) == 0) stop("File not found on Google Drive.")
    file_id <- file$id
  }

  temp_file <- tempfile(fileext = paste0(".", file_type))
  googledrive::drive_download(file_id, path = temp_file, overwrite = TRUE)

  if (file_type == "csv") {
    data <- readr::read_csv(temp_file)
  } else {
    data <- readxl::read_excel(temp_file, sheet = sheet)
  }

  return(data)
}
