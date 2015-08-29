path = require 'path'
HtmlWebpackPlugin = require 'html-webpack-plugin'
webpack = require 'webpack'
module.exports =
  entry: [
      'webpack-dev-server/client?http://localhost:3000',
      'webpack/hot/only-dev-server',
      './main'
  ]
  output: {
    path: path.join __dirname, 'build'
    filename: '[name].js'
  }
  resolve: {
    extensions: ['', '.js', '.cjsx', '.coffee']
  }
  module:
    loaders: [
        { test: /(\.cjsx)$/, loaders: ['react-hot', 'coffee', 'cjsx']},
        { test: /\.coffee$/, loader: "coffee-loader" },
        { test: /\.(coffee\.md|litcoffee)$/, loader: "coffee-loader?literate" },
        {
          test: /\.less$/,
          loader: "style!css!less"
        }
        {
            test: /\.(eot|woff|woff2|ttf|svg|png|jpg)$/,
            loader: 'url-loader?limit=30000&name=[name]-[hash].[ext]'
        }
    ]
  plugins: [
    new HtmlWebpackPlugin
      template: 'index.html'
      inject: 'body'
#    new webpack.HotModuleReplacementPlugin()
  ]
  devServer:
    contentBase: "./build",
  devtool: 'sourcemaps'
