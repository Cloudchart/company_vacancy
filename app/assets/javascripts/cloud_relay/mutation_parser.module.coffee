# Rules
#
Rules = """


  start =
    query


  query =
    space? node:node space? {
      return node
    }


  node =
    name:name arguments:arguments? fields:fields? {
      return {
        name:       name,
        arguments:  arguments || [],
        fields:     fields || []
      }
    }


  fields =
    space? '{' space? fields:(field)* space? '}' space? {
      return fields
    }


  field =
    ','? query:query {
      return query
    }


  arguments =
    '(' arguments:(argument)* named_arguments:(named_argument)* ')' space? {
      return arguments.concat(named_arguments)
    }


  argument =
    ','? space? name:name [^:] {
      return name
    }


  named_argument =
    ','? space? name:name ':' space? value:name space? {
      var data    = {}
      data[name]  = value
      return data
    }


  name =
    characters:(letter / digit / '-' / '_')+ {
      return characters.join('')
    }


  letter =
    [a-z]i


  digit =
    [0-9]


  space =
    [ \\t\\n\\r]+



"""


# Parser
#
Parser = PEG.buildParser(Rules)


# Exports
#
module.exports = Parser
