module.exports = 
	entry: "./src/index.coffee"
	output:
		pathinfo:true
		path: "dist"
		filename: "script.js"
	module:
		loaders: [
					test: /\.vs$/
					loader: "raw-loader"
				,
					test: /\.fs$/
					loader: "raw-loader"
				,
					test: /\.coffee$/
					loader: "coffee-loader"
				,
					test: /\.litcoffee$/
					loader: "coffee-loader?literate"
				,
					test: /\.sass$/
					loader: (require "extract-text-webpack-plugin").extract "style-loader", "css-loader!sass-loader?indentedSyntax"
				,
          {test: /\.json$/, loader:'json-loader'}
			]
	plugins: [
				new (require "clean-webpack-plugin") "dist"
			,
				new (require "extract-text-webpack-plugin") "[hash].css"
			,
				new (require "html-webpack-plugin")
					templateContent: (templateParams, compilation) ->
						require("jade").renderFile "./src/index.jade", templateParams
		]