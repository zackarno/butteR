#' Remove group names from XLSForm survey sheet name column
#' 
#' Works to remove group names added from the `add_group_to_xlsform_name` function to return the original survey sheet.
#' 
#' @param survey XLSForm survey sheet
#' @param sep Separator for groups from name of question, either `.` or `/`
#' 
#' @return XLSForm survey sheet with original name column
#' 
#' @export
remove_groups_from_xlsform_names <- function(survey, sep = ".") {
  # Checking values for survey and sep
  sep <- match.arg(sep, c(".", "/"))
  assertthat::assert_that(all(c("name", "type") %in% names(survey)), msg = "XLSForm survey sheet lacks at least one of name or type columns")
  
  # Ensuring no empty rows
  survey <- survey[!is.na(survey$type),]
  
  # Determining groups for each row
  survey$groups <- NA
  survey$name2 <- survey$name
  group <- c()
  group_label <- ""
  for (i in 1:nrow(survey)) {
    if (stringr::str_detect(survey$type[i], "begin group|begin_group")) {
      group <- c(group, survey$name[i])
      group_label <- paste(group, collapse = sep)
    } 
    survey$groups[i] <- group_label
    if (survey$groups[i] != "") {
      survey$name2[i] <- str_remove(survey$name2[i], paste0("^", survey$groups[i], sep))
    }
    if (stringr::str_detect(survey$type[i], "end group|end_group")) {
      group <- group[-length(group)]
      group_label <- paste(group, collapse = sep)
    }
  }
  
  # Returning survey sheet exactly as it was, except the name column has groups
  # Ensure that end_group and begin_group rows return original name
  survey$name <- ifelse(stringr::str_detect(survey$type, "begin group|begin_group|end group|end_group"),
                                            survey$name,
                                            survey$name2)
  return(survey[, !(names(survey) %in% c("groups", "name2"))])
}