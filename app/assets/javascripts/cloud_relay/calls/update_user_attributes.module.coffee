# Parser
#
Parser = require('cloud_relay/mutation_parser')


# Call
#
module.exports = Parser.parse """

  UpdateUserAttributes(

    id

    full_name
    first_name
    last_name

    company
    occupation

    avatar
    remove_avatar

  ) {

    user {
      id
      full_name
      company
      occupation
      avatar_url
    }

  }

"""
