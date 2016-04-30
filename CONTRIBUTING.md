# Running the Examples

To run the examples locally (except for Visual.elm):
```
cd elm-webaudio
elm-reactor
```

To compile the examples locally:
```
cd elm-webaudio
elm-make examples/Simple.elm --output simple.html
elm-make examples/Scales.elm --output scales.html
elm-make examples/Stream.elm --output stream.html
```


## Visual.elm

NOTE: you will need to add a soundcloud id to examples/Visual.html for that example to work

To compile the Visual.elm example:
```
cd elm-webaudio
elm-make examples/Visual.elm --output examples/Visual.js
```

To see the Visual.elm example locally, you can use the simple python server
```
python -m SimpleHTTPServer 8080
```
Now navigate to http://localhost:8080/examples/Visual.html

