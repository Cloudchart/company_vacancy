import React from 'react';
import Relay from 'react-relay';

import InsightCard from '../cards/insight_card';

const animationDuration = 750;
const animationDelay = 1000 * 3;


class SuperFeaturedCollections extends React.Component {

  constructor (props) {
    super(props);

    this.state = {
      index: 0
    };
  }

  componentDidMount () {
    setTimeout(this.switchInsights, animationDelay);
  }

  componentDidUpdate () {
    setTimeout(this.switchInsights, animationDelay);
  }

  switchInsights () {
    let headerNode = this.refs['header'];
    let [currHeaderNode, nextHeaderNode] = headerNode.childNodes;
    let currTop = currHeaderNode.getBoundingClientRect().top;
    let nextTop = nextHeaderNode.getBoundingClientRect().top;
    move(currHeaderNode).y(currTop - nextTop).set('opacity', 0).duration(animationDuration).end();
    move(nextHeaderNode).y(currTop - nextTop).set('opacity', 1).duration(animationDuration).end();

    let insightsNode = this.refs['insights'];
    Array.prototype.forEach.call(insightsNode.childNodes, (node) => {
      let [currInsightNode, nextInsightNode] = node.childNodes;
      let currTop = currInsightNode.getBoundingClientRect().top;
      let nextTop = nextInsightNode.getBoundingClientRect().top;
      move(currInsightNode).y(currTop - nextTop).set('opacity', 0).duration(animationDuration).end();
      move(nextInsightNode).y(currTop - nextTop).set('opacity', 1).duration(animationDuration).end();
    });

    setTimeout(this.incrementIndex, animationDuration);
  }

  incrementIndex () {
    this.setState({
      index: (this.state.index + 1) % this.props.collections.length
    });
  }

  render () {
    return (
      <section className="content-block">
        <h2>learn how to</h2>
        { this.renderHeader() }
        <ul className="insights" ref="insights">
          { this.renderInsights() }
        </ul>
      </section>
    );
  }


  renderHeader () {
    let nextIndex = (this.state.index + 1) % this.props.collections.length;
    let currCollection = this.props.collections[this.state.index];
    let nextCollection = this.props.collections[nextIndex];

    return (
      <h1 key={ currCollection.id } ref="header">
        <a className="through" href={ currCollection.url }>{ currCollection.title }</a>
        <span>{ nextCollection.title }</span>
      </h1>
    );
  }


  renderInsights () {
    let nextIndex = (this.state.index + 1) % this.props.collections.length;

    return this.props.collections[this.state.index].insights.edges.map((insight, i) => {
      let nextInsight = this.props.collections[nextIndex].insights.edges[i]
      return (
        <li key={ insight.node.id }>
          <InsightCard insight={ insight.node } />
          <InsightCard insight={ nextInsight.node } />
        </li>
      )
    })
  }
};

export default Relay.createContainer(SuperFeaturedCollections, {
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
