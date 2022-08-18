env_file =
	blank_line* assignments ";"? env_file { } /
	blank_line* blank* comment? { }


assignments =
	blank* assignment assignments? { }

assignment =
	n:name "=" v:word {
		if (!options.noact)
			process.env[n] = v;
	}

name =
	h:[A-Za-z_] t:[0-9A-Za-z_]* {
		return h + t.join("");
	}

word =
	h:(variable_expansion / escaped_char / single_quoted_string / double_quoted_string / literal_char) t:word {
		return h + t;
	} /
	""

variable_expansion =
	"$" n:(name / "{" n:name "}" { return n; }) {
		if (!(n in process.env)) {
			if (options.nounset)
				throw n + ": unbound variable";
			else
				return "";
		}

		return process.env[n];
	}

escaped_char =
	escaped_special_char /
	"\\" c:. {
		return c;
	}

escaped_special_char =
	"\\\n" {
		return "";
	} /
	"\\" c:[$`\\"] {
		return c;
	}

single_quoted_string =
	"'" s:[^']* "'" {
		return s.join("");
	}

double_quoted_string =
	"\"" s:inside_double_quotes "\"" {
		return s;
	}

inside_double_quotes =
	h:(variable_expansion / escaped_special_char / [^$`"]) t:inside_double_quotes {
		return h + t;
	} /
	""

literal_char =
	[^|&;<>()$`\\"' \t\n]

blank_line =
	blank* comment? "\n"

blank =
	[ \t]

comment =
	"#" [^\n]*
