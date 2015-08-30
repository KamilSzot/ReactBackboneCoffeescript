path = require 'path'
HtmlWebpackPlugin = require 'html-webpack-plugin'
ExtractTextPlugin = require 'extract-text-webpack-plugin'
webpack = require 'webpack'
module.exports =
  entry:
    bootstrap: [ './bootstrap-init', 'jquery', 'bootstrap', 'react-bootstrap' ]
    vendor: [ 'jquery', 'react', 'react-dom', 'lodash', 'backbone']
    app: [ 'webpack/hot/only-dev-server', './main' ]
  output: {
    path: path.join __dirname, 'build'
    filename: '[name]-[hash].js'
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
          loader: ExtractTextPlugin.extract("style-loader", "css-loader!less-loader")
        }
        {
          test: /\.css$/,
          loader: ExtractTextPlugin.extract("style-loader", "css-loader")
        }
        {
            test: /\.(eot|woff|woff2|ttf|svg|png|jpg)$/,
            loader: 'file-loader?name=[name]-[hash].[ext]'
        }
    ]
  plugins: [
    new HtmlWebpackPlugin
      template: 'index.html'
      inject: 'body'
    new webpack.optimize.CommonsChunkPlugin "vendor", "vendor-[hash].js"
    new ExtractTextPlugin("[name]-[hash].css")

  ]
  devServer:
    contentBase: "./build",
  devtool: 'sourcemaps'
