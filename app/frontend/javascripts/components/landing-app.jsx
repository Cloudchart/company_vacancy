import React from 'react';
import Relay from 'react-relay';

import Header from './shared/Header';

import InsightsContainer from './insights/InsightsContainer';

import CollectionSlab from './slabs/CollectionSlab';
import CollectionSlabList from './slabs/CollectionSlabList';

import UserSlab from './users/UserSlab';
import UserSlabList from './users/UserSlabList';

import ContentButton from './shared/ContentButton';


// Landing App Component
//
class LandingApp extends React.Component {
  render () {
    return (
      <article className="landing-app">
        <Header />

        <section className="landing-app__block landing-app__block_full landing-app__block_back">
          <section className="background" />
          <section className="content-block content-block_overflow">
            <h2 className="content-block__head content-block__head_small">learn how to</h2>
            <InsightsContainer collections={ this.props.viewer.super_featured_collections } />
          </section>
          <section className="content-block content-block_margin content-block_padding">
            <ContentButton />
          </section>
        </section>

        <section className="landing-app__block landing-app__block_padding">
          <section className="content-block content-block_margin">
    	      <h2 className="content-block__head_margin content-block__head_small content-block__head">
    	        Find insights you need.
    	        Use them on meetings, brainstorms or discussions.
    	        Follow collections you're interested in.
    	      </h2>
            <CollectionSlabList items={ this.props.viewer.featured_collections } />
  	      </section>

          <section className="content-block content-block_margin" key="featured-users">
            <h2 className="content-block__head content-block__head_small content-block__head_margin">
              We research interviews, books and social media posts
              by successfull entrepreneurs, find the most important
              insights and collect them for you to use.
            </h2>
            <UserSlabList items={ this.props.viewer.featured_users }/>
          </section>

          <section className="content-block content-block_margin">
            <ContentButton />
          </section>
        </section>
      </article>
    );
  }
};

// Landing App Relay Container
//
export default Relay.createContainer(LandingApp, {
  fragments: {
    viewer: () => Relay.QL`
      fragment on User {
        full_name
        super_featured_collections(scope: "main") {
          ${InsightsContainer.getFragment("collections")}
        }
        featured_collections(scope: "main") {
          id
          ${CollectionSlab.getFragment('collection')}
        }
        featured_users(scope: "main") {
          id
          ${UserSlab.getFragment('user')}
        }
      }
    `
  }
});
