#!/bin/bash

set -e

elm-test
elm make src/Main.elm --optimize --output=tmp.js
elm-format --yes src tests
elm-review
uglifyjs tmp.js --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output static/main.js
rm tmp.js
tidy -im static/index.html
