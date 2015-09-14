module.exports = {
  context:  __dirname + '/app/assets/frontend',
  entry:    './index.js',
  output: {
    filename:   '[name].bundle.js',
    path:       __dirname + '/app/assets/max-javascripts'
  },

  module: {

    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel',
        query: {
          stage: 0,
          optional: ['runtime'],
          plugins: [
            __dirname + '/app/assets/frontend/babel_relay_plugin.js'
          ]
        }
      }
    ]

  },

  resolve: {
    extensions: ['', '.js']
  }
}
