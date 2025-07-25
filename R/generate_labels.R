#' Generate a Stata .do file to prepare a dataset exported from KoboToolbox
#'
#' This function creates a Stata `.do` file that automates the import of an Excel file,
#' variable renaming, adding variable labels, defining value labels (`label define`),
#' and applying those labels to variables (`label values`) using an exported dataset
#' and an associated XLSForm.
#'
#' @param data_path Path to the Excel file containing the exported data (typically from KoboToolbox).
#' @param xlsform_path Path to the XLSForm file used to generate the survey (optional).
#' @param output_path Path to save the generated `.do` file (default: `"statalab.do"`).
#'
#' @return No R object is returned. The function writes a `.do` Stata file to disk.
#'
#' @examples
#' \dontrun{
#' statalab(
#'   data_path = "data.xlsx",
#'   xlsform_path = "questionnaire.xlsx",
#'   output_path = "prepare_data.do"
#' )
#' }
#'
#' @export
#'
#' @importFrom readxl read_excel
#' @importFrom stringr str_trim
#' @importFrom dplyr filter pull mutate
statalab <- function(data_path, xlsform_path = NULL, output_path = "statalab.do") {

  data <- readxl::read_excel(data_path)
  old_names <- colnames(data)
  new_names <- paste0("var", seq_along(old_names))

  do_lines <- c()

  import_line <- sprintf('import excel "%s", sheet("Sheet 1") firstrow clear',
                         normalizePath(data_path, winslash = "\\", mustWork = FALSE))
  do_lines <- c(do_lines, import_line, "")

  rename_lines <- sprintf("rename %s %s", old_names, new_names)
  do_lines <- c(do_lines, "* Rename variables", rename_lines, "")

  label_lines <- sprintf("label variable %s \"%s\"", new_names, old_names)
  do_lines <- c(do_lines, "* Assign variable labels", label_lines, "")

  label_define_lines <- c()
  label_values_lines <- c()

  if (!is.null(xlsform_path)) {
    survey <- readxl::read_excel(xlsform_path, sheet = "survey")
    choices <- readxl::read_excel(xlsform_path, sheet = "choices")

    colnames(survey) <- tolower(trimws(colnames(survey)))
    colnames(choices) <- tolower(trimws(colnames(choices)))

    if (!all(c("type", "name") %in% names(survey)) ||
        !all(c("list_name", "name", "label") %in% names(choices))) {
      stop("The XLSForm is missing required columns in 'survey' or 'choices' sheets.")
    }

    survey <- dplyr::mutate(
      survey,
      type = stringr::str_trim(type),
      list_name = ifelse(grepl("^select_(one|multiple)\\s+", type),
                         gsub("^select_(one|multiple)\\s+", "", type),
                         NA)
    )

    for (i in seq_along(old_names)) {
      old_var <- old_names[i]
      new_var <- new_names[i]

      list_id <- survey %>%
        dplyr::filter(name == old_var) %>%
        dplyr::pull(list_name) %>%
        unique()

      if (length(list_id) == 1 && !is.na(list_id)) {
        subset_choices <- dplyr::filter(choices, list_name == list_id)

        if (nrow(subset_choices) > 0) {
          label_name <- paste0(old_var, "_lab")
          define_line <- sprintf("label define %s %s",
                                 label_name,
                                 paste0(subset_choices$name, ' "', subset_choices$label, '"', collapse = " "))
          value_line <- sprintf("label values %s %s", new_var, label_name)

          label_define_lines <- c(label_define_lines, define_line)
          label_values_lines <- c(label_values_lines, value_line)
        }
      }
    }

    if (length(label_define_lines) > 0) {
      do_lines <- c(do_lines, "* Define value labels", label_define_lines, "")
    }

    if (length(label_values_lines) > 0) {
      do_lines <- c(do_lines, "* Apply value labels to variables", label_values_lines, "")
    }
  }

  # Write the .do file with UTF-8 encoding to avoid encoding issues
  con <- file(output_path, open = "w", encoding = "UTF-8")
  writeLines(iconv(do_lines, to = "UTF-8"), con = output_path, useBytes = FALSE)
  close(con)

  message("Stata .do file successfully created at: ", output_path)
}

utils::globalVariables(c("type", "name", "list_name"))
