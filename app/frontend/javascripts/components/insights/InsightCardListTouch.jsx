import React from 'react';
import Relay from 'react-relay';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';

import InsightCard from './InsightCard';

const ANIMATION_DURATION = 750;
const ANIMATION_DELAY = 3000;


export default class InsightCardListTouch extends React.Component {
  static defaultProps = {
    collections: []
  };

  constructor (props) {
    super(props);

    this.state = {
      collectionIndex: 0,
      collectionItemIndex: 0
    };
  }

  _incrementIndex () {
    let collection = this.props.collections[this.state.collectionIndex];
    let nextCollectionIndex = this.state.collectionIndex;
    let nextCollectionItemIndex = this.state.collectionItemIndex + 1;

    if (nextCollectionItemIndex >= collection.insights.edges.length) {
      nextCollectionIndex = (this.state.collectionIndex + 1) % this.props.collections.length;
      nextCollectionItemIndex = 0;
    }


    this.setState({
      collectionIndex: nextCollectionIndex,
      collectionItemIndex: nextCollectionItemIndex
    });
  }

  componentDidMount () {
    setTimeout(this._incrementIndex.bind(this), ANIMATION_DELAY + ANIMATION_DURATION);
  }

  componentDidUpdate () {
    setTimeout(this._incrementIndex.bind(this), ANIMATION_DELAY + ANIMATION_DURATION);
  }

  render () {
    let collection = this.props.collections[this.state.collectionIndex];
    let insight = collection.insights.edges[this.state.collectionItemIndex];

    return (
      <div className="insights">
        <h1 className="content-block__head content-block__head_big insights__head">
          <ReactCSSTransitionGroup className="insights__head-label__animation"
                                   transitionName="insights__head-label"
                                   transitionEnterTimeout={ ANIMATION_DURATION }
                                   transitionLeaveTimeout={ ANIMATION_DURATION }>
            <a className="through insights__head-label"
               href={ collection.url }
               key={ collection.id }>{ collection.title }</a>
          </ReactCSSTransitionGroup>
        </h1>
        <ReactCSSTransitionGroup component="ul"
                                 className="insights__list"
                                 transitionName="insights__list-el"
                                 transitionEnterTimeout={ ANIMATION_DURATION }
                                 transitionLeaveTimeout={ ANIMATION_DURATION }>
          <li className="insights__list-el" key={ insight.node.id }>
            <InsightCard insight={ insight.node } />
          </li>
        </ReactCSSTransitionGroup>
      </div>
    );
  }
};
