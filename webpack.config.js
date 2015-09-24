var path = require('path');

module.exports = {
  context: path.resolve(__dirname, './app/frontend'),
  entry: './index.js',
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname,  './app/assets/max-javascripts'),
    sourceMapFilename: '[name].js.map'
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
            path.resolve(__dirname, './app/frontend/babel_relay_plugin.js')
          ]
        }
      }
    ]
  },
  resolve: {
    extensions: ['', '.js']
  }
};
