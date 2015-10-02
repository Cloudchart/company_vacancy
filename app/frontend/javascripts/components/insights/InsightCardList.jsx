import React from 'react';
import Relay from 'react-relay';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';

import InsightCard from './InsightCard';

const ANIMATION_DURATION = 750;
const ANIMATION_DELAY = 3000;


export default class InsightCardList extends React.Component {
  static defaultProps = {
    collections: []
  };

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
    setTimeout(this._incrementIndex.bind(this), ANIMATION_DELAY + ANIMATION_DURATION);
  }

  componentDidUpdate () {
    this._switchInsights();
  }

  render () {
    let nextIndex = (this.state.index + 1) % this.props.collections.length;

    let currCollection = this.props.collections[this.state.index];
    let nextCollection = this.props.collections[nextIndex];

    let insightsCurr = currCollection.insights.edges;
    let insightsNext = nextCollection.insights.edges;

    let items = insightsCurr.map((curr, i) => {
      let next = insightsNext[i];
      return (
        <li className="insights__list-el" key={ curr.node.id }>
          <InsightCard insight={ curr.node } />
          <InsightCard insight={ next.node } />
        </li>
      )
    });

    return (
      <div className="insights">
        <ReactCSSTransitionGroup component="h1"
                                 className="content-block__head content-block__head_big insights__head"
                                 transitionName="insights__head-label"
                                 transitionEnterTimeout={ ANIMATION_DURATION }
                                 transitionLeaveTimeout={ ANIMATION_DURATION }>
          <a className="through insights__head-label"
             href={ currCollection.url }
             key={ currCollection.id }>{ currCollection.title }</a>
        </ReactCSSTransitionGroup>
        <ul className="insights__list" ref="insights">{ items }</ul>
      </div>
    );
  }
};
