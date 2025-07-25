% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/monitoring.R
\name{kobo}
\alias{kobo}
\title{Import submission data from KoboToolbox}
\usage{
kobo(username, password, form_id, server = "kobotoolbox", output_dir = getwd())
}
\arguments{
\item{username}{Character. Your KoboToolbox username.}

\item{password}{Character. Your KoboToolbox password.}

\item{form_id}{Character. The unique identifier of the KoboToolbox form (asset UID).}

\item{server}{Character. Either "kobotoolbox" (default) or "humanitarian" to specify the server type.}

\item{output_dir}{Character. Directory to which files might be written (reserved for future use). Must exist. Defaults to current working directory.}
}
\value{
A data frame containing the form submission data.
Returns \code{NULL} if no data is available. Stops with an informative
error message if the request fails.
}
\description{
This function connects to the KoboToolbox API and downloads the submission data
of a specified form (identified by its asset UID). It returns the data as a
data frame, with cleaned column names.
}
\details{
Column names are cleaned by:
\itemize{
  \item Removing any prefix up to the last `/`
  \item Removing leading and trailing underscores
  \item Replacing multiple consecutive underscores with a single underscore
  \item Ensuring uniqueness of column names
}
}
\examples{
\dontrun{
df <- kobo(
  username = "my_user",
  password = "my_password",
  form_id = "a1b2c3d4e5f6g7h8i9",
  server = "humanitarian"
)
head(df)
}

}
