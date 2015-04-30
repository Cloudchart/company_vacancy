# Mutation
#
###

  UpdateUserAttributes(:full_name, :avatar, :remove_avatar, :company, :occupation) {

    user {

      emails {
        count,
        edges {
          node {
            cursor,
            address
          }
        }
      },

      roles(limit: 5) {
        count,
        edges {
          node {
            cursor,
            value,
            owner_id,
            owner_type
          }
        }
      }

    }

  }

###


Primer = """

  UpdateUserAttributes(
    first_name
    last_name
    full_name
    avatar
    remove_avatar
    occupation
    company
  ) {

    user {}

  }

"""


Parser = require('cloud_relay/mutation_parser')

console.log JSON.stringify Parser.parse(Primer, QueryParser: require('cloud_relay/query_parser'))


class Mutation




# Exports
#
module.exports = Mutation
