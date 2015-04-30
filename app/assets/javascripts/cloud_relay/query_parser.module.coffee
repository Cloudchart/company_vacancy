# Rules
#
Rules = """


  start =
    space?


  space =
    [ \\t\\n\\r]+


"""


# Parser
#
Parser = PEG.buildParser(Rules)


# Exports
#
module.exports = Parser
