-- ~/.config/nvim/luasnippets/tex_advanced.lua
-- Advanced Castel snippets that originally required Python runtime
-- Parenthesis-matching fractions, sympy evaluation, etc.

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmta = require("luasnip.extras.fmt").fmta

local in_mathzone = function()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

-- ============================================================================
-- PARENTHESIS-MATCHING FRACTION
-- (1 + 2 + 3)/ → \frac{1 + 2 + 3}{}
-- (1 + (2+3))/ → \frac{1 + (2+3)}{}
-- Handles nested parentheses correctly.
-- ============================================================================

local function find_matching_paren(line)
  -- Walk backwards from the `/` (which is already stripped) to find matching `(`
  local depth = 0
  for j = #line, 1, -1 do
    local c = line:sub(j, j)
    if c == ")" then
      depth = depth + 1
    elseif c == "(" then
      depth = depth - 1
    end
    if depth == 0 then
      -- Found the matching open paren
      local before = line:sub(1, j - 1)
      local inside = line:sub(j + 1, #line - 1) -- strip outer parens
      return before, inside
    end
  end
  return nil, nil
end

-- ============================================================================
-- SYMPY EVALUATION
-- Castel's original: type `sympy`, then an expression, then `sympy` + Tab
-- It evaluates the expression using Python's sympy and inserts LaTeX output.
-- Example: sympy expand((x+1)**3) sympy → x^{3} + 3x^{2} + 3x + 1
-- ============================================================================

local function eval_sympy(expr)
  local py_code = string.format([[
python3 -c "
from sympy import *
from sympy.parsing.sympy_parser import parse_expr
x, y, z, t, s, a, b, c, n, k = symbols('x y z t s a b c n k')
expr = parse_expr('%s')
print(latex(expr))
" 2>/dev/null
]], expr:gsub("'", "\\'"):gsub('"', '\\"'))
  local result = vim.fn.system(py_code)
  if vim.v.shell_error ~= 0 then
    return "\\text{sympy error}"
  end
  return vim.trim(result)
end

-- ============================================================================
-- MATHEMATICA EVALUATION
-- Same idea but using Wolfram's API-free approach via sympy
-- Castel used: math expression math → evaluated LaTeX
-- We approximate this with sympy's simplify
-- ============================================================================

local function eval_math_simplify(expr)
  local py_code = string.format([[
python3 -c "
from sympy import *
from sympy.parsing.sympy_parser import parse_expr
x, y, z, t, s, a, b, c, n, k = symbols('x y z t s a b c n k')
expr = parse_expr('%s')
print(latex(simplify(expr)))
" 2>/dev/null
]], expr:gsub("'", "\\'"):gsub('"', '\\"'))
  local result = vim.fn.system(py_code)
  if vim.v.shell_error ~= 0 then
    return "\\text{math error}"
  end
  return vim.trim(result)
end

local snippets = {}
local autosnippets = {

  -- ========================================================================
  -- PARENTHESIS-MATCHING FRACTION
  -- Triggers on any line ending with )/ where the parens are balanced
  -- ========================================================================
  s({
    trig = "^(.+%))/$",
    name = "Parenthesis fraction",
    regTrig = true,
    snippetType = "autosnippet",
    wordTrig = false,
    priority = 1000,
  },
  {
    d(1, function(_, snip)
      local line = snip.captures[1]
      -- line is everything before the `/`, including the closing `)`
      local before, inside = find_matching_paren(line)
      if before and inside then
        return sn(nil, {
          t(before .. "\\frac{" .. inside .. "}{"),
          i(1),
          t("}"),
        })
      else
        -- Fallback: couldn't match parens, just wrap everything
        return sn(nil, {
          t("\\frac{" .. line .. "}{"),
          i(1),
          t("}"),
        })
      end
    end),
    i(0),
  },
  { condition = in_mathzone }),

  -- ========================================================================
  -- SYMPY EVALUATION
  -- Type: sympy <expression> sympy → evaluates to LaTeX
  -- Example: sympy expand((x+1)**3) sympy → expands the polynomial
  -- ========================================================================
  s({
    trig = "sympy(.+)sympy",
    name = "Sympy evaluate",
    regTrig = true,
    snippetType = "autosnippet",
    wordTrig = false,
  },
  {
    f(function(_, snip)
      local expr = vim.trim(snip.captures[1])
      return eval_sympy(expr)
    end),
  }),

  -- ========================================================================
  -- MATH SIMPLIFY
  -- Type: math <expression> math → simplifies to LaTeX
  -- ========================================================================
  s({
    trig = "math(.+)math",
    name = "Math simplify",
    regTrig = true,
    snippetType = "autosnippet",
    wordTrig = false,
  },
  {
    f(function(_, snip)
      local expr = vim.trim(snip.captures[1])
      return eval_math_simplify(expr)
    end),
  }),

  -- ========================================================================
  -- SMART FRACTION WITH REGEX: 4\pi^2/ → \frac{4\pi^2}{}
  -- Matches: digits, letters, subscripts, superscripts followed by /
  -- This is the regex-based version (not parenthesis-based)
  -- ========================================================================
  s({
    trig = "(([%d]*)(\\?[A-Za-z]+)([_%^]?{?[%d]*}?))/",
    name = "Smart fraction",
    regTrig = true,
    snippetType = "autosnippet",
    wordTrig = false,
    priority = 500,
  },
  {
    f(function(_, snip) return "\\frac{" .. snip.captures[1] .. "}" end),
    t("{"), i(1), t("}"), i(0),
  },
  { condition = in_mathzone }),

}

return snippets, autosnippets
