RULE = """


  start =
    ws result:field ws {
      return result
    }


// Commons

  ws = [ \\t\\n\\r]*


// Fields


  fields =
    first:field rest:(ws ','? ws field:field { return field })* { return [first].concat(rest) }


  field =
    name:variable arguments:arguments? children:(ws '{' ws fields:fields? ws '}' ws { return fields })? {
      return { kind: "Field", name: name, arguments: arguments, children: children }
    }


// Arguments

  arguments =
    '(' ws
      arguments:(
        first:argument
        rest:(ws ',' ws argument:argument { return argument })* { return [first].concat(rest) }
      )?
    ws ')' { return arguments }

  argument =
    name:variable ':' ws value:string {
      return { kind: "Argument", name: name, value: value }
    }


// Variable

  variable =
    first:[_a-z]i rest:[_a-z0-9]i* {
      return first + rest.join('')
    }


// String

  string =
    quote characters:character* quote { return characters.join('') }

  character =
      unescaped
    / escape sequence:(
        quote
      / escape
      / '/'
      / 'b' { return '\\b' }
      / 'f' { return '\\f' }
      / 'n' { return '\\n' }
      / 'r' { return '\\r' }
      / 't' { return '\\t' }
      / 'u' digits:$(hexdigit hexdigit hexdigit hexdigit) { return String.fromCharCode(parseInt(digits, 16)) }
    )

  unescaped       = [\\x20-\\x21\\x23-\\x5B\\x5D-\\u10FFFF]
  escape          = '\\\\'
  quote           = '"'
  hexdigit        = [0-9a-f]i

"""

module.exports = PEG.buildParser(RULE)
