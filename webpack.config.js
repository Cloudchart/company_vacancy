module.exports = {

  context: __dirname + '/app/frontend',

  entry: './javascripts/main.js',

  output: {
    path: __dirname + '/app/assets/javascripts',
    filename: '[name].bundle.js'
  },

  module: {

    loaders: [
      { test: /\.js$/, exclude: /node_modules/, loader: 'babel' },
      { test: /\.coffee$/, loader: 'coffee-jsx' }
    ]

  },

  resolve: {
    extensions: ['', '.js', '.coffee']
  }

}
