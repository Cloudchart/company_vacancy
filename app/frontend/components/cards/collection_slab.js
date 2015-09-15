import React from 'react'
import Relay from 'react-relay'


let pluralize = (count, singular, plural) => `${count} ${count == 1 ? singular : plural}`


class CollectionSlab extends React.Component {

  render = () =>
    <div className="collection-slab">
      <a href={ this.props.collection.url } className="through">
        { this.props.collection.title }
        <em className="caps">{ pluralize(this.props.collection.insights.count, 'insight', 'insights') }</em>
      </a>
    </div>

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
