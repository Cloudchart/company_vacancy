# Rules
#
Rules = """


  start =
    document

  source_character =
    .

  white_space =
    [\\u0009\\u000b\\u000c\\u0020\\u00a0]

  line_terminator =
    [\\u000a\\u000d\\u2028\\u2029]

  comment =
    '#' comment_char *

  comment_char =
    ! line_terminator source_character

  comma =
    ','

  token =
    punctuator / name / int_value / float_value / string_value

  ignored =
    white_space / line_terminator / comment / comma

  punctuator =
    [!$():=@[\\]{}] / '...'

  name =
    first:[_a-z]i rest:[_a-z0-9]i* {
      return first + rest.join('')
    }

  document =
    definition +

  definition =
    operation_definition / fragment_definition

  operation_definition =
    ignored* operation_type:operation_type
    ignored* name:name
    ignored* variable_definitions:variable_definitions?
    ignored* (directive+)?
    ignored* selection_set:selection_set ignored* {
      return {
        operation_type:       operation_type,
        name:                 name,
        variable_definition:  variable_definitions,
        selection_set:        selection_set
      }
    }

  operation_type =
    'query' / 'mutation'

  selection_set =
    ignored* '{' ignored* selections:(selection+)? ignored* '}' ignored* {
      return selections
    }

  selection =
    field / fragment_spread / inline_fragment

  field =
    ignored* alias:alias?
    ignored* name:name
    ignored* arguments:arguments?
    ignored* directives:directives?
    ignored* selection_set:selection_set? ignored* {
      return {
        name:           name,
        arguments:      arguments,
        directives:     directives,
        selection_set:  selection_set
      }
    }

  arguments =
    ignored* '(' ignored* argument+ ignored* ')' ignored*

  argument =
    ignored* name ignored* ':' ignored* value ignored*

  alias =
    ignored* name ignored* ':' ignored*

  fragment_spread =
    '...' fragment_name directives?

  fragment_definition =
    'fragment' fragment_name 'on' type_condition directives? selection_set

  fragment_name =
    ! 'on' name

  type_condition =
    named_type

  value =
    variable / int_value / float_value / string_value / boolean_value / enum_value / list_value / object_value

  inline_fragment =
    '...' 'on' type_condition (directive+)? selection_set

  int_value =
    integer_part

  integer_part =
    negative_sign? '0' / negative_sign? non_zero_digit (digit+)?

  negative_sign =
    '-'

  digit =
    [0-9]

  non_zero_digit =
    ! '0' digit

  float_value =
    integer_part fractional_part / integer_part exponent_part / integer_part fractional_part exponent_part

  fractional_part =
    digit+

  exponent_part =
    exponent_indicator sign? (digit+)?

  exponent_indicator =
    [e]i

  sign =
    [-+]

  boolean_value =
    'true' / 'false'

  string_value =
    '"' '"' / '"' string_character+ '"'

  string_character =
    ! ('"' / '\' / line_terminator) source_character / '\' escaped_unicode / '\' escaped_character

  escaped_unicode =
    'u' [0-9a-f]i [0-9a-f]i [0-9a-f]i [0-9a-f]i

  escaped_character =
    '"' / '\' / '/' / [bfnrt]

  enum_value =
    ! ('true' / 'false' / 'null') name

  list_value =
    '[' ']' / '[' value+ ']'

  object_value =
    '{' '}' / '{' object_field+ '}'

  object_field =
    name ':' value

  variable =
    '$' name

  variable_definitions =
    ignored* '(' ignored* variable_definition+ ignored* ')' ignored*

  variable_definition =
    ignored* variable ignored* ':' ignored* type ignored* default_value? ignored*

  default_value =
    '=' value

  type =
    named_type / list_type / non_null_type

  named_type =
    name

  list_type =
    '[' type ']'

  non_null_type =
    named_type '!' / list_type '!'

  directives =
    directive+

  directive =
    '@' name arguments?

"""


# Parser
#
Parser = PEG.buildParser(Rules)


# Exports
#
module.exports = Parser
