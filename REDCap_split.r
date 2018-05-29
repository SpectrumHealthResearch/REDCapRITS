#' Split REDCap repeating instruments table into multiple tables
#'
#' This will take a raw \code{data.frame} from REDCap and split it into a base table
#' and give individual tables for each repeating instrument. Metadata
#' is used to determine which fields should be included in each resultant table.
#'
#' @param records \code{data.frame} containing project records
#' @param metadata \code{data.frame} containing project metadata (the data dictionary)
#' @author Paul W. Egeler, M.S., GStat
#' @examples
#' \dontrun{
#' library(jsonlite)
#' library(RCurl)
#'
#' # Get the metadata
#' result.meta <- postForm(
#'     api_url,
#'     token = api_token,
#'     content = 'metadata',
#'     format = 'json'
#' )
#'
#' # Get the records
#' result.record <- postForm(
#'     uri = api_url,
#'     token = api_token,
#'     content = 'record',
#'     format = 'json',
#'     type = 'flat',
#'     rawOrLabel = 'raw',
#'     rawOrLabelHeaders = 'raw',
#'     exportCheckboxLabel = 'false',
#'     exportSurveyFields = 'false',
#'     exportDataAccessGroups = 'false',
#'     returnFormat = 'json'
#' )
#'
#' # Convert JSON to data.frames
#' records <- fromJSON(result.record)
#' metadata <- fromJSON(result.meta)
#'
#' # Split the data.frame into a list of data.frames
#' REDCap_split(records, metadata)
#' }
#' @return a list of data.frames
#' @export
REDCap_split <- function(records, metadata) {

  stopifnot(all(sapply(list(records,metadata), inherits, "data.frame")))

  # Check to see if there were any repeating instruments

  if (!any(names(records) == "redcap_repeat_instrument")) {

    message("There are no repeating instruments in this data.")

    return(list(records))

  }

  # Clean the metadata
  metadata <-
    metadata[metadata$field_type != "descriptive", c("field_name", "form_name")]

  # Identify the subtables in the data
  subtables <- unique(records$redcap_repeat_instrument)
  subtables <- subtables[subtables != ""]

  # Split the table based on instrument
  out <- split.data.frame(records, records$redcap_repeat_instrument)

  # Delete the variables that are not relevant
  for (i in names(out)) {

    if (i == "") {

      out[[which(names(out) == "")]] <-
        out[[which(names(out) == "")]][metadata[!metadata[,2] %in% subtables, 1]]

    } else {

      out[[i]] <-
        out[[i]][c(names(records[1:3]),metadata[metadata[,2] == i, 1])]

    }

  }

  return(out)

}
