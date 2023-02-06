#' Create a simple form field schema
#' 
#' This is the function to create a basic offline form field schema. It is 
#' recommended to use the specific functions for each schema type such as 
#' textFieldSchema() or serialNumberFieldSchema().
#'
#' @param type The type character string defining the form field type.
#' @param label The label of the form field
#' @param description The description of the form field
#' @param code The code name of the form field
#' @param id The id of the form Field; default is to generate a new cuid
#' @param key Whether the form field is a key field; default is FALSE
#' @param required Whether the form field is required; default is FALSE
#' @param hideFromEntry Whether the form field is hidden during data entry; default is FALSE
#' @param hideInTable Whether the form field is hidden during data display; default is FALSE
#' @param relevanceRules Relevance rules for the form field given as a character string; default is ""
#' @param validationRules Validation rules for the form field given as a character string; default is ""
#' @param reviewerOnly Whether the form field is for reviewers only; default is FALSE
#' @param typeParameters The type parameters object specific to the type given.
#'
#' @export
formFieldSchema <- function(type, label, description = NULL, code = NULL, id = cuid(), key = FALSE, required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE, typeParameters = NULL) {
  stopifnot("The label is required to be a character string" = (is.character(label)&&length(label)==1&&nchar(label)>0))
  stopifnot("The description must be a character string" = is.null(description)||(is.character(description)&&length(description)==1&&nchar(description)>0))
  stopifnot("The code must be a character string" = is.null(code)||(is.character(code)&&length(code)==1&&nchar(code)>0))
  stopifnot("The id is required and must be a character string" = !is.null(id)&&(is.character(id)&&length(id)==1&&nchar(id)>0))
  stopifnot("`relevanceRules` must be given as a character string" = !is.null(relevanceRules)&&(is.character(relevanceRules)&&length(relevanceRules)==1))
  stopifnot("`validationRules` must be given as a character string" = !is.null(validationRules)&&(is.character(validationRules)&&length(validationRules)==1))
  stopifnot("The key must be a logical/boolean of length 1" = is.logical(key)&&length(key)==1)
  stopifnot("`required` must be a logical/boolean of length 1" = is.logical(required)&&length(required)==1)
  stopifnot("`hideFromEntry` must be a logical/boolean of length 1" = is.logical(hideFromEntry)&&length(hideFromEntry)==1)
  stopifnot("`hideInTable` must be a logical/boolean of length 1" = is.logical(hideInTable)&&length(hideInTable)==1)
  stopifnot("`reviewerOnly` must be a logical/boolean of length 1" = is.logical(reviewerOnly)&&length(reviewerOnly)==1)
  stopifnot("The type parameters must be a list if defined" = is.null(typeParameters)||is.list(typeParameters))
  
  schema <- list()
  
  schema$id <- id
  
  if (!is.null(code)) {
    schema$code = code
  }
  
  schema$label <- label
  schema$relevanceCondition <- relevanceRules
  schema$validationCondition <- validationRules
  schema$tableVisible <- !hideFromEntry
  schema$required <- required
  
  if (!is.null(description)) {
    schema$description = description
  }
  
  schema$type <- type
  schema$key <- key
  
  schema$typeParameters <- typeParameters
  
  schema <- asFormFieldSchema(schema)
  
  schema
  
}

asFormFieldSchema <- function(e) {
  e$key <- identical(e$key, TRUE)
  e$required <- identical(e$required, TRUE)
  e$tableVisible <- !identical(e$tableVisible, FALSE)
  if(is.null(e$code)) {
    e["code"] <- list(NULL)
  }
  if(is.null(e$description)) {
    e["description"] <- list(NULL)
  }
  class(e) <- c("activityInfoFormFieldSchema", "formField", class(e))
  
  e <- addFormFieldSchemaCustomClass(e)
  e
}

addFormFieldSchemaCustomClass <- function(e) {
  if (e$type == "FREE_TEXT") {
    if (e$typeParameters$barcode) {
      class(e) <- c("activityInfoBarcodeFieldSchema", class(e))
    } else {
      class(e) <- c("activityInfoTextFieldSchema", class(e))
    }
  } else if (e$type == "serial") {
    class(e) <- c("activityInfoSerialNumberFieldSchema", class(e))
  } else if (e$type == "quantity") {
    class(e) <- c("activityInfoQuantityFieldSchema", class(e))
  } else if (e$type == "NARRATIVE") {
    class(e) <- c("activityInfoMultilineFieldSchema", class(e))
  } else if (e$type == "date") {
    class(e) <- c("activityInfoDateFieldSchema", class(e))
  } else if (e$type == "epiweek") {
    class(e) <- c("activityInfoWeekFieldSchema", class(e))
  } else if (e$type == "fortnight") {
    class(e) <- c("activityInfoFortnightFieldSchema", class(e))
  } else if (e$type == "month") {
    class(e) <- c("activityInfoMonthFieldSchema", class(e))
  } else if (e$type == "enumerated") {
    if (e$typeParameters$cardinality == "single") {
      class(e) <- c("activityInfoSingleSelectFieldSchema", class(e))
    } else if (e$typeParameters$cardinality == "multiple") {
      class(e) <- c("activityInfoMultipleSelectFieldSchema", class(e))
    }
  } else if (e$type == "attachment") {
    class(e) <- c("activityInfoAttachmentFieldSchema", class(e))
  } else if (e$type == "calculated") {
    class(e) <- c("activityInfoCalculatedFieldSchema", class(e))
  } else if (e$type == "attachment") {
    class(e) <- c("activityInfoAttachmentFieldSchema", class(e))
  } else if (e$type == "subform") {
    class(e) <- c("activityInfoSubformFieldSchema", class(e))
  } else if (e$type == "geopoint") {
    class(e) <- c("activityInfoGeopointFieldSchema", class(e))
  } else if (e$type == "reference") {
    if (grepl("@user$", e$typeParameters$range[[1]]$formId)) {
      class(e) <- c("activityInfoUserFieldSchema", class(e))
    } else {
      class(e) <- c("activityInfoReferenceFieldSchema", class(e))
    }
  } else if (e$type == "section") {
    class(e) <- c("activityInfoSectionFieldSchema", class(e))
  }
  return(e)
}

#' Pretty print a form field schema
#'
#' @param x an object of class \code{activityInfoFormFieldSchema}.
#' @param ... ignored
#'
#' @export
print.activityInfoFormFieldSchema <- function(x, ...) {
  cat(sprintf("%s (%s)\n", class(x)[1], x$type))
  cat(sprintf("    %s: %s\n", x$id, x$label))
  
  xNames <- names(x)
  
  for(nm in xNames) {
    if(nm == "typeParameters") {
      tNames <- names(x[[nm]])
      cat("      Type parameters: \n")
      for (nm2 in tNames) {
        cat(sprintf("        %s: %s\n", nm2, x[[nm]][nm2]))
      }
    } else {
      cat(sprintf("      %s: %s\n", nm, x[nm]))
    }
  }
  
  
  # attrs <- c(
  #   if (x$key) "Key" else NULL,
  #   if (x$required) "Required" else NULL
  # )
  # 
  # if (length(attrs)) {
  #   cat(sprintf("      %s\n", paste(attrs, collapse = ", ")))
  # }
  # 
  # if (is.character(x$description)) {
  #   cat(sprintf("      description: %s\n", x$description))
  # }
  # 
}

formFieldArgsList <- names(formals(formFieldSchema))

formFieldArgs <- function(x) {
  x[(names(x) %in% formFieldArgsList)]
}

#' Create a text form field schema
#' 
#' You can define the format of the text that the users should type in a Text 
#' field using an Input Mask. 
#' See: https://www.activityinfo.org/support/docs/m/93526/l/1143998.html
#' 
#' @inheritParams formFieldSchema
#'
#' @export
textFieldSchema <- function(label, description = NULL, code = NULL, id = cuid(), key = FALSE, required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "FREE_TEXT"),
      formFieldArgs(as.list(environment())),
      list(
        typeParameters = list("barcode" = FALSE)
        )
      )
  )
  
  schema
}

#' Create a barcode form field schema
#'
#' @inheritParams formFieldSchema
#'
#' @export
barcodeFieldSchema <- function(label, description = NULL, code = NULL, id = cuid(), key = FALSE, required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "FREE_TEXT"),
      formFieldArgs(as.list(environment())),
      list(
        typeParameters = list("barcode" = TRUE)
      )
    )
  )
  
  schema
}

#' Create a serial number form field schema
#' 
#' Only one serial number field is possible in a form. The Prefix Formula is 
#' available for Serial Number fields and can be used to customise how the 
#' Serial Number will appear. In Subforms, the Prefix Formula can also derive 
#' from the Parent Form.
#' 
#' @param digits The number of digits in the serial number
#' @param prefixFormula A formula as a character string defining the prefix for 
#' the serial number
#' @inheritParams formFieldSchema
#'
#' @export
serialNumberFieldSchema <- function(label, description = NULL, digits = 5, prefixFormula = NULL, code = NULL, id = cuid(), key = FALSE, required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  stopifnot("The prefix formula must be NULL or a character string" = is.null(prefixFormula)||(is.character(prefixFormula)&&length(prefixFormula)==1&&nchar(prefixFormula)>0))
  stopifnot("The digits must be an integer" = is.numeric(digits)&&as.integer(digits)==digits)
  
  typeParameters <- list(digits = digits)
  typeParameters$prefixFormula = prefixFormula

  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "serial"),
      formFieldArgs(as.list(environment()))
    )
  )
  
  schema
}

#' Create a quantity form field schema
#' 
#' A Quantity field allow users to enter a numerical value. You can define the 
#' units and the aggregation function.
#' 
#' A quantity field cannot be a key field.
#' 
#' @inheritParams formFieldSchema
#' @param units A character string describing the units, e.g. "litres per day"
#' @param aggregation A character string giving the aggregation function; "SUM" 
#' is default
#'
#' @export
quantityFieldSchema <- function(label, description = NULL, units = "", aggregation = "SUM", code = NULL, id = cuid(), required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  stopifnot("Units must be a character string (empty or not)" = is.character(units)&&length(units)==1)
  stopifnot("Aggregation must be a character string" = is.character(aggregation)&&length(aggregation)==1)
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "quantity"),
      formFieldArgs(as.list(environment())),
      list(
        typeParameters = list(
          "units" = units,
          "aggregation" = aggregation
          )
      )
    )
  )
  
  schema
}

#' Create a multi-line or narrative form field schema
#' 
#' Multi-Line Text fields can be used to collect long answers to open-ended 
#' questions. They could be used for example to collect Comments about a 
#' specific Form or an Extended Narrative. It cannot be a key field.
#' 
#' @inheritParams formFieldSchema
#'
#' @export
multilineFieldSchema <- function(label, description = NULL, code = NULL, id = cuid(), required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "NARRATIVE"),
      as.list(environment())
    )
  )
  
  schema
}

#' Create a date form field schema
#' 
#' The Date format in ActivityInfo is YYYY-MM-DD so no matter the way the Date 
#' is typed by a user it will always appear in this format.
#' 
#' @inheritParams formFieldSchema
#'
#' @export
dateFieldSchema <- function(label, description = NULL, code = NULL, id = cuid(), key = FALSE, required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "date"),
      as.list(environment())
    )
  )
  
  schema
}

#' Create a week form field schema
#' 
#' The Week format in ActivityInfo is YYYY-WW. Users can directly type using 
#' this format or use the calendar to select a week. Please note that the Week 
#' field uses the EPI week convention.
#' 
#' @inheritParams formFieldSchema
#'
#' @export
weekFieldSchema <- function(label, description = NULL, code = NULL, id = cuid(), key = FALSE, required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "epiweek"),
      as.list(environment())
    )
  )
  
  schema
}

#' Create a fortnight form field schema
#' 
#' The Fortnight field format in ActivityInfo is YYYYWW-WW (e.g. 2020W3-W4). 
#' Users can directly type using this format or use the calendar to select a 
#' week.
#' 
#' @inheritParams formFieldSchema
#'
#' @export
fortnightFieldSchema <- function(label, description = NULL, code = NULL, id = cuid(), key = FALSE, required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "fortnight"),
      as.list(environment())
    )
  )
  
  schema
}

#' Create a month form field schema
#' 
#' The Month format in ActivityInfo is YYYY-MM.
#' 
#' @inheritParams formFieldSchema
#'
#' @export
monthFieldSchema <- function(label, description = NULL, code = NULL, id = cuid(), key = FALSE, required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "month"),
      as.list(environment())
    )
  )
  
  schema
}

selectFieldSchema <- function(cardinality, label, description = NULL, values = list(), presentation = "automatic", code = NULL, id = cuid(), key = FALSE, required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  stopifnot("Presentation must be a character string" = is.character(presentation)&&length(presentation)==1)
  stopifnot("Cardinality must be a character string 'single' or 'multiple'" = is.character(cardinality)&&length(cardinality)==1&&(cardinality %in% c("single", "multiple")))
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "enumerated"),
      formFieldArgs(as.list(environment())),
      list(
        typeParameters = list(
          "cardinality" = cardinality,
          "presentation" = presentation,
          "values" = values
        )
      )
    )
  )
  
  schema
}

#' Create a Single Select form field schema
#' 
#' There is an options parameter for the list of single select items. Single 
#' Selection fields can be used to ask from users to select one out of two or 
#' more options as an answer. This can be a "Yes" or "No" question for example 
#' or any other type of question that can be answered with one option. Single 
#' Selection fields can be used in Prefix Formulas to customize Serial Numbers 
#' too.
#' 
#' @inheritParams formFieldSchema
#' @param values A list of the single select field values
#' @param presentation Default is "automatic"
#'
#' @export
singleSelectFieldSchema <- function(label, description = NULL, values = list(), presentation = "automatic", code = NULL, id = cuid(), key = FALSE, required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  schema <- do.call(
    selectFieldSchema, 
    args = c(
      list(cardinality = "single"),
      as.list(environment())
    )
  )
}

#' Create a Multiple Select form field schema
#' 
#' There is an options parameter for the list of multiple select items. Multiple 
#' Selection fields can be used to ask from users to select any number of 
#' options as an answer.
#' 
#' @inheritParams formFieldSchema
#' @param values A list of the multiple select field values
#' @param presentation Default is "automatic"
#'
#' @export
multipleSelectFieldSchema <- function(label, description = NULL, values = list(), presentation = "automatic", code = NULL, id = cuid(), key = FALSE, required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  schema <- do.call(
    selectFieldSchema, 
    args = c(
      list(cardinality = "multiple"),
      as.list(environment())
    )
  )
}

#' Converts a factor, list or vector to select values
#' 
#' Creates a list of values in the ActivityInfo format for Single Select or
#' Multiple Select form fields.
#' 
#' @rdname toSelectValues
#' @param values The values to convert
#'
#' @export
toSelectValues <- function(values) {
  UseMethod("toSelectValues")
}


#' @rdname toSelectValues
#' @export
toSelectValues.character <- function(values) {
  lapply(
    values,
    function(x) {
      list(
        id = cuid(), 
        label = x)
      })
}

#' @rdname toSelectValues
#' @export
toSelectValues.default <- toSelectValues.character


#' @rdname toSelectValues
#' @export
toSelectValues.list <- function(values) {
  values <- as.character(values)
  toSelectValues.character(values)
}

#' @rdname toSelectValues
#' @export
toSelectValues.factor <- function(values) {
  toSelectValues.character(levels(values))
}

#' Create an attachments form field schema
#' 
#' An attachments field allow users to add one or more attachments.
#' 
#' An attachments field cannot be a key field.
#' 
#' @inheritParams formFieldSchema
#'
#' @export
attachmentsFieldSchema <- function(label, description = NULL, code = NULL, id = cuid(), required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "attachment"),
      formFieldArgs(as.list(environment())),
      list(
        typeParameters = list(
          "cardinality" = "multiple",
          "kind" = "attachment"
        )
      )
    )
  )
  
  schema
}


#' Create a calculated field schema
#' 
#' A calculated field can be used to define a formula that presents calculation 
#' results in the form.
#' 
#' A calculated field cannot be a key field.
#' 
#' @inheritParams formFieldSchema
#' @param formula A character string with the calculation formula
#'
#' @export
calculatedFieldSchema <- function(label, description = NULL, formula, code = NULL, id = cuid(), hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  stopifnot("Formula must be a character string" = is.character(formula)&&length(formula)==1&&nchar(formula)>0)
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "calculated"),
      formFieldArgs(as.list(environment())),
      list(
        typeParameters = list(
          "formula" = formula
        )
      )
    )
  )
  
  schema
}

#' Create a Subform field schema
#' 
#' A subform field can be used to define a field that contains a subform.
#' 
#' A subform field cannot be a key field.
#' 
#' @inheritParams formFieldSchema
#' @param subformId The id of the sub-form
#'
#' @export
subformFieldSchema <- function(label, description = NULL, subformId, code = NULL, id = cuid(), hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  stopifnot("The subform id must be a character string" = is.character(subformId)&&length(subformId)==1&&nchar(subformId)>0)
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "subform"),
      formFieldArgs(as.list(environment())),
      list(
        typeParameters = list(
          "formId" = subformId
        )
      )
    )
  )
  
  schema
}

#' Create a Reference field schema
#' 
#' A reference field can be used to make reference to a record in another form.
#' 
#' @inheritParams formFieldSchema
#' @param formId The id of the referenced form
#'
#' @export
referenceFieldSchema <- function(label, description = NULL, formId, code = NULL, id = cuid(), key = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  stopifnot("The referenced form id must be a character string" = is.character(formId)&&length(formId)==1&&nchar(formId)>0)
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "reference"),
      formFieldArgs(as.list(environment())),
      list(
        typeParameters = list(
          "cardinality" = "single",
          "range" = list(
            list(
              "formId" = formId
              )
          )
        )
      )
    )
  )
  
  schema
}

#' Create a Geographic Point form field schema
#' 
#' A Geographic Point field allow users to enter a geo-location with a certain
#' accuracy.
#' 
#' The user interface as the required geo-location accuracy options:
#' * No minimum accuracy
#' * Medium accuracy (25 m); default
#' * High accuracy (10 m)"
#' 
#' This field cannot be a key field.
#' 
#' @inheritParams formFieldSchema
#' @param requiredAccuracy Minimum required accuracy in metres/meters.
#' @param manualEntryAllowed Whether coordinates may be added manually; default
#' is TRUE
#'
#' @export
geopointFieldSchema <- function(label, description = NULL, requiredAccuracy = NULL, manualEntryAllowed = TRUE, code = NULL, id = cuid(), required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  stopifnot("requiredAccuracy must be a single numeric value or NULL" = is.null(requiredAccuracy)||(is.numeric(requiredAccuracy)&&length(requiredAccuracy)==1))
  stopifnot("manualEntryAllowed must be single logical" = is.logical(manualEntryAllowed)&&length(manualEntryAllowed)==1)
  
  schemaArgs <- c(
      list(type = "geopoint"),
      formFieldArgs(as.list(environment())),
      list(
        typeParameters = list(
          "manualEntryAllowed" = manualEntryAllowed
        )
      )
      )
      
  schemaArgs$typeParameters$requiredAccuracy <- requiredAccuracy
  
  schema <- do.call(
    formFieldSchema, 
    args = schemaArgs
    )
  
  schema
}

#' Create a User form field schema
#' 
#' User fields allow you to select a specific user from a list. It is a field 
#' useful for the Case Management Database template with which you can assign 
#' Cases to specific users. User fields and inactive users: If you are using 
#' the User field in your Form and a user who has added Records to the Form, is 
#' no longer active, instead of deleting that user, create a new Role empty of 
#' permissions and assign it to that user.
#' 
#' 
#' @inheritParams formFieldSchema
#' @param databaseId The database id of the form and users
#'
#' @export
userFieldSchema <- function(label, description = NULL, databaseId, code = NULL, id = cuid(), key = FALSE, required = FALSE, hideFromEntry = FALSE, hideInTable = FALSE, relevanceRules = "", validationRules = "", reviewerOnly = FALSE) {
  stopifnot("`databaseId` must be a character string" = is.character(databaseId)&&length(databaseId)==1&&nchar(databaseId)>0)
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "reference"),
      formFieldArgs(as.list(environment())),
      list(
        typeParameters = list(
          "cardinality" = "single",
          "range" = list(list(
            "formId" = sprintf("%s@users", databaseId)
          ))
        )
      )
    )
  )
  
  schema
}

#' Create a section header form field schema
#' 
#' A special form field to define a section header for the form.
#' 
#' @inheritParams formFieldSchema
#'
#' @export
sectionFieldSchema <- function(label, description = NULL) {
  schema <- do.call(
    formFieldSchema, 
    args = c(
      list(type = "section"),
      as.list(environment())
    )
  )
  
  schema
}

isFormFieldSchema <- function(schema) {
  "activityInfoFormFieldSchema" %in% class(schema)
}

#' Add a new form field
#' 
#' Adds a new form field to an offline form schema or else downloads the form 
#' schema and adds the new form field. Note that the either the upload argument 
#' must be TRUE for the field to be added automatically online or the user will 
#' also need to use updateFormSchema() to upload the changes after they are 
#' completed.
#' 
#' @rdname addFormField
#' @param formId The identifier of the form online
#' @param formSchema The offline schema of the form
#' @param schema The form field schema to be added to the form
#' @param upload Default is FALSE. If TRUE the modified form schema will be uploaded.
#' @param ... ignored
#'
#' @export
addFormField <- function(...) {
  UseMethod("addFormField")
}

#' @rdname addFormField
#' @export
addFormField.character <- function(formId, schema, upload = FALSE, ...) {
  formSchema <- getFormSchema(formId = formId)
  formSchema$elements[[length(formSchema$elements)+1]] <- schema
  if (upload == TRUE) {
    updateFormSchema(formSchema)
  } else {
    formSchema
  }
}

#' @rdname addFormField
#' @export
addFormField.formSchema <- function(formSchema, schema, upload = FALSE, ...) {
  formSchema$elements[[length(formSchema$elements)+1]] <- schema
  if (upload == TRUE) {
    updateFormSchema(formSchema)
  } else {
    formSchema
  }
}

#' @rdname addFormField
#' @export
addFormField.default <- addFormField.character
