#' Download XLSForm from KoboToolbox
#'
#' This function connects to the KoboToolbox API to download the XLSForm file
#' associated with a given form ID (asset UID). The file is saved locally with
#' the form ID as the filename and `.xls` extension.
#'
#' @param username Character. Your KoboToolbox username.
#' @param password Character. Your KoboToolbox password.
#' @param form_id Character. The unique identifier of the KoboToolbox form (asset UID).
#'
#' @return A character string representing the path to the downloaded XLSForm file.
#' The function stops with an informative error message if the download fails.
#'
#' @details
#' The function constructs the URL for the XLSForm export and performs an authenticated GET request.
#' The XLSForm is saved with the form ID as the filename, overwriting any existing file with the same name.
#'
#' @importFrom httr GET authenticate status_code write_disk progress http_status
#' @examples
#' \dontrun{
#' # Download XLSForm using valid KoboToolbox credentials and form ID
#' file_path <- xlsform(
#'   username = "your_username",
#'   password = "your_password",
#'   form_id = "a1b2c3d4e5f6g7h8i9"
#' )
#' print(file_path)
#' }
#'
#' @export
xlsform <- function(username, password, form_id) {
  # Check if username, password, or form_id is missing
  if (missing(username) || missing(password) || missing(form_id)) {
    # Stop and show error if any required parameter is missing
    stop("Parameters username, password, and form_id are required")
  }

  # Check if username, password, and form_id are character strings
  if (!is.character(username) || !is.character(password) || !is.character(form_id)) {
    # Stop and show error if any parameter is not a character string
    stop("All parameters must be of type character")
  }

  # Check if username, password, or form_id is an empty string
  if (nchar(username) == 0 || nchar(password) == 0 || nchar(form_id) == 0) {
    # Stop and show error if any parameter is empty
    stop("None of the parameters can be an empty string")
  }

  # Build the direct URL to the XLSForm including the .xls suffix in form_id
  url <- paste0("https://kf.kobotoolbox.org/api/v2/assets/", form_id, ".xls")

  # Define the output filename with .xls extension
  output_file <- paste0(form_id, ".xlsx")

  # Try to execute the GET request to download the XLSForm
  tryCatch({
    # Send GET request with authentication and save the file, allowing overwrite
    response <- httr::GET(
      url,
      httr::authenticate(username, password),
      httr::write_disk(output_file, overwrite = TRUE),
      httr::progress()
    )

    # Check if the HTTP status code is 200 (OK)
    if (httr::status_code(response) == 200) {
      # Inform the user that the XLSForm was downloaded successfully
      message("XLSForm successfully downloaded: ", output_file)
      # Return the filename of the downloaded XLSForm
      return(output_file)
    } else {
      # If HTTP status is not 200, stop with an error message showing status and message
      stop(paste("HTTP error:", httr::status_code(response), "-",
                 httr::http_status(response)$message))
    }
  }, error = function(e) {
    # Catch any error during download and stop with the error message
    stop(paste("Error while downloading the XLSForm:", e$message))
  })
}
