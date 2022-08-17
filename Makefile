parser.js: parser.pegjs
	peggy $^

clean:
	rm -f parser.js
