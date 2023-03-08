-- desolate.nvim
--
-- Copyright 2022 He4eT
-- Copyright 2021 Kim Silkebækken
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

local lush = require("lush")
local hsl = lush.hsl

-- Config params

local params = {
	contrast = (tonumber(vim.g.desolate_contrast) or 110) / 100,
	base_color = hsl(
		tonumber(vim.g.desolate_h) or 15,
		tonumber(vim.g.desolate_s) or 5,
		tonumber(vim.g.desolate_l) or 50),

	fg = vim.g.desolate_fg,
	bg = vim.g.desolate_bg,

	constant = vim.g.desolate_constant,
	identifier = vim.g.desolate_identifier,
	statement = vim.g.desolate_statement,

	error = vim.g.desolate_error or '#ff0000',
	warning = vim.g.desolate_warning or '#ffff00',
	success = vim.g.desolate_success or '#00ff00',
	info = vim.g.desolate_info or '#0000ff',
}

-- Offset function

local offset_fn = "lighten"
if vim.o.background == "light" then
	offset_fn = "darken"
	params.base_color = params.base_color.darken(50)
end

-- Main colors

local colors = {}

-- Monochrome shades

local shade = function(base_color, contrast, offset)
	return base_color[offset_fn](contrast * offset)
end

local offsets = { 50, 20, 10, 0, -10, -25, -45, -60, -70 }
for i, offset in pairs(offsets) do
	colors[i] = shade(params.base_color, params.contrast, offset)
end

-- Logical colors

local useHex = function(hexColor, fallback)
	if hexColor then
		return hsl(hexColor)
	else
		return fallback
	end
end

colors.nt = params.base_color

colors.fg = useHex(
	params.fg,
	shade(params.base_color, params.contrast, 100))

colors.bg = useHex(
	params.bg,
	shade(params.base_color, params.contrast, -100))

colors.constant = useHex(
	params.constant,
	colors[0])

colors.identifier = useHex(
	params.identifier,
	colors[1])

colors.statement = useHex(
	params.statement,
	colors[2])

colors.error = hsl(params.error)
colors.warning = hsl(params.warning)
colors.success = hsl(params.success)
colors.info = hsl(params.info)

-- Highlights

---@diagnostic disable: undefined-global
return lush(function()
	return {
		Normal({ fg = colors.fg, bg = colors.bg }), -- Normal text

		SyntaxError({ fg = colors.error }),
		SyntaxWarning({ fg = colors.warning }),
		SyntaxInfo({ fg = colors.info }),
		SyntaxHint({ fg = colors.success }),

		Comment({ fg = colors[6] }), -- any comment
		ColorColumn({ bg = colors[6] }), -- used for the columns set with 'colorcolumn'
		Conceal({}), -- placeholder characters substituted for concealed text (see 'conceallevel')
		Cursor({ fg = colors.bg, bg = colors.identifier }), -- character under the cursor
		-- CursorI({}), -- insert cursor TODO make this based on other colors
		-- CursorR({}), -- replace cursor
		-- CursorO({}), -- operator-pending cursor
		-- lCursor({}), -- the character under the cursor when |language-mapping| is used (see 'guicursor')
		-- CursorIM({}), -- like Cursor, but used when in IME mode |CursorIM|
		-- CursorColumn({}), -- Screen-column at the cursor, when 'cursorcolumn' is set.
		CursorLine({ bg = Normal.bg[offset_fn](2) }), -- Screen-line at the cursor, when 'cursorline' is set.  Low-priority if foreground (ctermfg OR guifg) is not set.
		Directory({ fg = colors.info }), -- directory names (and other special names in listings)
		DiffAdd({ fg = colors.success }), -- diff mode: Added line |diff.txt|
		DiffChange({ fg = colors.warning }), -- diff mode: Changed line |diff.txt|
		DiffDelete({ fg = colors.error }), -- diff mode: Deleted line |diff.txt|
		DiffText({ fg = colors.info, bg = colors.error }), -- diff mode: Changed text within a changed line |diff.txt|
		-- EndOfBuffer({}), -- filler lines (~) after the end of the buffer.  By default, this is highlighted like |hl-NonText|.
		-- TermCursor({}), -- cursor in a focused terminal
		-- TermCursorNC({}), -- cursor in an unfocused terminal
		Error({ fg = colors.error }), -- (preferred) any erroneous construct
		ErrorMsg({ fg = colors.error }), -- error messages on the command line
		VertSplit({ fg = colors[8] }), -- the column separating vertically split windows
		Folded({ fg = colors[3], bg = colors[9] }), -- line used for closed folds
		FoldColumn({}), -- 'foldcolumn'
		SignColumn({}), -- column where |signs| are displayed
		IncSearch({ fg = colors.bg, bg = colors.identifier }), -- 'incsearch' highlighting; also used for the text replaced with ":s///c"
		-- Substitute({}), -- |:substitute| replacement text highlighting
		LineNr({ fg = colors[6] }), -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
		CursorLineNr({ fg = colors[1] }), -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line.
		MatchParen({ fg = colors.constant, gui = "underline" }), -- The character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
		ParenMatch({ MatchParen }),
		ModeMsg({}), -- 'showmode' message (e.g., "-- INSERT -- ")
		MsgArea({}), -- Area for messages and cmdline
		MsgSeparator({}), -- Separator for scrolled messages, `msgsep` flag of 'display'
		MoreMsg({ fg = colors.identifier, gui = "bold" }), -- |more-prompt|
		NonText({ fg = colors.nt }), -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
		NormalFloat({ bg = colors[7], fg = colors[1] }), -- Normal text in floating windows.
		FloatBorder({ NormalFloat }), -- Borders in floating windows.
		NormalNC({}), -- Normal text in non-current windows
		Pmenu({ NormalFloat }), -- Popup menu: Normal item.
		PmenuSel({ fg = colors.bg, bg = colors.fg }), -- Popup menu: selected item.
		PmenuSbar({ bg = colors[6] }), -- Popup menu: scrollbar.
		PmenuThumb({ bg = colors[3] }), -- Popup menu: Thumb of the scrollbar.
		Question({}), -- |hit-enter| prompt and yes/no questions
		QuickFixLine({}), -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
		Search({ fg = colors.bg, bg = colors.identifier }), -- Last search pattern highlighting (see 'hlsearch').  Also used for similar items that need to stand out.
		SpecialKey({ gui = "bold" }), -- Unprintable characters: text displayed differently from what it really is.  But not 'listchars' whitespace. |hl-Whitespace|
		SpellBad({ SyntaxError }), -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
		SpellCap({ SyntaxInfo }), -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
		SpellLocal({ SyntaxHint }), -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
		SpellRare({ SyntaxWarning }), -- Word that is recognized by the spellchecker as one that is hardly ever used.  |spell| Combined with the highlighting used otherwise.
		StatusLine({ fg = colors.fg, bg = colors.bg }), -- status line of current window
		StatusLineNC({ fg = colors[6], bg = colors.bg }), -- status lines of not-current windows Note: if this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.
		TabLine({ fg = colors[3] }), -- tab pages line, not active tab page label
		TabLineFill({ fg = colors[3] }), -- tab pages line, where there are no labels
		TabLineSel({ fg = colors[1], gui = "bold" }), -- tab pages line, active tab page label
		Title({ gui = "bold" }), -- titles for output from ":set all", ":autocmd" etc.
		Visual({ fg = colors.bg, bg = colors.fg }), -- Visual mode selection
		-- VisualNOS({}), -- Visual mode selection when vim is "Not Owning the Selection".
		Warning({ fg = colors.warning }), -- warning messages
		WarningMsg({ Warning }), -- warning messages
		Whitespace({ fg = colors[7] }), -- "nbsp", "space", "tab" and "trail" in 'listchars'
		WildMenu({ fg = colors[6], bg = colors.fg }), -- current match in 'wildmenu' completion

		Constant({ fg = colors.constant }), -- (preferred) any constant
		-- String({}), -- a string constant: "this is a string"
		-- Character({}), -- a character constant: 'c', '\n'
		-- Number({}), -- a number constant: 234, 0xff
		-- Boolean({}), -- a boolean constant: TRUE, false
		-- Float({}), -- a floating point constant: 2.3e10

		Identifier({ fg = colors.identifier }), -- (preferred) any variable name
		-- Function({}), -- function name (also: methods for classes)

		Statement({ fg = colors.statement }), -- (preferred) any statement
		-- Conditional({}), -- if, then, else, endif, switch, etc.
		-- Repeat({}), -- for, do, while, etc.
		-- Label({}), -- case, default, etc.
		-- Operator({}), -- "sizeof", "+", "*", etc.
		-- Keyword({}), -- any other keyword
		-- Exception({}), -- try, catch, throw

		PreProc({}), -- (preferred) generic Preprocessor
		-- Include({}), -- preprocessor #include
		-- Define({}), -- preprocessor #define
		-- Macro({}), -- same as Define
		-- PreCondit({}), -- preprocessor #if, #else, #endif, etc.

		Type({}), -- (preferred) int, long, char, etc.
		StorageClass({}), -- static, register, volatile, etc.
		Structure({}), -- struct, union, enum, etc.
		Typedef({}), -- A typedef

		Special({ fg = colors.statement }), -- (preferred) any special symbol
		-- SpecialChar({}), -- special character in a constant
		-- Tag({}), -- you can use CTRL-] on this
		-- Delimiter({}), -- character that needs attention
		-- SpecialComment({}), -- special things inside a comment
		-- Debug({}), -- debugging statements

		Underlined({ gui = "underline" }), -- (preferred) text that stands out, HTML links
		Bold({ gui = "bold" }),
		Italic({ gui = "italic" }),

		-- Ignore({}), -- (preferred) left blank, hidden  |hl-Ignore|

		Todo({ fg = colors.identifier, gui = "bold" }), -- (preferred) anything that needs extra attention; mostly the keywords TODO FIXME and XXX

		LspReferenceText({ fg = colors.statement }), -- used for highlighting "text" references
		LspReferenceRead({ fg = colors.statement }), -- used for highlighting "read" references
		LspReferenceWrite({ fg = colors.success }), -- used for highlighting "write" references

		IndentBlanklineChar({ fg = colors[8] }),
		IndentBlanklineContextChar({ fg = colors.nt }),

		DiagnosticError({ fg = colors.error }), -- Used as the base highlight group. Other LspDiagnostic highlights link to this by default (except Underline)
		DiagnosticWarn({ fg = colors.warning }), -- Used as the base highlight group. Other LspDiagnostic highlights link to this by default (except Underline)
		DiagnosticInfo({ fg = colors.info }), -- Used as the base highlight group. Other LspDiagnostic highlights link to this by default (except Underline)
		DiagnosticHint({ fg = colors.success }), -- Used as the base highlight group. Other LspDiagnostic highlights link to this by default (except Underline)

		-- LspDiagnosticsVirtualTextError({}), -- Used for "Error" diagnostic virtual text
		-- LspDiagnosticsVirtualTextWarning({}), -- Used for "Warning" diagnostic virtual text
		-- LspDiagnosticsVirtualTextInformation({}), -- Used for "Information" diagnostic virtual text
		-- LspDiagnosticsVirtualTextHint({}), -- Used for "Hint" diagnostic virtual text

		DiagnosticUnderlineError({ SyntaxError }), -- Used to underline "Error" diagnostics
		DiagnosticUnderlineWarn({ SyntaxWarning }), -- Used to underline "Warning" diagnostics
		DiagnosticUnderlineInfo({ SyntaxInfo }), -- Used to underline "Information" diagnostics
		DiagnosticUnderlineHint({ SyntaxHint }), -- Used to underline "Hint" diagnostics

		-- LspDiagnosticsFloatingError({}), -- Used to color "Error" diagnostic messages in diagnostics float
		-- LspDiagnosticsFloatingWarning({}), -- Used to color "Warning" diagnostic messages in diagnostics float
		-- LspDiagnosticsFloatingInformation({}), -- Used to color "Information" diagnostic messages in diagnostics float
		-- LspDiagnosticsFloatingHint({}), -- Used to color "Hint" diagnostic messages in diagnostics float

		DiagnosticSignError({ fg = colors.error }), -- Used for "Error" signs in sign column
		DiagnosticSignWarning({ fg = colors.warning }), -- Used for "Warning" signs in sign column
		DiagnosticSignInformation({ fg = colors.info }), -- Used for "Information" signs in sign column
		DiagnosticSignHint({ fg = colors.success }), -- Used for "Hint" signs in sign column

		-- Treesitter

		-- TSAnnotation({}), -- For C++/Dart attributes, annotations that can be attached to the code to denote some kind of meta information.
		-- TSAttribute({}), -- (unstable) TODO: docs
		-- TSBoolean({}), -- For booleans.
		-- TSCharacter({}), -- For characters.
		-- TSComment({}), -- For comment blocks.
		-- TSConstructor({}), -- For constructor calls and definitions: ` { }` in Lua, and Java constructors.
		-- TSConditional({}), -- For keywords related to conditionnals.
		-- TSConstant({}), -- For constants
		-- TSConstBuiltin({}), -- For constant that are built in the language: `nil` in Lua.
		-- TSConstMacro({}), -- For constants that are defined by macros: `NULL` in C.
		-- TSError({}), -- For syntax/parser errors.
		-- TSException({}), -- For exception related keywords.
		-- TSField({}), -- For fields.
		-- TSFloat({}), -- For floats.
		-- TSFunction({}), -- For function (calls and definitions).
		-- TSFuncBuiltin({}), -- For builtin functions: `table.insert` in Lua.
		-- TSFuncMacro({}), -- For macro defined fuctions (calls and definitions): each `macro_rules` in Rust.
		-- TSInclude({}), -- For includes: `#include` in C, `use` or `extern crate` in Rust, or `require` in Lua.
		-- TSKeyword({}), -- For keywords that don't fall in previous categories.
		-- TSKeywordFunction({}), -- For keywords used to define a fuction.
		-- TSLabel({}), -- For labels: `label:` in C and `:label:` in Lua.
		-- TSMethod({}), -- For method calls and definitions.
		-- TSNamespace({}), -- For identifiers referring to modules and namespaces.
		-- TSNone({}), -- TODO: docs
		-- TSNumber({}), -- For all numbers
		-- TSOperator({}), -- For any operator: `+`, but also `->` and `*` in C.
		-- TSParameter({}), -- For parameters of a function.
		-- TSParameterReference({}), -- For references to parameters of a function.
		TSProperty({}), -- Same as `TSField`.
		-- TSPunctDelimiter({}), -- For delimiters ie: `.`
		-- TSPunctBracket({}), -- For brackets and parens.
		-- TSPunctSpecial({}), -- For special punctutation that does not fall in the catagories before.
		-- TSRepeat({}), -- For keywords related to loops.
		-- TSString({}), -- For strings.
		TSStringRegex({ fg = colors[1] }), -- For regexes.
		TSStringEscape({ fg = colors.fg, gui = "bold" }), -- For escape characters within a string.
		-- TSSymbol({}), -- For identifiers referring to symbols or atoms.
		-- TSType({}), -- For types.
		-- TSTypeBuiltin({}), -- For builtin types.
		-- TSVariable({}), -- Any variable name that does not have another highlight.
		-- TSVariableBuiltin({}), -- Variable names that are defined by the languages, like `this` or `self`.
		-- TSTag({}), -- Tags like html tag names.
		-- TSTagDelimiter({}), -- Tag delimiter like `<` `>` `/`
		-- TSText({}), -- For strings considered text in a markup language.
		-- TSEmphasis({}), -- For text to be represented with emphasis.
		-- TSUnderline({}), -- For text to be represented with an underline.
		-- TSStrike({}), -- For strikethrough text.
		-- TSTitle({}), -- Text that is part of a title.
		-- TSLiteral({}), -- Literal text.
		-- TSURI({}), -- Any URI like a link or email.

		IndentBlankLineContextStart({ gui = "underline", sp = colors.nt }),
		TreesitterContext({ fg = colors[3] }),

		-- Lightspeed
		LightspeedGreyWash({ Comment }),
		LightspeedLabel({ fg = colors.statement }),
		LightspeedOverlapped({ fg = colors.statement.darken(15), gui = "underline" }),
		LightspeedLabelDistant({ fg = colors.identifier, gui = "underline" }),
		LightspeedLabelDistantOverlapped({ fg = colors.identifier.darken(15), gui = "underline" }),
		LightspeedShortcut({ fg = colors.identifier }),
		LightspeedShortcutOverlapped({ LightspeedShortcut }),
		LightspeedMaskedChar({ fg = colors.fg, gui = "none" }),
		LightspeedUnlabeledMatch({ fg = colors.fg, gui = "bold" }),
		LightspeedOneCharMatch({ LightspeedShortcut, gui = "none" }),
		LightspeedUniqueChar({ LightspeedUnlabeledMatch }),
		LightspeedPendingOpArea({ LightspeedShortcut, gui = "underline" }),

		-- Leap
		LeapBackdrop({ Comment }),
		LeapLabelPrimary({ Identifier }),
		LeapMatch({ Constant }),
		LeapLabelSecondary({ Statement }),

		-- Dirty fixes
		typescriptParens({ NormalFloat })
	}
end)
