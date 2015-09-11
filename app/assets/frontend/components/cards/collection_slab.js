import React from 'react'
import Relay from 'react-relay'

class CollectionSlab extends React.Component {

  render = () => {
    return (
      <div className="collection-slab">
        <a href={ this.props.collection.url }>
          <strong>{ this.props.collection.title }</strong>
          <em>{ this.props.collection.insights.count } insights</em>
        </a>
      </div>
    )
  }

}

export default Relay.createContainer(CollectionSlab, {

  fragments: {
    collection: () => Relay.QL`
      fragment on Collection {
        title
        url
        insights {
          count
        }
      }
    `
  }

})
