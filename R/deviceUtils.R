# Utility functions that have nowhere else to live at the moment.
# These functions are used by the device subroutines.

getDocumentPointsize <- function(docString) {

  # This function scans a LaTeX document declaration
  # for base pointsize used in the document. For example,
  # the declaration:
  #
  #    \documentclass[draft,12pt]{article}
  #
  # Should cause this function to return 12 as the pointsize.
  # The pointsize is used by the tikzDevice to determine
  # scaling factors and is stored at the C level in the
  # startps component of the pDevDesc structure.

  # Search the document declaration for the pointsize, and extract it if it is
  # there.  (Split the input by newlines before.)
  pointsize <- gsub(
    "^(?:.*[[, \t](\\d+)pt[], \t])?.*$", "\\1",
    strsplit(docString, "\n", fixed = TRUE),
    ignore.case = F, perl = T
  )

  # Return first matching line (if any), or NA otherwise
  as.numeric(pointsize[pointsize != ""][1])
}

tikzDefaults <- list(
  tikzDefaultEngine = "pdftex",

  tikzLatex = getOption("tikzLatexDefault"),

  tikzDocumentDeclaration = "\\documentclass[10pt]{article}\n",

  tikzLatexPackages = c(
    "\\usepackage{tikz}\n",
    "\\usepackage[active,tightpage,psfixbb]{preview}\n",
    "\\PreviewEnvironment{pgfpicture}\n",
    "\\setlength\\PreviewBorder{0pt}\n"
  ),

  tikzXelatexPackages = c(
    "\\usepackage{tikz}\n",
    "\\usepackage[active,tightpage,xetex]{preview}\n",
    "\\usepackage{fontspec,xunicode}\n",
    "\\PreviewEnvironment{pgfpicture}\n",
    "\\setlength\\PreviewBorder{0pt}\n"
  ),

  tikzLualatexPackages = c(
    "\\usepackage{tikz}\n",
    "\\IfFileExists{luatex85.sty}{\\usepackage{luatex85}}{}\n",
    "\\usepackage[active,tightpage,psfixbb]{preview}\n",
    "\\usepackage{fontspec}\n",
    "\\PreviewEnvironment{pgfpicture}\n",
    "\\setlength\\PreviewBorder{0pt}\n"
  ),

  tikzFooter = "",

  tikzMetricPackages = c(
    # The fontenc package is very important here!
    # R assumes the output device is uing T1 encoding.
    # LaTeX defaults to OT1. This package makes the
    # symbol codes consistant for both systems.
    "\\usepackage[T1]{fontenc}\n",
    "\\usetikzlibrary{calc}\n"
  ),

  tikzUnicodeMetricPackages = c(
    # The fontenc package is very important here!
    # R assumes the output device is uing T1 encoding.
    # LaTeX defaults to OT1. This package makes the
    # symbol codes consistant for both systems.
    "\\usepackage[T1]{fontenc}\n",
    "\\usetikzlibrary{calc}\n",
    "\\usepackage{fontspec}\n"
  ),


  tikzSanitizeCharacters = c("%", "$", "}", "{", "^", "_", "#", "&", "~"),

  tikzReplacementCharacters = c(
    "\\%", "\\$", "\\}", "\\{", "\\^{}", "\\_{}",
    "\\#", "\\&", "\\char`\\~"
  ),

  tikzLwdUnit = 0.4,

  tikzPdftexWarnUTF = TRUE,

  tikzSymbolicColors = FALSE,
  tikzMaxSymbolicColors = 100
)


#' Reset tikzDevice options to default values.
#'
#' This function resets the following options:
#'
#' \itemize{
#'   \item `tikzDefaultEngine`
#'   \item `tikzLatex`
#'   \item `tikzDocumentDeclaration`
#'   \item `tikzFooter`
#'   \item `tikzLatexPackages`
#'   \item `tikzXelatexPackages`
#'   \item `tikzLualatexPackages`
#'   \item `tikzMetricPackages`
#'   \item `tikzUnicodeMetricPackages`
#'   \item `tikzSanitizeCharacters`
#'   \item `tikzReplacementCharacters`
#'   \item `tikzPdftexWarnUTF`
#' }
#'
#' @param overwrite Should values that are already set in `options()` be
#'   overwritten?
#' @return Nothing returned.
#'
#' @author Cameron Bracken \email{cameron.bracken@@gmail.com} and Charlie
#'   Sharpsteen \email{source@@sharpsteen.net}
#'
#' @seealso [tikz()]
#'
#' @examples
#'
#'   print( options( 'tikzDocumentDeclaration' ) )
#'   options( tikzDocumentDeclaration = 'foo' )
#'   setTikzDefaults()
#'   print( options( 'tikzDocumentDeclaration' ) )
#'
#' @export
setTikzDefaults <- function(overwrite = TRUE) {
  if (!overwrite) {

    # We don't want to overwrite options that have allready been set.
    # Figure out which those are.
    tikzSetOptions <- sapply(
      do.call(options, as.list(names(tikzDefaults))),
      is.null
    )

    tikzSetOptions <- names(tikzDefaults)[ tikzSetOptions ]
  } else {
    tikzSetOptions <- names(tikzDefaults)
  }

  # Set defaults
  do.call(options, tikzDefaults[ tikzSetOptions ])

  # Return a list of the options that were modified.
  invisible(tikzSetOptions)
}

#' Get default options set by tikzDevice.
#'
#' @return 
#' This function returns a list with elements
#' \itemize{
#'   \item `tikzDefaultEngine`
#'   \item `tikzLatex`
#'   \item `tikzDocumentDeclaration`
#'   \item `tikzFooter`
#'   \item `tikzLatexPackages`
#'   \item `tikzXelatexPackages`
#'   \item `tikzLualatexPackages`
#'   \item `tikzMetricPackages`
#'   \item `tikzUnicodeMetricPackages`
#'   \item `tikzSanitizeCharacters`
#'   \item `tikzReplacementCharacters`
#'   \item `tikzPdftexWarnUTF`
#' }
#' 
#' @export
getTikzDefaults <- function() {
  return(tikzDefaults)
}

isTikzDevice <- function(which = dev.cur()) {
  if (which == 1) {
    return(FALSE)
  }

  dev_name <- names(dev.list()[which - 1])
  return(dev_name == "tikz output")
}


getDeviceInfo <- function(dev_num = dev.cur()) {
  # This function recovers some information about a tikz() graphics device that
  # is stored at the C level in the tikzDevDesc struct.
  #
  # Currently returns:
  #
  #  * The path to the TeX file that is being created.
  if (!isTikzDevice(dev_num)) {
    stop("The specified device is not a tikz device!")
  }

  device_info <- .Call(TikZ_DeviceInfo, dev_num)

  return(device_info)
}

# This function allows an R expression to be evaluated in a context where it
# will be protected from user interrupts (use of CTRL-C for example).
evalWithoutInterrupts <- function(expr, envir = parent.frame()) {
  # Wrap the expression in a call to `substitute` so that it gets passed
  # directly to the C code instead of being evaluated before being passed to
  # the C code.
  .Call(TikZ_EvalWithoutInterrupts, substitute(expr), envir)
}


#' Check If a String Contains Multibyte UTF-8 characters
#'
#' This function is used by tikzDevice to check if an incoming string contains
#' multibyte UTF-8 characters
#'
#' This function searches through the characters in the given string, if any of
#' the characters in the string are more than one byte then the function
#' returns `TRUE` otherwise it returns `FALSE`.
#'
#' The function will assume an input encoding of UTF-8 but will take any
#' specified encoding into account and will convert from the specified encoding
#' to UTF-8 before doing any checks
#'
#' @param string A character vector of length 1 (a string).
#' @param encoding Unused.
#' @return A boolean value
#' @author Cameron Bracken \email{cameron.bracken@@gmail.com}
#' @seealso [tikz()]
#' @keywords character
#' @encoding UTF8
#' @examples
#'
#' # TRUE
#' anyMultibyteUTF8Characters('R is GNU ©, but not ®')
#' # FALSE
#' anyMultibyteUTF8Characters('R is GNU copyright but not restricted')
#'
#' @export
anyMultibyteUTF8Characters <- function(string, encoding = "UTF-8") {

  # This function checks if any of the characters in the given string
  # are multibyte unicode charcters (not ASCII)
  #
  # The function will assume an input encoding of UTF-8 but will take any
  # specified encoding into account and will convert from the specified
  # encoding to UTF-8 before doing any checks

  mb <- FALSE

  # convert the string to UTF-8
  string <- enc2utf8(string)

  # Check if any of the characters are Multibyte
  explode <- strsplit(string, "")[[1]]
  for (i in seq_along(explode)) {
    if (length(charToRaw(explode[i])) > 1) {
      mb <- TRUE
      break
    }
  }

  return(mb)
}


# -----------------------------------------------------------------------------
#                     Methods for locating TeX Compilers
# -----------------------------------------------------------------------------

# S3 classes to represent the various sources for the path to an exectuable.
PATH <- function(origin) {
  structure(Sys.which(origin), origin = origin, class = "PATH")
}

OPTION <- function(origin) {
  structure(
    ifelse(is.null(getOption(origin)), "", Sys.which(getOption(origin))),
    origin = origin, class = "OPTION"
  )
}

ENV_VAR <- function(origin) {
  structure(
    ifelse(is.na(Sys.getenv(origin, unset=NA)), "", Sys.which(Sys.getenv(origin))),
    origin = origin, class = "ENV_VAR"
  )
}


isExecutable <- function(executable) {
  path <- as.character(executable)

  # file.access doesn't like non-zero lengths.
  if (nchar(path) == 0) {
    return(FALSE)
  }

  if (file.access(path, 1) == 0) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

formatExecutable <- function(executable) {
  desc <- "path:\n\t"
  desc <- paste(desc, as.character(executable), sep = "")
  desc <- paste(desc, "\nObtained from ", sep = "")
  desc <- paste(desc, format(executable), "\n", sep = "")

  return(desc)
}

# S3 methods have to be exported to the NAMESPACE in order to be effective
# during .onLoad...

#' @export
format.PATH <- function(x, ...) {
  sprintf("the PATH using the command: %s", attr(x, "origin"))
}
#' @export
format.OPTION <- function(x, ...) {
  sprintf("the global option: %s", attr(x, "origin"))
}
#' @export
format.ENV_VAR <- function(x, ...) {
  sprintf("the environment variable: %s", attr(x, "origin"))
}


#' Print paths to TeX compilers.
#'
#' This function reports information concerning compilers that the `tikz`
#' device will use to calculate character metrics. Information on LaTeX will
#' always be available but information on XeLaTeX and LuaLaTeX will only be
#' reported if the compilers were found.
#'
#' @param verbose
#'   If set to `FALSE`, calling this function will not cause any output to
#'   be printed to the screen. Defaults to `TRUE`.
#'
#' @return
#'   Invisibly returns a list containing paths to TeX compilers.
#'
#' @author
#'   Charlie Sharpsteen \email{source@@sharpsteen.net}
#'
#' @seealso
#'   [tikz()]
#'
#' @export
tikzCompilerInfo <- function(verbose = TRUE) {
  latexCompiler <- getOption("tikzLatex")
  xelatexCompiler <- getOption("tikzXelatex")
  lualatexCompiler <- getOption("tikzLualatex")

  if (verbose) {
    print_compiler_info(latexCompiler, "LaTeX")
    print_compiler_info(xelatexCompiler, "XeLaTeX")
    print_compiler_info(lualatexCompiler, "LuaLaTeX")
  }

  invisible(list(
    latex = latexCompiler, xelatex = xelatexCompiler, lualatex = lualatexCompiler
  ))
}

#' Test invocation of a LaTeX engine.
#'
#' This function simulates the measurement of dimensions and prints detailed
#' information in case of errors.
#'
#' @inheritParams getLatexStrWidth
#' @inheritParams tikz
#'
#' @seealso
#'   [tikz()]
#'
#' @export
tikzTest <- function(texString = "A",
                     engine = getOption("tikzDefaultEngine"),
                     documentDeclaration = getOption("tikzDocumentDeclaration"),
                     packages) {
  latex_cmd <- get_latex_cmd(engine)
  print_compiler_info(latex_cmd, "Active")
  getLatexStrWidth(
    texString,
    engine = engine,
    documentDeclaration = documentDeclaration,
    packages = packages,
    diagnose = TRUE
  )
}

print_compiler_info <- function(latex_cmd, name) {
  cat("\n", name, " compiler:\n\t", sep = "")
  if (is.null(latex_cmd)) {
    cat("Not available.\n")
  } else {
    cat(latex_cmd)
    cat("\n\t")
    p <- pipe(paste(latex_cmd, "--version"))
    cat(utils::head(readLines(p), 2), sep = "\n\t")
    close(p)
    cat("\n")
  }
}
