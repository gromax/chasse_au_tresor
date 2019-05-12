const webpack = require('webpack');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const UglifyJsPlugin = require("uglifyjs-webpack-plugin");
const CopyWebpackPlugin = require('copy-webpack-plugin');
const path = require('path');
const merge = require('webpack-merge');
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const DashboardPlugin = require("webpack-dashboard/plugin");
const HtmlWebpackPlugin = require('html-webpack-plugin');

const devMode = process.env.NODE_ENV !== 'production'
const devLiveReload = process.env.NODE_LIVERELOAD == 'active'


let config = {
  entry: [
    "tether",
    'font-awesome/scss/font-awesome.scss',
    "./dev/initialize.js"
  ],
  output: {
    path: path.resolve(__dirname, "public"),
    filename: devMode ? "app.js" : "app.[contentHash]."+require("./package.json").version+".js"
  },
  resolve: {
    alias:{
      'app$': path.resolve(__dirname, 'dev/components/app.coffee'),
      'apps': path.resolve(__dirname, 'dev/components/apps'),
      'entities': path.resolve(__dirname, 'dev/components/entities'),
      'templates': path.resolve(__dirname, 'dev/templates'),
      "jquery-ui": path.resolve(__dirname, 'node_modules/jquery-ui/ui/widgets'),
    }
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: "babel-loader"
      },
      {
        test: /\.(sa|sc|c)ss$/,
        use: [
          devMode ? 'style-loader' : MiniCssExtractPlugin.loader,
          'css-loader',
          'postcss-loader',
          'sass-loader',
        ],
      },
      {
        test: /bootstrap\/dist\/js\/umd\//, use: 'imports-loader?jQuery=jquery'
      },
      {
        test: /\.coffee$/,
        use: [
          {
            loader: 'coffee-loader',
            options: {
              transpile: {
                presets: ['env']
              }
            }
          }
        ]
      },
      {
        test: /\.tpl$/,
        loader: 'underscore-template-loader'
      },
      {
        test: /font-awesome\.config\.js/,
        use: [
          { loader: 'style-loader' },
          { loader: 'font-awesome-loader' }
        ]
      },
      {
        test: /\.woff2?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        use: 'url-loader?limit=10000',
      },
      {
        test:/\.(eot|ttf|svg)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        //test: /\.(ttf|eot|svg)(\?[\s\S]+)?$/,
        use: 'file-loader',
      },
      {
        test: /\.(jpe?g|png|gif|svg)$/i,
        use: [
          'file-loader?name=images/[name].[ext]',
          'image-webpack-loader?bypassOnDebug'
        ]
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: devMode ? '[name].css' : '[name].[contentHash].css',
      chunkFilename: devMode ? '[id].css' : '[id].[contentHash].css',
    }),
    new CopyWebpackPlugin([
      //{
      //  from: devMode ? './dev/assets/.htaccess.local' : './dev/assets/.htaccess.server',
      //  to: './.htaccess'
      //},
      {
        from: devMode ? './dev/assets/dev/.htaccess' : './dev/assets/prod/.htaccess'
      },
      {
        from: './dev/assets/favicon.ico',
        to: './favicon.ico'
      },
      {
        from: './dev/assets/favicon.png',
        to: './favicon.png'
      },
      {
        from: './dev/assets/api.php',
        to: './api.php'
      },
      {
        from: './dev/assets/image.php',
        to: './image.php'
      }
    ]),
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      'window.jQuery': 'jquery',
      tether: 'tether',
      Tether: 'tether',
      'window.Tether': 'tether',
      Popper: ['popper.js', 'default'],
      _: 'underscore',
      'Backbone': 'backbone',
      Alert: 'exports-loader?Alert!bootstrap/js/dist/alert',
      Button: 'exports-loader?Button!bootstrap/js/dist/button',
      Carousel: 'exports-loader?Carousel!bootstrap/js/dist/carousel',
      Collapse: 'exports-loader?Collapse!bootstrap/js/dist/collapse',
      Dropdown: 'exports-loader?Dropdown!bootstrap/js/dist/dropdown',
      Modal: 'exports-loader?Modal!bootstrap/js/dist/modal',
      Popover: 'exports-loader?Popover!bootstrap/js/dist/popover',
      Scrollspy: 'exports-loader?Scrollspy!bootstrap/js/dist/scrollspy',
      Tab: 'exports-loader?Tab!bootstrap/js/dist/tab',
      Tooltip: "exports-loader?Tooltip!bootstrap/js/dist/tooltip",
      Util: 'exports-loader?Util!bootstrap/js/dist/util'
    }),
    new DashboardPlugin(),
    new HtmlWebpackPlugin({
      title: 'Chasse au trésor',
      filename: 'index.php',
      template: 'dev/index.php'
    }),
    new webpack.DefinePlugin({
      VERSION: JSON.stringify(require("./package.json").version)
    })
  ],
  devServer: {
    contentBase: path.resolve(__dirname, "./public"),
    historyApiFallback: {
      rewrites: [
        { from: /^\/api\/session/, to: '/api.php' }
      ]
    },
    inline: true,
    open: true,
    hot: true
  },
  devtool: "eval-source-map"
}

if (devLiveReload) {
	var LiveReloadPlugin = require('webpack-livereload-plugin');
	config.plugins.push(new LiveReloadPlugin());
}

module.exports = config;



if (process.env.NODE_ENV === 'production') {
  module.exports.optimization = {
    minimizer: [
      new UglifyJsPlugin({
        cache: true,
        parallel: true,
        sourceMap: true // set to true if you want JS source maps
      }),
      new OptimizeCSSAssetsPlugin({})
    ]
  }

}


