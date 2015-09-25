const path = require('path');
const ExtractTextPlugin = require("extract-text-webpack-plugin");

module.exports = {
  context: path.resolve(__dirname, './app/frontend'),
  entry: {
    main: path.resolve(__dirname, './app/frontend/index.js')
  },

  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname,  './app/assets/bundles'),
    sourceMapFilename: '[name].js.map'
  },

  module: {
    loaders: [
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'url-loader?limit=10000&minetype=application/font-woff'
      },
      {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'file-loader'
      },
      {
        test: /\.png|jpg|jpeg$/,
        loader: 'file-loader'
      },
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
      },
      {
        test: /\.scss$/,
        loader: ExtractTextPlugin.extract('style-loader', [
          'css-loader',
          `sass-loader?outputStyle=${[
            'expanded',
            `includePaths[]=${path.resolve(__dirname, './app/assets/stylesheets')}`,
            `includePaths[]=${path.resolve(__dirname, './node_modules')}`
          ].join('&')}`
        ].join('!')),
      }
    ]
  },
  resolve: {
    extensions: ['', '.js', '.scss']
  },
  plugins: [
    new ExtractTextPlugin("[name].css", {'omit': 1, 'extract': true, 'remove': true})
  ]
};
