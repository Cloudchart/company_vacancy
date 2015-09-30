import React from 'react';
import Relay from 'react-relay';
import ReactDOM from 'react-dom';

import ReactTransitionGroup from 'react-addons-transition-group';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';

import InsightCard from './InsightCard';

const ANIMATION_DURATION = 750;
const ANIMATION_DELAY = 3000;


class InsightCardList extends React.Component {

  constructor (props) {
    super(props);

    this.state = {
      index: 0
    };
  }

  _switchInsights () {
    let insightsNode = this.refs.insights;
    Array.prototype.forEach.call(insightsNode.childNodes, (node) => {
      let [currInsightNode, nextInsightNode] = node.childNodes;
      let currTop = currInsightNode.getBoundingClientRect().top;
      let nextTop = nextInsightNode.getBoundingClientRect().top;
      move(currInsightNode).y(currTop - nextTop).set('opacity', 0).duration(ANIMATION_DURATION).end();
      move(nextInsightNode).y(currTop - nextTop).set('opacity', 1).duration(ANIMATION_DURATION).end();
    });
    setTimeout(this._incrementIndex.bind(this), ANIMATION_DELAY + ANIMATION_DURATION);
  }

  _incrementIndex () {
    this.setState({
      index: (this.state.index + 1) % this.props.collections.length
    });
  }

  componentDidMount () {
    setTimeout(this._incrementIndex.bind(this), ANIMATION_DELAY);
  }

  componentDidUpdate () {
    this._switchInsights();
  }

  renderInsights () {
    let nextIndex = (this.state.index + 1) % this.props.collections.length;
    let insightsCurr = this.props.collections[this.state.index].insights.edges;
    let insightsNext = this.props.collections[nextIndex].insights.edges;

    return insightsCurr.map((curr, i) => {
      let next = insightsNext[i];
      return (
        <li className="insights__list-el" key={ curr.node.id }>
          <InsightCard insight={ curr.node } />
          <InsightCard insight={ next.node } />
        </li>
      )
    });
  }

  render () {
    let currCollection = this.props.collections[this.state.index];
    let currInsights = this.props.collections[this.state.index].insights.edges;

    return (
      <div className="insights">
        <h1 className="content-block__head content-block__head_big insights__head">
          <ReactCSSTransitionGroup className="insights__head-label__animation"
                                   transitionName="insights__head-label"
                                   transitionEnterTimeout={ ANIMATION_DURATION }
                                   transitionLeaveTimeout={ ANIMATION_DURATION }>
            <a className="through insights__head-label"
               href={ currCollection.url }
               key={ currCollection.id }>{ currCollection.title }</a>
          </ReactCSSTransitionGroup>
        </h1>
        <ul className="insights__list" ref="insights">
          { this.renderInsights() }
        </ul>
      </div>
    );
  }
};

export default Relay.createContainer(InsightCardList, {
  fragments: {
    collections: () => Relay.QL`
      fragment on Collection @relay(plural: true) {
        id
        title
        url
        insights(first: 3) {
          edges {
            node {
              id
              ${InsightCard.getFragment('insight')}
            }
          }
        }
      }
    `
  }
});
