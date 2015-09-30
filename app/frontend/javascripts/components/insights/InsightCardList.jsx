import React from 'react';
import Relay from 'react-relay';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';

import InsightCard from './InsightCard';

const ANIMATION_DURATION = 750;
const ANIMATION_DELAY = 1e3 * 4;


class InsightCardList extends React.Component {

  constructor (props) {
    super(props);

    this.state = {
      index: 0
    };
  }

  componentDidMount () {
    // setTimeout(this._switchInsights.bind(this), ANIMATION_DELAY);
    setTimeout(this._incrementIndex.bind(this), ANIMATION_DELAY);
  }

  componentDidUpdate () {
    // setTimeout(this._switchInsights.bind(this), ANIMATION_DELAY);
    setTimeout(this._incrementIndex.bind(this), ANIMATION_DELAY);
  }

  // _switchInsights () {
  //   let insightsNode = this.refs.insights;
  //   Array.prototype.forEach.call(insightsNode.childNodes, (node) => {
  //     let [currInsightNode, nextInsightNode] = node.childNodes;
  //     let currTop = currInsightNode.getBoundingClientRect().top;
  //     let nextTop = nextInsightNode.getBoundingClientRect().top;
  //     move(currInsightNode).y(currTop - nextTop).set('opacity', 0).duration(ANIMATION_DURATION).end();
  //     move(nextInsightNode).y(currTop - nextTop).set('opacity', 1).duration(ANIMATION_DURATION).end();
  //   });
  //   setTimeout(this._incrementIndex.bind(this), ANIMATION_DURATION);
  // }

  _incrementIndex () {
    this.setState({
      index: (this.state.index + 1) % this.props.collections.length
    });
  }

  _renderInsightItem (insight, key) {
    if (!!insight) {
      return (
        <li className="insights__list-el" key={ key }>
          <ReactCSSTransitionGroup className="insight-card__animation"
                                   component="div"
                                   transitionName="insight-card"
                                   transitionAppearTimeout={ ANIMATION_DURATION }
                                   transitionEnterTimeout={ ANIMATION_DURATION }
                                   transitionLeaveTimeout={ ANIMATION_DURATION }>
            <InsightCard insight={ insight.node } key={ insight.node.id }/>
          </ReactCSSTransitionGroup>
        </li>
      );
    } else {
      return null;
    }
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
        <ul className="insights__list">
          { this._renderInsightItem(currInsights[0], 'first') }
          { this._renderInsightItem(currInsights[1], 'second') }
          { this._renderInsightItem(currInsights[2], 'third') }
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
