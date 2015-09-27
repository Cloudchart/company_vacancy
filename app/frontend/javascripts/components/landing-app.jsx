import React from 'react';
import Relay from 'react-relay';

import Header from './shared/header';

import InsightCardList from './insights/InsightCardList';

import CollectionSlab from './cards/CollectionSlab';
import CollectionSlabList from './cards/CollectionSlabList';

import UserSlab from './cards/user_slab';
import ContentButton from './shared/ContentButton';


// Featured User
//
let renderFeaturedUser = (user) =>
  <UserSlab user={ user } key={ user.id } />

// Featured Users
//
let renderFeaturedUsers = (users) =>
  <section className="content-block content-block_margin" key="featured-users">
    <h2>
      We research interviews, books and social media posts
      by successfull entrepreneurs, find the most important
      insights and collect them for you to use.
    </h2>
    <section className="users-slabs">
      { users.map(renderFeaturedUser) }
    </section>
  </section>

// Landing App Component
//
class LandingApp extends React.Component {
  render () {
    return (
      <article className="landing-app">
        <Header />
        <section className="super-feature">
          <section className="background" />
          <section className="content-block content-block_overflow">
            <h2 className="content-block__head content-block__head_small">learn how to</h2>
            <InsightCardList collections={ this.props.viewer.super_featured_collections } />
          </section>
          <section className="content-block content-block_margin">
            <ContentButton />
          </section>
        </section>
        <section className="content-block content-block_margin">
  	      <h2 className="content-block__head_small">
  	        Find insights you need.
  	        Use them on meetings, brainstorms or discussions.
  	        Follow collections you're interested in.
  	      </h2>
          <CollectionSlabList items={ this.props.viewer.featured_collections } />
	      </section>
        { renderFeaturedUsers(this.props.viewer.featured_users) }
        <section className="content-block content-block_margin">
          <ContentButton />
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
          ${InsightCardList.getFragment("collections")}
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
