#' Import submission data from KoboToolbox
#'
#' This function connects to the KoboToolbox API and downloads the submission data
#' of a specified form (identified by its asset UID). It returns the data as a
#' data frame, with cleaned column names.
#'
#' Column names are cleaned by:
#' \itemize{
#'   \item Removing any prefix up to the last `/`
#'   \item Removing leading and trailing underscores
#'   \item Replacing multiple consecutive underscores with a single underscore
#'   \item Ensuring uniqueness of column names
#' }
#'
#' @param username Character. Your KoboToolbox username.
#' @param password Character. Your KoboToolbox password.
#' @param form_id Character. The unique identifier of the KoboToolbox form (asset UID).
#' @param server Character. Either "kobotoolbox" (default) or "humanitarian" to specify the server type.
#' @param output_dir Character. Directory to which files might be written (reserved for future use). Must exist. Defaults to current working directory.
#'
#' @return A data frame containing the form submission data.
#' Returns \code{NULL} if no data is available. Stops with an informative
#' error message if the request fails.
#'
#' @importFrom httr GET authenticate status_code content http_status
#' @importFrom jsonlite fromJSON
#' @importFrom stringr str_replace
#'
#' @examples
#' \dontrun{
#' df <- kobo(
#'   username = "my_user",
#'   password = "my_password",
#'   form_id = "a1b2c3d4e5f6g7h8i9",
#'   server = "humanitarian"
#' )
#' head(df)
#' }
#'
#' @export
kobo <- function(username, password, form_id, server = "kobotoolbox", output_dir = getwd()) {
  if (missing(username) || missing(password) || missing(form_id)) {
    stop("Parameters username, password, and form_id are required")
  }

  if (!is.character(username) || !is.character(password) || !is.character(form_id)) {
    stop("All parameters must be of type character")
  }

  if (!server %in% c("kobotoolbox", "humanitarian")) {
    stop("Parameter 'server' must be either 'kobotoolbox' or 'humanitarian'")
  }

  if (!dir.exists(output_dir)) {
    stop("Specified output_dir does not exist.")
  }

  base_url <- switch(server,
                     kobotoolbox = "https://kf.kobotoolbox.org",
                     humanitarian = "https://kf.hh.kobotoolbox.org")

  data_url <- paste0(base_url, "/api/v2/assets/", form_id, "/data.json?format=json")
  form_url <- paste0(base_url, "/api/v2/assets/", form_id, "/")

  tryCatch({
    data_response <- httr::GET(data_url, httr::authenticate(username, password))
    form_response <- httr::GET(form_url, httr::authenticate(username, password))

    if (httr::status_code(data_response) != 200 || httr::status_code(form_response) != 200) {
      stop("Failed to retrieve data or form structure.")
    }

    json_data <- jsonlite::fromJSON(httr::content(data_response, as = "text", encoding = "UTF-8"), flatten = TRUE)
    json_form <- jsonlite::fromJSON(httr::content(form_response, as = "text", encoding = "UTF-8"), flatten = TRUE)

    if (is.null(json_data$results) || nrow(json_data$results) == 0) {
      message("No data found in the form.")
      return(NULL)
    }

    df <- as.data.frame(json_data$results)

    # Nettoyage des noms de colonnes
    clean_colnames <- function(names) {
      names <- stringr::str_replace(names, ".*/", "")
      names <- gsub("^_+", "", names)
      names <- gsub("_+$", "", names)
      names <- gsub("__+", "_", names)
      return(names)
    }

    colnames(df) <- make.unique(clean_colnames(colnames(df)))

    # Convertir les listes en chaînes
    df[] <- lapply(df, function(x) {
      if (is.list(x)) sapply(x, paste, collapse = ", ") else x
    })

    # Extraire les métadonnées du formulaire
    survey <- json_form$content$survey
    choices <- json_form$content$choices

    # Créer un dictionnaire nom-question
    labels <- setNames(survey$label, clean_colnames(survey$name))
    types <- setNames(survey$type, clean_colnames(survey$name))

    # Traiter les questions à choix multiples
    for (q in names(types)) {
      if (grepl("^select_multiple", types[q])) {
        if (q %in% names(df)) {
          modalities <- strsplit(df[[q]], " ")
          all_choices <- unique(unlist(modalities))

          for (choice in all_choices) {
            new_var <- paste0(q, "_", choice)
            df[[new_var]] <- sapply(modalities, function(x) as.integer(choice %in% x))
            attr(df[[new_var]], "label") <- paste0(labels[q], " - ", choice)
          }

          df[[q]] <- NULL  # On retire la variable originale concaténée
        }
      } else if (q %in% names(df)) {
        attr(df[[q]], "label") <- labels[q]
      }
    }

    # Réorganiser les colonnes selon l’ordre du formulaire
    field_order <- clean_colnames(survey$name)
    extra_fields <- setdiff(names(df), field_order)
    df <- df[, c(intersect(field_order, names(df)), extra_fields)]

    message("Data successfully retrieved. Number of records: ", nrow(df))
    return(df)

  }, error = function(e) {
    stop(paste("Error while retrieving data:", e$message))
  })
}
