
# Monitoring Package

Monitoring is an R package designed to simplify workflows involving
**Google Drive**, **GitHub**, and **KoboToolbox**. It provides tools to:

- Import CSV/XLSX files from Google Drive or GitHub
- Download XLSForm files from KoboToolbox
- Retrieve and clean KoboToolbox submission data
- Generate Stata `.do` files based on KoboToolbox survey structures

These functions are particularly useful for researchers, field teams,
and analysts working in survey-based and humanitarian data collection
contexts.

## Installation

``` r
# Install this package
library(monitoring)
```

## Available Functions

### 1. `gdrive()`: Import Files from Google Drive

Imports a CSV or Excel file from Google Drive using either the file name
or a shared URL.

#### Arguments:

- `file_name`: *(optional)* Exact name of the file on Google Drive
- `file_url`: *(optional)* Shared Google Drive URL
- `file_type`: `"csv"` or `"xlsx"`
- `sheet`: *(optional)* Sheet name for Excel files

#### Returns:

A `data.frame` containing the file content.

#### Example:

``` r
data1 <- gdrive(file_name = "data.csv", file_type = "csv")

data2 <-  gdrive(
  file_url = "https://drive.google.com/file/d/XYZ/view",
  file_type = "xlsx",
  sheet = "Sheet1"
)
```

### 2. `githb()`: Import Files from GitHub

Downloads a CSV or Excel file directly from a public GitHub repository
using the raw URL.

#### Arguments:

- `github_raw_url`: Direct raw URL to the file (e.g., from
  `raw.githubusercontent.com`)
- `file_type`: `"csv"` or `"xlsx"`
- `sheet`: *(optional)* Excel sheet name (if applicable)

#### Returns:

A `data.frame` with the imported data.

#### Example:

``` r
githb("https://raw.githubusercontent.com/user/repo/main/data.csv", file_type = "csv")

githb(
  "https://raw.githubusercontent.com/user/repo/main/data.xlsx",
  file_type = "xlsx",
  sheet = "Sheet1"
)
```

### 3. `xlsform()`: Download XLSForm from KoboToolbox

Connects to the KoboToolbox API and downloads the XLSForm corresponding
to a form ID.

#### Arguments:

- `username`: Your KoboToolbox username
- `password`: Your KoboToolbox password
- `form_id`: The KoboToolbox form’s asset UID

#### Returns:

A string: the local file path of the downloaded `.xls` file.

#### Example:

``` r
xlsform(
  username = "your_username",
  password = "your_password",
  form_id = "a1b2c3d4e5f6g7h8i9"
)
```

### 4. `kobo()`: Import KoboToolbox Submission Data

Downloads and processes KoboToolbox form submission data.

#### Arguments:

- `username`: Your KoboToolbox username
- `password`: Your KoboToolbox password
- `form_id`: KoboToolbox form ID (asset UID)
- `server`: `"kobotoolbox"` *(default)* or `"humanitarian"`
- `output_dir`: *(reserved for future use)* Must be a valid directory

#### Returns:

A cleaned `data.frame` or `NULL` if no data is available.

#### Column cleaning rules:

- Removes prefixes before the last `/`
- Trims leading/trailing underscores
- Replaces repeated underscores with single `_`
- Ensures column name uniqueness

#### Example:

``` r
df <- kobo(
  username = "my_user",
  password = "my_password",
  form_id = "a1b2c3d4e5f6g7h8i9",
  server = "humanitarian"
)
```

### 5. `statalab()`: Generate Stata `.do` File

Creates a `.do` script to automate Stata import and labeling based on a
KoboToolbox XLSForm and exported dataset.

#### Arguments:

- `data_path`: Path to the Excel data export
- `xlsform_path`: Path to the corresponding XLSForm (optional)
- `output_path`: Output file path (default: `"statalab.do"`)

#### Returns:

No R object is returned; writes a `.do` file to disk.

#### Example:

``` r
statalab(
  data_path = "data.xlsx",
  xlsform_path = "questionnaire.xlsx",
  output_path = "prepare_data.do"
)
```

## License

MIT License © \[Julien BIDIAS, Jean MOYENGA\] See `LICENSE` file for
details.

## Support

For bugs, issues, or suggestions, open an issue on the GitHub
repository: <https://github.com/yourusername/MyPackage/issues>
