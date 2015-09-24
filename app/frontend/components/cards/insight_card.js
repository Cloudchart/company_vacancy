import React from 'react'
import Relay from 'react-relay'


const MaxContentLength = 230

let stripContent = (content) =>
  content.length > MaxContentLength + 3 ? content.substring(0, MaxContentLength) + '...' : content


class InsightCard extends React.Component {

  render = () =>
    <div className="insight-card">
      <p className="content">
        <a href={ this.props.insight.url } className="through">
          { stripContent(this.props.insight.content) }
        </a>
      </p>
      <ul className="controls">
        <li className="user">
          <a href={ this.props.insight.user.url }>
            { this.props.insight.user.full_name }
          </a>
        </li>
      </ul>
    </div>

}

export default Relay.createContainer(InsightCard, {

  fragments: {
    insight: () => Relay.QL`
      fragment on Insight {
        content
        url
        user {
          full_name
          url
        }
      }
    `
  }

})
