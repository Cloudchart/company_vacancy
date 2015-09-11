import React from 'react'
import Relay from 'react-relay'

import CollectionSlab from './cards/collection_slab'


function renderFeaturedCollections(collections) {

  collections = collections.map((collection) => {
    return (
      <li key={ collection.id }>
        <CollectionSlab collection={ collection } />
      </li>
    )
  })

  return (
    <div className="content-block">
      <h2>
        Find insights you need.
        Use them on meetings, brainstorms or discussions.
        Follow collections you're interested in.
      </h2>
      <ul>
        { collections }
      </ul>
    </div>
  )

}


class LandingApp extends React.Component {

  render = () => {
    return (
      renderFeaturedCollections(this.props.viewer.featured_collections)
    )
  }

}

export default Relay.createContainer(LandingApp, {

  fragments: {
    viewer: () => Relay.QL`
      fragment on User {
        full_name
        featured_collections(scope: "main") {
          id
          ${CollectionSlab.getFragment('collection')}
        }
      }
    `
  }

})
