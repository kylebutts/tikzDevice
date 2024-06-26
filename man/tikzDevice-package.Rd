% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tikzDevice-package.R
\docType{package}
\name{tikzDevice-package}
\alias{tikzDevice-package}
\alias{tikzDevice}
\title{Support for native LaTeX output of R graphics}
\description{
The tikzDevice package implements the \code{\link[=tikz]{tikz()}} ouput device which
generates R graphics in a LaTeX friendly format. LaTeX handles the
typesetting of all text in graphics generated by \code{tikz}. This allows for
seamless integration between these graphics and documents that are also being
typeset by LaTeX. Using LaTeX to generate graph text also means that
\strong{LaTeX mathematics can be typeset directly into labels and
annotations}.
}
\section{Options That Affect Package Behavior}{
 The \pkg{tikzDevice} package
is currently influenced by a number of global options that may be set in
scripts, from the console or in a \code{.Rprofile} file. All of the options
can be set by using \verb{options(<option> = <value>)}.  These options
allow for the use of custom \code{documentclass} declarations, LaTeX
packages, and typesetting engines (e.g. XeLaTeX or LuaLaTeX). The defaults,
if are any for a given option, are shown below the description. The global
options are:

\describe{

\item{\code{tikzDefaultEngine}}{ Specifies which typesetting engine
functions in the tikzDevice package will prefer. Current possible values
are \code{pdftex}, \code{xetex} or \code{luatex}. Respectively, these
values trigger the use of the \code{pdflatex}, \code{xelatex} and
\code{lualatex} compilers.  }

\item{\code{tikzLatex}}{ Specifies the location of the LaTeX compiler to be
used by \pkg{tikzDevice}. Setting this option may help the package locate a
missing compiler. The default is searched for when the package is loaded,
otherwise it can be set manually. This option may be set as follows:
\code{options( tikzLatex = '/path/to/latex/compiler' )}.  }

\item{\code{tikzXelatex}}{ Functions similar to \code{tikzLatex}, except
this option specifies the location of the XeLaTeX compiler.  }

\item{\code{tikzLualatex}}{ Functions similar to \code{tikzLatex}, except
this option specifies the location of the LuaLaTeX compiler.  }

\item{\code{tikzMetricsDictionary}}{ When using the graphics device
provided by \pkg{tikzDevice}, you may notice that appears to "lag" or
"hang" when commands such as \code{plot()} are executed. This is because
the device must query the LaTeX compiler for string widths and font
metrics. For a normal plot, this may happen dozens or hundreds of times-
hence becomes unresponsive for a while. The good news is that the
\code{\link[=tikz]{tikz()}} code is designed to cache the results of these
computations so they need only be performed once for each string or
character. By default, these values are stored in a temporary cache file
which is deleted when is shut down.  A location for a permanent cache file
may be specified by setting the value of \code{tikzMetricsDictionary} in
\code{.Rprofile} with \code{options(tikzMetricsDictionary = '/path/to/dictionary/location')}.  }

\item{\code{tikzDocumentDeclaration}}{ A string. The LaTeX \code{documentclass}
declaration used in output files when \code{standAlone == TRUE}.
\code{tikzDocumentDeclaration} also influences the calculation of font
metrics. The default value is: \code{options(tikzDocumentDeclaration =
  "\\\\documentclass[10pt]{article}")} }

\item{\code{tikzLatexPackages}}{ A character vector. These are the packages
which are included when using the \code{pdftex} engine and
\code{\link[=tikz]{tikz()}} is used with the the \code{standAlone} option as well as
when font metrics are calculated.  }

\item{\code{tikzXelatexPackages}}{ This option works like
\code{tikzLatexPackages}, except is is used when the \code{xetex} engine is
in use.  }

\item{\code{tikzLualatexPackages}}{ This option works like
\code{tikzXelatexPackages}, except is is used when the \code{luatex} engine
is in use.  }

\item{\code{tikzFooter}}{ A character vector. The footer to be used only
when \code{standAlone==TRUE}.  }

\item{\code{tikzMetricPackages}}{ A character vector. These are the
packages which are additionally loaded when doing font metric calculations.
As you see below, the font encoding is set to Type 1. This is very
important so that character codes of LaTeX and match up. The default value
is: \code{options(tikzMetricPackages = c( "\\\\usepackage[utf8]{inputenc}",
  "\\\\usepackage[T1]{fontenc}", "\\\\usetikzlibrary{calc}" ))} }

\item{\code{tikzUnicodeMetricPackages}}{ This vector is used when font
metric calculations are performed using the \code{xetex} or \code{luatex}
engines. It should have the same contents as \code{tikzMetricPackages} with
the addition of the \code{fontspec} and \code{xunicode} packages.  }

\item{\code{tikzSanitizeCharacters}}{ A character vector of special latex
characters to replace. These values should correspond to the replacement
values from the \code{tikzReplacementCharacters} option. See
\code{\link[=sanitizeTexString]{sanitizeTexString()}} for more details.  }

\item{\code{tikzReplacementCharacters}}{ A character vector of replacements
for special latex characters. These values should correspond to the values
from the \code{tikzSanitizeCharacters} option.  }

\item{\code{tikzLwdUnit}}{ A numeric that denotes the number of \code{pt}s in LaTeX that \code{lwd=1} in R is
translated to. Defaults to 0.4 (LaTeX and TikZ default); for compatibility
with R default, please use 72.27/96 (96 pixels in R is 1 inch, which is 72.27
points in TeX).}

\item{\code{tikzPdftexWarnUTF}}{ A \code{TRUE/FALSE} value that controls
whether warnings are printed if Unicode characters are sent to a device
using the \code{pdftex} engine.  }

\item{\code{tikzSymbolicColors}}{ A logical value indicating whether colors
are written as RGB values or as symbolic names in which case the need to be
defined in the LaTeX document. }

\item{\code{tikzMaxSymbolicColors}}{ an integer number indicating the
maximal number of distinct colors to write symbolically. Any excess color
will be defined as if \code{symbolicColors} was set to \code{FALSE}.} }

Default values for all options may be viewed or restored using the
\code{\link[=setTikzDefaults]{setTikzDefaults()}} function.
}

\references{
The TikZ and PGF Packages: Manual for version 2.00\cr
\url{https://sourceforge.net/projects/pgf}\cr Till Tantau, February 20, 2008
}
\seealso{
\code{\link[=tikz]{tikz()}}
}
\author{
See \code{packageDescription("tikzDevice")}.

Submit bug reports to: \url{https://github.com/daqana/tikzDevice/issues}
}
