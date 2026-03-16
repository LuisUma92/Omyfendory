local ls = require("luasnip")
local utils = require("luasnip-latex-snippets.util.utils")
local s = ls.snippet
local sa = ls.extend_decorator.apply(ls.snippet, {}) --[[@as function]]
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- local ai = require("luasnip.nodes.absolute_indexer")
-- local extras = require("luasnip.extras")
-- local l = extras.lambda
-- local rep = extras.rep
-- local p = extras.partial
-- local m = extras.match
-- local n = extras.nonempty
-- local dl = extras.dynamic_lambda
-- local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local conds = require("luasnip.extras.expand_conditions")
-- local postfix = require("luasnip.extras.postfix").postfix
-- local types = require("luasnip.util.types")
-- local parse = require("luasnip.util.parser").parse_snippet
-- local ms = ls.multi_snippet
-- local k = require("luasnip.nodes.key_indexer").new_key
-- set a higher priority (defaults to 0 for most snippets)
-- local snip = ls.parser.parse_snippet(
--   { trig = "mk", name = "Math", condition = not_math, priority = 10 },
--   "$ ${1:${TM_SELECTED_TEXT}} $$0"
-- )
local pipe = utils.pipe
local is_math = utils.with_opts(utils.is_math, true)
local no_backslash = utils.no_backslash
local not_math = utils.with_opts(utils.not_math, true)

return {
  sa(
    {
      trig = "(%a+)vc",
      wordTrig = false,
      regTrig = true,
      name = "vec",
      snippetType = "autosnippet",
      condition = pipe({ is_math, no_backslash }),
      priority = 100,
    },
    f(function(_, snip)
      return string.format("\\vec{%s}", snip.captures[1])
    end, {})
  ),
  s({
    trig = "ss",
    condition = pipe({ is_math }),
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    t("\\scrp{"),
    i(1),
    t("}"),
    i(0),
  }),
  s({
    trig = "gg",
    snippetType = "autosnippet",
  }, {
    t("\\gls{"),
    i(0),
    t("}"),
  }),
  s({
    trig = "ii",
    snippetType = "autosnippet",
    wordTrig = false,
    condition = pipe({ is_math }),
  }, {
    t("\\hat{\\imath}"),
    i(0),
  }),
  s({
    trig = "jj",
    snippetType = "autosnippet",
    wordTrig = false,
    condition = pipe({ is_math }),
  }, {
    t("\\hat{\\jmath}"),
    i(0),
  }),
  s({
    trig = "kk",
    snippetType = "autosnippet",
    wordTrig = false,
    condition = pipe({ is_math }),
  }, {
    t("\\hat{k}"),
    i(0),
  }),
  s({
    trig = "nmm",
    snippetType = "autosnippet",
    wordTrig = false,
    condition = pipe({ is_math }),
  }, {
    t("\\num{"),
    i(1),
    t("}"),
    i(0),
  }),
  s({
    trig = "dd",
    snippetType = "autosnippet",
    wordTrig = false,
    condition = pipe({ is_math }),
  }, {
    t("\\dd{"),
    i(1),
    t("}"),
    i(0),
  }),
  s({
    trig = "vc",
    snippetType = "autosnippet",
    wordTrig = false,
    condition = pipe({ is_math }),
  }, {
    t("\\vc{"),
    i(1),
    t("}"),
    i(0),
  }),
  s({
    trig = "vh",
    snippetType = "autosnippet",
    wordTrig = false,
    condition = pipe({ is_math }),
  }, {
    t("\\hat{"),
    i(1),
    t("}"),
    i(0),
  }),
  s({
    trig = "aa",
    snippetType = "autosnippet",
    wordTrig = false,
    condition = pipe({ is_math }),
  }, {
    t("\\ang{"),
    i(1),
    t("}"),
    i(0),
  }),
  s({
    trig = "bf",
    snippetType = "autosnippet",
    condition = pipe({ is_math }),
  }, {
    t("\\bm{"),
    i(1),
    t("}"),
    i(0),
  }),
  s({
    trig = "bf",
    snippetType = "autosnippet",
    condition = pipe({ not_math }),
  }, {
    t("\\textbf{"),
    i(1),
    t("}"),
    i(0),
  }),
  s({
    trig = "prime",
    wordTrig = false,
    snippetType = "autosnippet",
    condition = pipe({ is_math }),
  }, {
    t("^{\\prime}"),
  }),
  s({
    trig = "equa",
  }, {
    t({ "\\begin{equation}", "  " }),
    i(2),
    t({ "", "\\label{eq:" }),
    r(1, "VISUAL"),
    t({ "}", "\\end{equation}" }),
    i(0),
  }),
  s({
    trig = "dl254",
  }, {
    t({ "\\begin{dinglist}{254}", "  \\item " }),
    i(0),
    t({ "", "\\end{dinglist}" }),
  }),
  s({
    trig = "dl228",
  }, {
    t({ "\\begin{dinglist}{228}", "  \\item " }),
    i(0),
    t({ "", "\\end{dinglist}" }),
  }),
  s({
    trig = "dl43",
  }, {
    t({ "\\begin{dinglist}{43}", "  \\item " }),
    i(0),
    t({ "", "\\end{dinglist}" }),
  }),
  s({
    trig = "--",
    wordTrig = false,
    snippetType = "autosnippet",
    condition = pipe({ not_math }),
  }, {
    t({ "", "\\item" }),
    i(0),
  }),
  s({
    trig = "item",
    condition = pipe({ not_math }),
  }, {
    t({ "\\begin{itemize}", "  \\item" }),
    i(0),
    t({ "", "\\end{itemize}" }),
  }),
  s({
    trig = "gath",
    snippetType = "autosnippet",
    condition = pipe({ not_math }),
  }, {
    t({ "\\begin{gather*}", "  " }),
    i(1),
    t({ " \\\\" }),
    i(0),
    t({ "", "\\end{gather*}" }),
  }),
  s({
    trig = "\\\\nl",
    wordTrig = false,
    snippetType = "autosnippet",
    condition = pipe({ is_math }),
  }, {
    t({ "\\\\", "" }),
    i(1),
    t({ " \\\\" }),
    i(0),
  }),
  s({
    trig = "dts",
  }, {
    t({ "Datos:", "\\[\\begin{array}{l}", "" }),
    i(0),
    t({ " \\\\", "\\end{array}\\]" }),
  }),
}
