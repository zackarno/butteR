#' Add group names to XLSForm survey sheet name column
#' 
#' @param survey XLSForm survey sheet
#' @param sep Separator for groups from name of question, either `.` or `/`
#' 
#' @return XLSForm survey sheet with edited name column
#' 
#' @export
add_groups_to_xlsform_names <- function(survey, sep = ".") {
  # Checking values for survey and sep
  sep <- match.arg(sep, c(".", "/"))
  assertthat::assert_that(all(c("name", "type") %in% names(survey)), msg = "XLSForm survey sheet lacks at least one of name or type columns")
  
  # Ensuring no empty rows
  survey <- survey[!is.na(survey$type),]
  
  # Determining groups for each row
  survey$groups <- NA
  group <- c()
  group_label <- ""
  for (i in 1:nrow(survey)) {
    if (stringr::str_detect(survey$type[i], "begin group|begin_group")) {
      group <- c(group, survey$name[i])
      group_label <- paste(group, collapse = sep)
    } else 
    survey$groups[i] <- group_label
    if (stringr::str_detect(survey$type[i], "end group|end_group")) {
      group <- group[-length(group)]
      group_label <- paste(group, collapse = sep)
    }
  }
  
  # Returning survey sheet exactly as it was, except the name column has groups
  # Ensure that end_group and begin_group rows return original name
  survey$name <- ifelse(stringr::str_detect(survey$type, "begin group|begin_group|end group|end_group"),
                                            survey$name,
                                            paste(survey$groups, survey$name, sep = sep))
  survey$name <- stringr::str_remove(survey$name, paste0("^\\", sep))
  return(survey[, !(names(survey) == "groups")])
}