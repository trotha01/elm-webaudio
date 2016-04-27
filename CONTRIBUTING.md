# COMPILE EXAMPLES

To run the examples locally, you can use `elm-reactor` from the root folder to see Scales.elm and Stream.elm

Or

From the root folder, you can run `elm-make examples/Scales.elm` and `elm-make examples/Stream.elm` to generate an index.html file


To build the Visual.elm example, run from the root folder `elm-make examples/Visual.elm --output examples/Visual.js`.
You can use `python -m SimpleHTTPServer 8080` to start a small http server and navigate to http://localhost:8080/examples/Visual.html

NOTE: you will need to add a soundcloud id to examples/Visual.html for that example to work
