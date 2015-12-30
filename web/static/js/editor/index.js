import "./elixir"
import "./lint"

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
      let editor;

      socket.connect()
      let editorChannel = socket.channel("editor:lobby")
      editorChannel.join()

      let boilerplateButton = (label, preset) => {
        return $('<button>').text(label).click(function(e) {
          e.preventDefault()
          editorChannel.push("boilerplate", {
            preset: preset,
            name: $("#thing_firmware_name").val()
          })
          .receive("ok", ({code}) => editor.setValue(code))
        })
      }

      let toolbar = $('<div>')
      toolbar.append([
        boilerplateButton('Firmata', 'firmata'),
        boilerplateButton('Nerves', 'nerves')
      ])

      $(el).before(toolbar)

      editor = CodeMirror.fromTextArea(el, _.assign({}, defaults, {
        gutters: ["CodeMirror-lint-markers"],
        lint: { async: true }
      }))
      window.editor = editor;

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
