const path = require('path');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const AnyBarWebpackPlugin = require('anybar-webpack');
const webpack = require('webpack');

module.exports = {
  context: path.resolve(__dirname, './app/frontend/javascripts'),
  entry: {
    main: path.resolve(__dirname, './app/frontend/javascripts/index.js'),
    style: path.resolve(__dirname, './app/frontend/javascripts/style.js'),
  },
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname,  './app/frontend/bundles'),
    sourceMapFilename: '[name].bundle.js.map'
  },
  resolve: {
    extensions: ['', '.js', '.jsx', '.scss'],
    alias: {
      vars: path.resolve(__dirname, './app/frontend/stylesheets/_vars.scss')
    }
  },
  module: {
    loaders: [
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'url-loader?limit=10000&minetype=application/font-woff'
      }, {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: 'file-loader'
      }, {
        test: /\.png|jpg|jpeg$/,
        loader: 'file-loader'
      }, {
        test: /\.js|jsx$/,
        exclude: /node_modules/,
        loader: 'babel',
        query: {
          stage: 0,
          optional: ['runtime'],
          plugins: [
            path.resolve(__dirname, './app/frontend/javascripts/babel_relay_plugin.js')
          ]
        }
      }, {
        test: /\.scss$/,
        loader: ExtractTextPlugin.extract('style-loader', [
          'css-loader',
          `sass-loader?outputStyle=${[
            'expanded',
            `includePaths[]=${path.resolve(__dirname, './app/frontend/stylesheets')}`,
            `includePaths[]=${path.resolve(__dirname, './node_modules')}`
          ].join('&')}`
        ].join('!')),
      }
    ]
  },

  plugins: [
    new ExtractTextPlugin('[name].css', {
      omit: 1,
      extract: true,
      remove: true
    }),
    // new webpack.optimize.UglifyJsPlugin({}),
    new AnyBarWebpackPlugin()
  ]
};
