// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "deps/phoenix_html/web/static/js/phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import socket from "./socket"
import Editor from "./editor"
import TimeSeries from "./time-series"

let editors = $('.editor');
if (editors.length) {
  socket.connect()
  let editorChannel = socket.channel("editor:lobby")
  editorChannel.join()
  let name = $("#thing_firmware_name").val() || "Something"
  editors.each(function(_i, el) {
    console.log(el);
    Editor.init(editorChannel, name, el)
  });
}

// cool this works -- can be used to make graphs
//TimeSeries.init({
//  server: [
//    {
//      protocol: "http",
//      host:     "localhost",
//      port:     8086
//    }
//  ],
//  username: "",
//  password: "",
//
//  database: "uno"
//});
