import React from 'react';
import Relay from 'react-relay';

import Header from './shared/header';
import SuperFeaturedCollections from './shared/super_featured_collections';
import CollectionSlab from './cards/collection_slab';
import UserSlab from './cards/user_slab';


// Super Featured Collections
//
let renderSuperFeaturedCollections = (collections) =>
  <section className="super-feature">
    <section className="background" />
    <SuperFeaturedCollections collections={ collections } />
    { renderGetAccess() }
  </section>


// Featured Collection
//
let renderFeaturedCollection = (collection) =>
  <CollectionSlab collection={ collection } key={ collection.id} />

// Featured Collections
//
let renderFeaturedCollections = (collections) =>
  <section className="content-block" key='featured-collections'>
    <h2>
      Find insights you need.
      Use them on meetings, brainstorms or discussions.
      Follow collections you're interested in.
    </h2>
    <section className="collections-slabs">
      { collections.map(renderFeaturedCollection) }
    </section>
  </section>


// Featured User
//
let renderFeaturedUser = user =>
  <UserSlab user={ user } key={ user.id } />

// Featured Users
//
let renderFeaturedUsers = (users) =>
  <section className="content-block" key="featured-users">
    <h2>
      We research interviews, books and social media posts
      by successfull entrepreneurs, find the most important
      insights and collect them for you to use.
    </h2>
    <section className="users-slabs">
      { users.map(renderFeaturedUser) }
    </section>
  </section>


// Get Access button
//
let renderGetAccess = () =>
  <section className="content-block get-access" key="get-access">
    <button className="opaque" onClick={ handleGetAccessClick }>Get Access</button>
    <p>Requires Twitter account. Free while in beta.</p>
  </section>

// Handle Get Access button click
//
let handleGetAccessClick = (event) => window.location = '/login'


// Landing App Component
//
class LandingApp extends React.Component {

  render () {
    return (
      <article className="landing-app">
        <Header />
        { renderSuperFeaturedCollections(this.props.viewer.super_featured_collections) }
        { renderFeaturedCollections(this.props.viewer.featured_collections) }
        { renderFeaturedUsers(this.props.viewer.featured_users) }
        { renderGetAccess() }
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
          ${SuperFeaturedCollections.getFragment("collections")}
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
