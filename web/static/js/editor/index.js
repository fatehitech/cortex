import "./elixir"
import "./lint"
import ElixirLinter from "./elixir-lint"

let Editor = {
  init(socket, el){
    if (!el){ return }
    el = $(el).get(0);

    function getOpts(el) {
      return {
        lineNumbers: true,
        indentWithTabs: false,
        tabSize: 2,
        indentUnit: 2,
        mode: "elixir",
        theme: "tomorrow-night-bright",
        readOnly: $(el).attr('readonly') ? "nocursor" : false,
        gutters: ["CodeMirror-lint-markers"],
        lint: { async: true }
      }
    }

    if (el.tagName === "TEXTAREA") {
      let editor = CodeMirror.fromTextArea(el, getOpts(el))
      socket.connect()
      let editorChannel = socket.channel("editor:linter")
      editorChannel.join()
      ElixirLinter.init(editorChannel)
    } else {
      let code = $(el).text() 
      let container = $(el).parent().get(0);
      $(el).remove();
      let opts = getOpts(el);
      opts.value = code;
      CodeMirror(container, opts);
    }
  },
}

export default Editor;
