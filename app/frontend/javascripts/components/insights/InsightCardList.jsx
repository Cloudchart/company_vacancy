import React from 'react';
import Relay from 'react-relay';

import InsightCard from './InsightCard';

const ANIMATION_DURATION = 750;
const ANIMATION_DELAY = 1000 * 3;

class InsightCardList extends React.Component {

  constructor (props) {
    super(props);

    this.state = {
      index: 0
    };
  }

  componentDidMount () {
    setTimeout(this.switchInsights.bind(this), ANIMATION_DELAY);
  }

  componentDidUpdate () {
    setTimeout(this.switchInsights.bind(this), ANIMATION_DELAY);
  }

  switchInsights () {
    let headerNode = this.refs.header;
    let [currHeaderNode, nextHeaderNode] = headerNode.childNodes;
    let currTop = currHeaderNode.getBoundingClientRect().top;
    let nextTop = nextHeaderNode.getBoundingClientRect().top;
    move(currHeaderNode).y(currTop - nextTop).set('opacity', 0).duration(ANIMATION_DURATION).end();
    move(nextHeaderNode).y(currTop - nextTop).set('opacity', 1).duration(ANIMATION_DURATION).end();

    let insightsNode = this.refs.insights;
    Array.prototype.forEach.call(insightsNode.childNodes, (node) => {
      let [currInsightNode, nextInsightNode] = node.childNodes;
      let currTop = currInsightNode.getBoundingClientRect().top;
      let nextTop = nextInsightNode.getBoundingClientRect().top;
      move(currInsightNode).y(currTop - nextTop).set('opacity', 0).duration(ANIMATION_DURATION).end();
      move(nextInsightNode).y(currTop - nextTop).set('opacity', 1).duration(ANIMATION_DURATION).end();
    });

    setTimeout(this.incrementIndex.bind(this), ANIMATION_DURATION);
  }

  incrementIndex () {
    this.setState({
      index: (this.state.index + 1) % this.props.collections.length
    });
  }

  renderHeader () {
    let nextIndex = (this.state.index + 1) % this.props.collections.length;
    let currCollection = this.props.collections[this.state.index];
    let nextCollection = this.props.collections[nextIndex];

    return (
      <h1 className="content-block__head content-block__head_big" key={ currCollection.id } ref="header">
        <a className="through" href={ currCollection.url }>{ currCollection.title }</a>
        <span>{ nextCollection.title }</span>
      </h1>
    );
  }

  renderInsights () {
    let nextIndex = (this.state.index + 1) % this.props.collections.length;
    let insightsCurr = this.props.collections[this.state.index].insights.edges;
    let insightsNext = this.props.collections[nextIndex].insights.edges;

    return insightsCurr.map((insight, i) => {
      let nextInsight = insightsNext[i];
      return (
        <li className="insights__list-el" key={ insight.node.id }>
          <InsightCard insight={ insight.node } />
          <InsightCard insight={ nextInsight.node } />
        </li>
      );
    });
  }

  render () {
    return (
      <div className="insights">
        { this.renderHeader() }
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
