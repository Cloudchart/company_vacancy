import Relay from 'react-relay'

export default class extends Relay.Route {

  static routeName = 'ViewerRoute'

  static queries = {
    viewer: (Component) => Relay.QL`
      query Viewer {
        viewer {
          ${Component.getFragment('viewer')}
        }
      }
    `
  }
}
