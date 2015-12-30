// CodeMirror, copyright (c) by Marijn Haverbeke and others
// Distributed under an MIT license: http://codemirror.net/LICENSE

// Depends on jsonlint.js from https://github.com/zaach/jsonlint

// declare global: jsonlint
"use strict";

let ElixirLinter = {
  init(editorChannel) {
    CodeMirror.registerHelper("lint", "elixir", function(text, callback) {
      editorChannel.push("check_code", {code: text})
      .receive("error", ({line, description}) => {
        callback([{
          from: CodeMirror.Pos(line-1),
          to: CodeMirror.Pos(line-1),
          message: description
        }]);
      })
      .receive("ok", ()=>{
        callback([])
      })
    });
  }
}
export default ElixirLinter;
