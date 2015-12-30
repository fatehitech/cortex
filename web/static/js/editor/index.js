import "./elixir"
import "./lint"
import ElixirLinter from "./elixir-lint"

let Editor = {
  init(socket, el) {
    el = $(el).get(0);
    if (!el){ return }

    let defaults = {
      lineNumbers: true,
      indentWithTabs: false,
      tabSize: 2,
      indentUnit: 2,
      mode: "elixir",
      theme: "tomorrow-night-bright",
    }

    if (el.tagName === "TEXTAREA") {
      let editor = CodeMirror.fromTextArea(el, _.assign({}, defaults, {
        gutters: ["CodeMirror-lint-markers"],
        lint: { async: true }
      }))
      socket.connect()
      let editorChannel = socket.channel("editor:linter")
      editorChannel.join()
      ElixirLinter.init(editorChannel)
    } else {
      let code = $(el).text() 
      let container = $(el).parent().get(0);
      $(el).remove();
      CodeMirror(container, _.assign({}, defaults, {
        readOnly: "nocursor",
        value: code
      }));
    }
  }
}

export default Editor;
