-- ~/.config/nvim/luasnippets/tex.lua
-- Complete port of Gilles Castel's UltiSnips LaTeX snippets to LuaSnip
-- Source: https://github.com/gillescastel/latex-snippets
--         https://castel.dev/post/lecture-notes-1/

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local line_begin = require("luasnip.extras.expand_conditions").line_begin

-- Helper: math mode detection via VimTeX
local in_mathzone = function()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

local in_text = function()
  return not in_mathzone()
end

-- Helper: get visual selection
local get_visual = function(args, parent)
  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else
    return sn(nil, i(1))
  end
end

-- ============================================================================
-- REGULAR SNIPPETS (require Tab to expand)
-- ============================================================================
local snippets = {

  -- Template
  s({ trig = "template", name = "Basic template", dscr = "Basic LaTeX document template" },
    fmta([[
\documentclass[a4paper]{article}

\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{textcomp}
\usepackage{amsmath, amssymb}
\usepackage{physics}


% figure support
\usepackage{import}
\usepackage{xifthen}
\usepackage{pdfpages}
\usepackage{transparent}
\newcommand{\incfig}[1]{%
  \def\svgwidth{\columnwidth}
  \import{./figures/}{#1.pdf_tex}
}

\begin{document}
  <>
\end{document}
    ]], { i(0) }),
    { condition = line_begin }
  ),

  -- Table environment
  s({ trig = "table", name = "Table environment" },
    fmta([[
\begin{table}[<>]
  \centering
  \caption{<>}
  \label{tab:<>}
  \begin{tabular}{<>}
    <>
  \end{tabular}
\end{table}
    ]], { i(1, "htpb"), i(2, "caption"), i(3, "label"), i(4, "c"), i(0) }),
    { condition = line_begin }
  ),

  -- Figure environment
  s({ trig = "fig", name = "Figure environment" },
    fmta([[
\begin{figure}[<>]
  \centering
  \includegraphics[width=0.8\textwidth]{<>}
  \caption{<>}
  \label{fig:<>}
\end{figure}
    ]], { i(1, "htpb"), i(2), i(3), i(4) }),
    { condition = line_begin }
  ),

  -- Description environment
  s({ trig = "desc", name = "Description" },
    fmta([[
\begin{description}
  \item[<>] <>
\end{description}
    ]], { i(1), i(0) }),
    { condition = line_begin }
  ),

  -- Package
  s({ trig = "pac", name = "Package" },
    fmta([[\usepackage[<>]{<>}<>]], { i(1, "options"), i(2, "package"), i(0) }),
    { condition = line_begin }
  ),

  -- Section / subsection / subsubsection
  s({ trig = "sec", name = "Section" },
    fmta([[\section{<>}<>]], { i(1), i(0) }),
    { condition = line_begin }
  ),
  s({ trig = "ssec", name = "Subsection" },
    fmta([[\subsection{<>}<>]], { i(1), i(0) }),
    { condition = line_begin }
  ),
  s({ trig = "sssec", name = "Subsubsection" },
    fmta([[\subsubsection{<>}<>]], { i(1), i(0) }),
    { condition = line_begin }
  ),

  -- Big function definition
  s({ trig = "bigfun", name = "Big function" },
    fmta([[
\begin{align*}
  <>: <>  &\longrightarrow <> \\
       <> &\longmapsto <>(<>) = <>
\end{align*}
    ]], { i(1), i(2), i(3), i(4), i(1), i(4), i(0) }),
    { condition = line_begin }
  ),

  -- Column vector
  s({ trig = "cvec", name = "Column vector" },
    fmta([[
\begin{pmatrix} <> \\ \vdots \\ <> \end{pmatrix}
    ]], { i(1, "x_1"), i(2, "x_n") })
  ),

  -- Plot (pgfplots)
  s({ trig = "plot", name = "Plot" },
    fmta([[
\begin{figure}[<>]
  \centering
  \begin{tikzpicture}
    \begin{axis}[
      xmin=<>, xmax=<>,
      ymin=<>, ymax=<>,
      axis lines=middle,
      ]
      \addplot[domain=<>:<>, samples=<>]{<>};
    \end{axis}
  \end{tikzpicture}
  \caption{<>}
  \label{fig:<>}
\end{figure}
    ]], {
      i(1, "htpb"),
      i(2, "-10"), i(3, "10"),
      i(4, "-10"), i(5, "10"),
      i(6, "-10"), i(7, "10"),
      i(8, "100"), i(9, "x"),
      i(10, "caption"), i(0, "label"),
    }),
    { condition = line_begin }
  ),

}

-- ============================================================================
-- AUTOSNIPPETS (expand automatically without Tab)
-- ============================================================================
local autosnippets = {

  -- ===================== ENVIRONMENTS =====================

  -- begin/end
  s({ trig = "beg", name = "begin/end", snippetType = "autosnippet" },
    fmta([[
\begin{<>}
  <>
\end{<>}
    ]], { i(1), i(0), rep(1) }),
    { condition = line_begin }
  ),

  -- Enumerate
  s({ trig = "enum", name = "Enumerate", snippetType = "autosnippet" },
    fmta([[
\begin{enumerate}
  \item <>
\end{enumerate}
    ]], { i(0) }),
    { condition = line_begin }
  ),

  -- Itemize
  s({ trig = "item", name = "Itemize", snippetType = "autosnippet" },
    fmta([[
\begin{itemize}
  \item <>
\end{itemize}
    ]], { i(0) }),
    { condition = line_begin }
  ),

  -- Align
  s({ trig = "ali", name = "Align", snippetType = "autosnippet" },
    fmta([[
\begin{align*}
  <>
\end{align*}
    ]], { i(0) }),
    { condition = line_begin }
  ),

  -- Cases
  s({ trig = "case", name = "cases", snippetType = "autosnippet" },
    fmta([[
\begin{cases}
  <>
\end{cases}
    ]], { i(0) }),
    { condition = in_mathzone }
  ),

  -- ===================== MATH MODE =====================

  -- Inline math
  s({ trig = "mk", name = "Inline math", snippetType = "autosnippet", wordTrig = true },
    fmta("$<>$<>", { i(1), i(0) }),
    { condition = in_text }
  ),

  -- Display math
  s({ trig = "dm", name = "Display math", snippetType = "autosnippet", wordTrig = true },
    fmta([[
\[
  <>
.\] <>
    ]], { i(1), i(0) }),
    { condition = in_text }
  ),

  -- ===================== FRACTIONS =====================

  -- Basic fraction
  s({ trig = "//", name = "Fraction", snippetType = "autosnippet", wordTrig = false },
    fmta([[\frac{<>}{<>}<>]], { i(1), i(2), i(0) }),
    { condition = in_mathzone }
  ),

  -- Auto fraction: 3/ -> \frac{3}{}
  s({ trig = "(%d+)/", name = "Number fraction", regTrig = true, snippetType = "autosnippet", wordTrig = false },
    { f(function(_, snip) return "\\frac{" .. snip.captures[1] .. "}" end), t("{"), i(1), t("}"), i(0) },
    { condition = in_mathzone }
  ),

  -- Auto fraction: expression with letters/numbers
  s({ trig = "([A-Za-z])(%d)/", name = "Letter-number fraction", regTrig = true, snippetType = "autosnippet", wordTrig = false },
    { f(function(_, snip) return "\\frac{" .. snip.captures[1] .. snip.captures[2] .. "}" end), t("{"), i(1), t("}"), i(0) },
    { condition = in_mathzone }
  ),

  -- ===================== SUB/SUPERSCRIPTS =====================

  -- Auto subscript: a1 -> a_1
  s({ trig = "([A-Za-z])(%d)", name = "Auto subscript", regTrig = true, snippetType = "autosnippet", wordTrig = false },
    f(function(_, snip) return snip.captures[1] .. "_" .. snip.captures[2] end),
    { condition = in_mathzone }
  ),

  -- Auto subscript2: a_12 -> a_{12}
  s({ trig = "([A-Za-z])_(%d%d)", name = "Auto subscript2", regTrig = true, snippetType = "autosnippet", wordTrig = false },
    f(function(_, snip) return snip.captures[1] .. "_{" .. snip.captures[2] .. "}" end),
    { condition = in_mathzone }
  ),

  -- Superscript
  s({ trig = "td", name = "Superscript", snippetType = "autosnippet", wordTrig = false },
    fmta("^{<>}<>", { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- Squared
  s({ trig = "sr", name = "Squared", snippetType = "autosnippet", wordTrig = false },
    t("^2"),
    { condition = in_mathzone }
  ),

  -- Cubed
  s({ trig = "cb", name = "Cubed", snippetType = "autosnippet", wordTrig = false },
    t("^3"),
    { condition = in_mathzone }
  ),

  -- Complement
  s({ trig = "compl", name = "Complement", snippetType = "autosnippet", wordTrig = false },
    t("^{c}"),
    { condition = in_mathzone }
  ),

  -- Subscript
  s({ trig = "__", name = "Subscript", snippetType = "autosnippet", wordTrig = false },
    fmta("_{<>}<>", { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- ===================== POSTFIX SNIPPETS (hat, bar, etc.) =====================

  -- hat
  s({ trig = "(%a)hat", name = "hat", regTrig = true, snippetType = "autosnippet", wordTrig = false },
    f(function(_, snip) return "\\hat{" .. snip.captures[1] .. "}" end),
    { condition = in_mathzone }
  ),

  -- bar
  s({ trig = "(%a)bar", name = "bar", regTrig = true, snippetType = "autosnippet", wordTrig = false },
    f(function(_, snip) return "\\bar{" .. snip.captures[1] .. "}" end),
    { condition = in_mathzone }
  ),

  -- vec
  s({ trig = "(%a)vec", name = "vec", regTrig = true, snippetType = "autosnippet", wordTrig = false },
    f(function(_, snip) return "\\vec{" .. snip.captures[1] .. "}" end),
    { condition = in_mathzone }
  ),

  -- tilde
  s({ trig = "(%a)tld", name = "tilde", regTrig = true, snippetType = "autosnippet", wordTrig = false },
    f(function(_, snip) return "\\tilde{" .. snip.captures[1] .. "}" end),
    { condition = in_mathzone }
  ),

  -- overline (conjugate)
  s({ trig = "conj", name = "Conjugate/overline", snippetType = "autosnippet", wordTrig = true },
    fmta([[\overline{<>}<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- Bra-ket (physics package)
  s({ trig = "bra", name = "bra", snippetType = "autosnippet",
wordTrig = true },
    fmta([[\bra{<>}<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "ket", name = "ket", snippetType = "autosnippet",
wordTrig = true },
    fmta([[\ket{<>}<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "brk", name = "braket", snippetType = "autosnippet",
wordTrig = true },
    fmta([[\braket{<>}{<>}<>]], { i(1), i(2), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "ip", name = "inner product", snippetType =
"autosnippet", wordTrig = true },
    fmta([[\ip{<>}{<>}<>]], { i(1), i(2), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "mel", name = "matrix element", snippetType =
"autosnippet", wordTrig = true },
    fmta([[\mel{<>}{<>}{<>}<>]], { i(1), i(2), i(3), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "ev", name = "expectation value", snippetType =
"autosnippet", wordTrig = true },
    fmta([[\ev{<>}<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "comm", name = "commutator", snippetType = "autosnippet",
wordTrig = true },
    fmta([[\comm{<>}{<>}<>]], { i(1), i(2), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "acomm", name = "anticommutator", snippetType =
"autosnippet", wordTrig = true },
    fmta([[\acomm{<>}{<>}<>]], { i(1), i(2), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "dv", name = "derivative", snippetType = "autosnippet",
wordTrig = true },
    fmta([[\dv{<>}{<>}<>]], { i(1), i(2), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "pdv", name = "partial derivative", snippetType =
"autosnippet", wordTrig = true },
    fmta([[\pdv{<>}{<>}<>]], { i(1), i(2), i(0) }),
    { condition = in_mathzone }
  ),

  -- ===================== SYMBOLS & OPERATORS =====================

  -- Dots
  s({ trig = "...", name = "ldots", snippetType = "autosnippet", priority = 100 },
    t("\\ldots"),
    {}
  ),

  -- Implies / implied by / iff
  s({ trig = "=>", name = "implies", snippetType = "autosnippet", wordTrig = false },
    t("\\implies"),
    {}
  ),
  s({ trig = "=<", name = "implied by", snippetType = "autosnippet", wordTrig = false },
    t("\\impliedby"),
    {}
  ),
  s({ trig = "iff", name = "iff", snippetType = "autosnippet", wordTrig = true },
    t("\\iff"),
    { condition = in_mathzone }
  ),

  -- Not equal
  s({ trig = "!=", name = "not equal", snippetType = "autosnippet", wordTrig = false },
    t("\\neq"),
    { condition = in_mathzone }
  ),

  -- Less/greater equal
  s({ trig = "<=", name = "leq", snippetType = "autosnippet", wordTrig = false, priority = 100 },
    t("\\le"),
    { condition = in_mathzone }
  ),
  s({ trig = ">=", name = "geq", snippetType = "autosnippet", wordTrig = false, priority = 100 },
    t("\\ge"),
    { condition = in_mathzone }
  ),

  -- Much less/greater
  s({ trig = ">>", name = "gg", snippetType = "autosnippet", wordTrig = false },
    t("\\gg"),
    { condition = in_mathzone }
  ),
  s({ trig = "<<", name = "ll", snippetType = "autosnippet", wordTrig = false },
    t("\\ll"),
    { condition = in_mathzone }
  ),

  -- Sim
  s({ trig = "~~", name = "sim", snippetType = "autosnippet", wordTrig = false },
    t("\\sim"),
    { condition = in_mathzone }
  ),

  -- Approx
  s({ trig = "~=", name = "approx", snippetType = "autosnippet", wordTrig = false },
    t("\\approx"),
    { condition = in_mathzone }
  ),

  -- Times / cdot
  s({ trig = "xx", name = "times", snippetType = "autosnippet", wordTrig = false },
    t("\\times"),
    { condition = in_mathzone }
  ),
  s({ trig = "**", name = "cdot", snippetType = "autosnippet", wordTrig = false, priority = 100 },
    t("\\cdot"),
    { condition = in_mathzone }
  ),

  -- Infinity
  s({ trig = "ooo", name = "infinity", snippetType = "autosnippet", wordTrig = true },
    t("\\infty"),
    { condition = in_mathzone }
  ),

  -- Emptyset
  s({ trig = "OO", name = "emptyset", snippetType = "autosnippet", wordTrig = true },
    t("\\emptyset"),
    { condition = in_mathzone }
  ),

  -- Plus/minus
  s({ trig = "+-", name = "pm", snippetType = "autosnippet", wordTrig = false },
    t("\\pm"),
    { condition = in_mathzone }
  ),
  s({ trig = "-+", name = "mp", snippetType = "autosnippet", wordTrig = false },
    t("\\mp"),
    { condition = in_mathzone }
  ),

  -- Arrows
  s({ trig = "->", name = "to", snippetType = "autosnippet", wordTrig = false, priority = 100 },
    t("\\to"),
    { condition = in_mathzone }
  ),
  s({ trig = "<->", name = "leftrightarrow", snippetType = "autosnippet", wordTrig = false, priority = 200 },
    t("\\leftrightarrow"),
    { condition = in_mathzone }
  ),
  s({ trig = "!>", name = "mapsto", snippetType = "autosnippet", wordTrig = false },
    t("\\mapsto"),
    { condition = in_mathzone }
  ),

  -- Invs (inverse)
  s({ trig = "invs", name = "inverse", snippetType = "autosnippet", wordTrig = true },
    t("^{-1}"),
    { condition = in_mathzone }
  ),

  -- ===================== SET THEORY & LOGIC =====================

  -- Set
  s({ trig = "set", name = "set", snippetType = "autosnippet", wordTrig = true },
    fmta([[\{<>\}<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- Subset / supset
  s({ trig = "cc", name = "subset", snippetType = "autosnippet", wordTrig = true },
    t("\\subset"),
    { condition = in_mathzone }
  ),
  s({ trig = "cq", name = "subseteq", snippetType = "autosnippet", wordTrig = true },
    t("\\subseteq"),
    { condition = in_mathzone }
  ),

  -- In / not in
  s({ trig = "inn", name = "in", snippetType = "autosnippet", wordTrig = true },
    t("\\in"),
    { condition = in_mathzone }
  ),
  s({ trig = "notin", name = "not in", snippetType = "autosnippet", wordTrig = true },
    t("\\not\\in"),
    { condition = in_mathzone }
  ),

  -- Cap / cup
  s({ trig = "Nn", name = "cap", snippetType = "autosnippet", wordTrig = true },
    t("\\cap"),
    { condition = in_mathzone }
  ),
  s({ trig = "UU", name = "cup", snippetType = "autosnippet", wordTrig = true },
    t("\\cup"),
    { condition = in_mathzone }
  ),
  s({ trig = "bnn", name = "bigcap", snippetType = "autosnippet", wordTrig = true },
    t("\\bigcap"),
    { condition = in_mathzone }
  ),
  s({ trig = "buu", name = "bigcup", snippetType = "autosnippet", wordTrig = true },
    t("\\bigcup"),
    { condition = in_mathzone }
  ),

  -- Forall / exists
  s({ trig = "AA", name = "forall", snippetType = "autosnippet", wordTrig = true },
    t("\\forall"),
    { condition = in_mathzone }
  ),
  s({ trig = "EE", name = "exists", snippetType = "autosnippet", wordTrig = true },
    t("\\exists"),
    { condition = in_mathzone }
  ),

  -- ===================== BLACKBOARD BOLD =====================

  s({ trig = "RR", name = "R", snippetType = "autosnippet", wordTrig = true },
    t("\\mathbb{R}"),
    { condition = in_mathzone }
  ),
  s({ trig = "QQ", name = "Q", snippetType = "autosnippet", wordTrig = true },
    t("\\mathbb{Q}"),
    { condition = in_mathzone }
  ),
  s({ trig = "ZZ", name = "Z", snippetType = "autosnippet", wordTrig = true },
    t("\\mathbb{Z}"),
    { condition = in_mathzone }
  ),
  s({ trig = "NN", name = "N", snippetType = "autosnippet", wordTrig = true },
    t("\\mathbb{N}"),
    { condition = in_mathzone }
  ),
  s({ trig = "CC", name = "C", snippetType = "autosnippet", wordTrig = true },
    t("\\mathbb{C}"),
    { condition = in_mathzone }
  ),
  s({ trig = "HH", name = "H", snippetType = "autosnippet", wordTrig = true },
    t("\\mathbb{H}"),
    { condition = in_mathzone }
  ),
  s({ trig = "DD", name = "D", snippetType = "autosnippet", wordTrig = true },
    t("\\mathbb{D}"),
    { condition = in_mathzone }
  ),
  s({ trig = "PP", name = "P", snippetType = "autosnippet", wordTrig = true },
    t("\\mathbb{P}"),
    { condition = in_mathzone }
  ),
  s({ trig = "11", name = "1 (indicator)", snippetType = "autosnippet", wordTrig = true },
    t("\\mathbb{1}"),
    { condition = in_mathzone }
  ),

  -- ===================== GREEK LETTERS =====================

  s({ trig = "@a", snippetType = "autosnippet", wordTrig = false }, t("\\alpha"), { condition = in_mathzone }),
  s({ trig = "@b", snippetType = "autosnippet", wordTrig = false }, t("\\beta"), { condition = in_mathzone }),
  s({ trig = "@c", snippetType = "autosnippet", wordTrig = false }, t("\\chi"), { condition = in_mathzone }),
  s({ trig = "@d", snippetType = "autosnippet", wordTrig = false }, t("\\delta"), { condition = in_mathzone }),
  s({ trig = "@e", snippetType = "autosnippet", wordTrig = false }, t("\\epsilon"), { condition = in_mathzone }),
  s({ trig = "@f", snippetType = "autosnippet", wordTrig = false }, t("\\varphi"), { condition = in_mathzone }),
  s({ trig = "@g", snippetType = "autosnippet", wordTrig = false }, t("\\gamma"), { condition = in_mathzone }),
  s({ trig = "@h", snippetType = "autosnippet", wordTrig = false }, t("\\eta"), { condition = in_mathzone }),
  s({ trig = "@i", snippetType = "autosnippet", wordTrig = false }, t("\\iota"), { condition = in_mathzone }),
  s({ trig = "@k", snippetType = "autosnippet", wordTrig = false }, t("\\kappa"), { condition = in_mathzone }),
  s({ trig = "@l", snippetType = "autosnippet", wordTrig = false }, t("\\lambda"), { condition = in_mathzone }),
  s({ trig = "@m", snippetType = "autosnippet", wordTrig = false }, t("\\mu"), { condition = in_mathzone }),
  s({ trig = "@n", snippetType = "autosnippet", wordTrig = false }, t("\\nu"), { condition = in_mathzone }),
  s({ trig = "@o", snippetType = "autosnippet", wordTrig = false }, t("\\omega"), { condition = in_mathzone }),
  s({ trig = "@p", snippetType = "autosnippet", wordTrig = false }, t("\\pi"), { condition = in_mathzone }),
  s({ trig = "@q", snippetType = "autosnippet", wordTrig = false }, t("\\theta"), { condition = in_mathzone }),
  s({ trig = "@r", snippetType = "autosnippet", wordTrig = false }, t("\\rho"), { condition = in_mathzone }),
  s({ trig = "@s", snippetType = "autosnippet", wordTrig = false }, t("\\sigma"), { condition = in_mathzone }),
  s({ trig = "@t", snippetType = "autosnippet", wordTrig = false }, t("\\tau"), { condition = in_mathzone }),
  s({ trig = "@u", snippetType = "autosnippet", wordTrig = false }, t("\\upsilon"), { condition = in_mathzone }),
  s({ trig = "@x", snippetType = "autosnippet", wordTrig = false }, t("\\xi"), { condition = in_mathzone }),
  s({ trig = "@z", snippetType = "autosnippet", wordTrig = false }, t("\\zeta"), { condition = in_mathzone }),

  -- Variants
  s({ trig = "@ve", snippetType = "autosnippet", wordTrig = false }, t("\\varepsilon"), { condition = in_mathzone }),
  s({ trig = "@vf", snippetType = "autosnippet", wordTrig = false }, t("\\phi"), { condition = in_mathzone }),
  s({ trig = "@vq", snippetType = "autosnippet", wordTrig = false }, t("\\vartheta"), { condition = in_mathzone }),

  -- Capital Greek
  s({ trig = "@G", snippetType = "autosnippet", wordTrig = false }, t("\\Gamma"), { condition = in_mathzone }),
  s({ trig = "@D", snippetType = "autosnippet", wordTrig = false }, t("\\Delta"), { condition = in_mathzone }),
  s({ trig = "@T", snippetType = "autosnippet", wordTrig = false }, t("\\Theta"), { condition = in_mathzone }),
  s({ trig = "@L", snippetType = "autosnippet", wordTrig = false }, t("\\Lambda"), { condition = in_mathzone }),
  s({ trig = "@X", snippetType = "autosnippet", wordTrig = false }, t("\\Xi"), { condition = in_mathzone }),
  s({ trig = "@P", snippetType = "autosnippet", wordTrig = false }, t("\\Pi"), { condition = in_mathzone }),
  s({ trig = "@S", snippetType = "autosnippet", wordTrig = false }, t("\\Sigma"), { condition = in_mathzone }),
  s({ trig = "@U", snippetType = "autosnippet", wordTrig = false }, t("\\Upsilon"), { condition = in_mathzone }),
  s({ trig = "@F", snippetType = "autosnippet", wordTrig = false }, t("\\Phi"), { condition = in_mathzone }),
  s({ trig = "@Y", snippetType = "autosnippet", wordTrig = false }, t("\\Psi"), { condition = in_mathzone }),
  s({ trig = "@W", snippetType = "autosnippet", wordTrig = false }, t("\\Omega"), { condition = in_mathzone }),

  -- ===================== CALCULUS & ANALYSIS =====================

  -- Sum
  s({ trig = "sum", name = "sum", snippetType = "autosnippet", wordTrig = true },
    fmta([[\sum_{<>}^{<>} <>]], { i(1, "n=1"), i(2, "\\infty"), i(0) }),
    { condition = in_mathzone }
  ),

  -- Product
  s({ trig = "prod", name = "product", snippetType = "autosnippet", wordTrig = true },
    fmta([[\prod_{<>}^{<>} <>]], { i(1, "n=1"), i(2, "\\infty"), i(0) }),
    { condition = in_mathzone }
  ),

  -- Limit
  s({ trig = "lim", name = "limit", snippetType = "autosnippet", wordTrig = true },
    fmta([[\lim_{<> \to <>} <>]], { i(1, "n"), i(2, "\\infty"), i(0) }),
    { condition = in_mathzone }
  ),

  -- Limit superior / inferior
  s({ trig = "limsup", name = "limsup", snippetType = "autosnippet", wordTrig = true, priority = 200 },
    t("\\limsup"),
    { condition = in_mathzone }
  ),

  -- Integral
  s({ trig = "dint", name = "Definite integral", snippetType = "autosnippet", wordTrig = true },
    fmta([[\int_{<>}^{<>} <> \,d<>]], { i(1, "-\\infty"), i(2, "\\infty"), i(3), i(0, "x") }),
    { condition = in_mathzone }
  ),

  -- Partial derivative
  s({ trig = "part", name = "Partial derivative", snippetType = "autosnippet", wordTrig = true },
    fmta([[\frac{\partial <>}{\partial <>}<>]], { i(1, "V"), i(2, "x"), i(0) }),
    { condition = in_mathzone }
  ),

  -- Derivative
  s({ trig = "ddx", name = "Derivative d/dx", snippetType = "autosnippet", wordTrig = true },
    fmta([[\frac{d<>}{d<>}<>]], { i(1, "V"), i(2, "x"), i(0) }),
    { condition = in_mathzone }
  ),

  -- Nabla
  s({ trig = "nabl", name = "nabla", snippetType = "autosnippet", wordTrig = true },
    t("\\nabla"),
    { condition = in_mathzone }
  ),

  -- ===================== LINEAR ALGEBRA =====================

  -- Norm / abs
  s({ trig = "norm", name = "norm", snippetType = "autosnippet", wordTrig = true },
    fmta([[\left\| <> \right\|<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "abs", name = "absolute value", snippetType = "autosnippet", wordTrig = true },
    fmta([[\left| <> \right|<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- Ceil / floor
  s({ trig = "ceil", name = "ceil", snippetType = "autosnippet", wordTrig = true },
    fmta([[\left\lceil <> \right\rceil<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "floor", name = "floor", snippetType = "autosnippet", wordTrig = true },
    fmta([[\left\lfloor <> \right\rfloor<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- Matrices
  s({ trig = "pmat", name = "pmatrix", snippetType = "autosnippet", wordTrig = true },
    fmta([[
\begin{pmatrix}
  <>
\end{pmatrix}<>
    ]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "bmat", name = "bmatrix", snippetType = "autosnippet", wordTrig = true },
    fmta([[
\begin{bmatrix}
  <>
\end{bmatrix}<>
    ]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- ===================== DELIMITERS =====================

  -- Left-right auto
  s({ trig = "lr(", name = "left( right)", snippetType = "autosnippet", wordTrig = false },
    fmta([[\left( <> \right)<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "lr[", name = "left[ right]", snippetType = "autosnippet", wordTrig = false },
    fmta([[\left[ <> \right]<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "lr{", name = "left{ right}", snippetType = "autosnippet", wordTrig = false },
    fmta([[\left\{ <> \right\}<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "lr|", name = "left| right|", snippetType = "autosnippet", wordTrig = false },
    fmta([[\left| <> \right|<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "lra", name = "left< right>", snippetType = "autosnippet", wordTrig = false },
    fmta([[\left\langle <> \right\rangle<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),
  s({ trig = "lr", name = "left( right)", snippetType = "autosnippet", wordTrig = true },
    fmta([[\left( <> \right)<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- ===================== TEXT & FORMATTING IN MATH =====================

  -- Text
  s({ trig = "tt", name = "text", snippetType = "autosnippet", wordTrig = true },
    fmta([[\text{<>}<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- Mathcal
  s({ trig = "mcal", name = "mathcal", snippetType = "autosnippet", wordTrig = true },
    fmta([[\mathcal{<>}<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- Mathfrak
  s({ trig = "mfr", name = "mathfrak", snippetType = "autosnippet", wordTrig = true },
    fmta([[\mathfrak{<>}<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- Mathbb
  s({ trig = "mbb", name = "mathbb", snippetType = "autosnippet", wordTrig = true },
    fmta([[\mathbb{<>}<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- Mathbf (bold)
  s({ trig = "mbf", name = "mathbf", snippetType = "autosnippet", wordTrig = true },
    fmta([[\mathbf{<>}<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- Mathscr
  s({ trig = "mscr", name = "mathscr", snippetType = "autosnippet", wordTrig = true },
    fmta([[\mathscr{<>}<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- sqrt
  s({ trig = "sq", name = "sqrt", snippetType = "autosnippet", wordTrig = true },
    fmta([[\sqrt{<>}<>]], { i(1), i(0) }),
    { condition = in_mathzone }
  ),

  -- ell
  s({ trig = "lll", name = "ell", snippetType = "autosnippet", wordTrig = true },
    t("\\ell"),
    { condition = in_mathzone }
  ),

  -- ===================== MISC MATH =====================

  -- Mid (divides)
  s({ trig = "||", name = "mid", snippetType = "autosnippet", wordTrig = false },
    t("\\mid"),
    { condition = in_mathzone }
  ),

  -- Stackrel
  s({ trig = "srel", name = "stackrel", snippetType = "autosnippet", wordTrig = true },
    fmta([[\stackrel{<>}{<>}<>]], { i(1), i(2), i(0) }),
    { condition = in_mathzone }
  ),

  -- Overset
  s({ trig = "ovs", name = "overset", snippetType = "autosnippet", wordTrig = true },
    fmta([[\overset{<>}{<>}<>]], { i(1), i(2), i(0) }),
    { condition = in_mathzone }
  ),

  -- Underset
  s({ trig = "uns", name = "underset", snippetType = "autosnippet", wordTrig = true },
    fmta([[\underset{<>}{<>}<>]], { i(1), i(2), i(0) }),
    { condition = in_mathzone }
  ),

  -- Trig functions
  s({ trig = "sin", snippetType = "autosnippet", wordTrig = true }, t("\\sin"), { condition = in_mathzone }),
  s({ trig = "cos", snippetType = "autosnippet", wordTrig = true }, t("\\cos"), { condition = in_mathzone }),
  s({ trig = "tan", snippetType = "autosnippet", wordTrig = true }, t("\\tan"), { condition = in_mathzone }),
  s({ trig = "cot", snippetType = "autosnippet", wordTrig = true }, t("\\cot"), { condition = in_mathzone }),
  s({ trig = "sec", snippetType = "autosnippet", wordTrig = true, priority = 50 }, t("\\sec"), { condition = in_mathzone }),
  s({ trig = "csc", snippetType = "autosnippet", wordTrig = true }, t("\\csc"), { condition = in_mathzone }),
  s({ trig = "ln", snippetType = "autosnippet", wordTrig = true }, t("\\ln"), { condition = in_mathzone }),
  s({ trig = "log", snippetType = "autosnippet", wordTrig = true }, t("\\log"), { condition = in_mathzone }),
  s({ trig = "exp", snippetType = "autosnippet", wordTrig = true }, t("\\exp"), { condition = in_mathzone }),
  s({ trig = "arcsin", snippetType = "autosnippet", wordTrig = true, priority = 200 }, t("\\arcsin"), { condition = in_mathzone }),
  s({ trig = "arccos", snippetType = "autosnippet", wordTrig = true, priority = 200 }, t("\\arccos"), { condition = in_mathzone }),
  s({ trig = "arctan", snippetType = "autosnippet", wordTrig = true, priority = 200 }, t("\\arctan"), { condition = in_mathzone }),
  s({ trig = "min", snippetType = "autosnippet", wordTrig = true }, t("\\min"), { condition = in_mathzone }),
  s({ trig = "max", snippetType = "autosnippet", wordTrig = true }, t("\\max"), { condition = in_mathzone }),
  s({ trig = "inf", snippetType = "autosnippet", wordTrig = true }, t("\\inf"), { condition = in_mathzone }),
  s({ trig = "sup", snippetType = "autosnippet", wordTrig = true }, t("\\sup"), { condition = in_mathzone }),
  s({ trig = "det", snippetType = "autosnippet", wordTrig = true }, t("\\det"), { condition = in_mathzone }),
  s({ trig = "dim", snippetType = "autosnippet", wordTrig = true }, t("\\dim"), { condition = in_mathzone }),
  s({ trig = "ker", snippetType = "autosnippet", wordTrig = true }, t("\\ker"), { condition = in_mathzone }),
  s({ trig = "deg", snippetType = "autosnippet", wordTrig = true }, t("\\deg"), { condition = in_mathzone }),

  -- Star
  s({ trig = "**", name = "cdot", snippetType = "autosnippet", wordTrig = false, priority = 100 },
    t("\\cdot"),
    { condition = in_mathzone }
  ),

  -- Dots
  s({ trig = "cds", name = "cdots", snippetType = "autosnippet", wordTrig = true },
    t("\\cdots"),
    { condition = in_mathzone }
  ),
  s({ trig = "vds", name = "vdots", snippetType = "autosnippet", wordTrig = true },
    t("\\vdots"),
    { condition = in_mathzone }
  ),
  s({ trig = "dds", name = "ddots", snippetType = "autosnippet", wordTrig = true },
    t("\\ddots"),
    { condition = in_mathzone }
  ),

  -- ===================== TEXT MODE FORMATTING =====================

  -- Bold / italic / underline (text mode)
  s({ trig = "bf", name = "textbf", snippetType = "autosnippet", wordTrig = true },
    fmta([[\textbf{<>}<>]], { i(1), i(0) }),
    { condition = in_text }
  ),
  s({ trig = "ita", name = "textit", snippetType = "autosnippet", wordTrig = true },
    fmta([[\textit{<>}<>]], { i(1), i(0) }),
    { condition = in_text }
  ),
  s({ trig = "und", name = "underline", snippetType = "autosnippet", wordTrig = true },
    fmta([[\underline{<>}<>]], { i(1), i(0) }),
    { condition = in_text }
  ),

  -- ===================== MISC =====================

  -- Superscript with star
  s({ trig = "sts", name = "star superscript", snippetType = "autosnippet", wordTrig = false },
    t("^{*}"),
    { condition = in_mathzone }
  ),

  -- Transpose
  s({ trig = "trp", name = "transpose", snippetType = "autosnippet", wordTrig = true },
    t("^{\\top}"),
    { condition = in_mathzone }
  ),

  -- Dagger
  s({ trig = "dag", name = "dagger", snippetType = "autosnippet", wordTrig = true },
    t("^{\\dagger}"),
    { condition = in_mathzone }
  ),

  -- Let omega (Castel-specific)
  s({ trig = "letw", name = "let omega", snippetType = "autosnippet", wordTrig = true },
    t("Let $\\omega \\in \\Omega$"),
    { condition = in_text }
  ),

  -- Taylor expansion
  s({ trig = "taylor", name = "Taylor", snippetType = "autosnippet", wordTrig = true },
    fmta([[<> = \sum_{<>}^{<>} c_<> (x - a)^<> <>]], {
      i(1, "f(x)"), i(2, "k=0"), i(3, "\\infty"),
      i(4, "k"), i(5, "k"), i(0)
    }),
    { condition = in_mathzone }
  ),

  -- xnn -> x_n, xii -> x_i, etc.
  s({ trig = "xnn", snippetType = "autosnippet", wordTrig = true }, t("x_{n}"), { condition = in_mathzone }),
  s({ trig = "xii", snippetType = "autosnippet", wordTrig = true }, t("x_{i}"), { condition = in_mathzone }),
  s({ trig = "xjj", snippetType = "autosnippet", wordTrig = true }, t("x_{j}"), { condition = in_mathzone }),
  s({ trig = "xmm", snippetType = "autosnippet", wordTrig = true }, t("x_{m}"), { condition = in_mathzone }),
  s({ trig = "ynn", snippetType = "autosnippet", wordTrig = true }, t("y_{n}"), { condition = in_mathzone }),
  s({ trig = "yii", snippetType = "autosnippet", wordTrig = true }, t("y_{i}"), { condition = in_mathzone }),
  s({ trig = "yjj", snippetType = "autosnippet", wordTrig = true }, t("y_{j}"), { condition = in_mathzone }),

  -- R0+, Rn
  s({ trig = "R0+", snippetType = "autosnippet", wordTrig = true }, t("\\mathbb{R}_0^+"), { condition = in_mathzone }),
  s({ trig = "Rn", snippetType = "autosnippet", wordTrig = true },
    fmta([[\mathbb{R}^{<>}<>]], { i(1, "n"), i(0) }),
    { condition = in_mathzone }
  ),

  -- Operators with limits
  s({ trig = "sumin", name = "sum i=1 to n", snippetType = "autosnippet", wordTrig = true, priority = 200 },
    t("\\sum_{i=1}^{n}"),
    { condition = in_mathzone }
  ),

  -- Display-style fraction
  s({ trig = "dff", name = "displaystyle frac", snippetType = "autosnippet", wordTrig = true },
    fmta([[\dfrac{<>}{<>}<>]], { i(1), i(2), i(0) }),
    { condition = in_mathzone }
  ),

}

return snippets, autosnippets
