import "./elixir"
import "./lint"

let Editor = {
  init(editorChannel, name, el) {
    el = $(el).get(0);
    if (!el){ return }

    let defaults = {
      lineNumbers: true,
      indentWithTabs: false,
      tabSize: 2,
      indentUnit: 2,
      mode: "elixir",
      theme: "tomorrow-night-bright",
      smartIndent: false
    }

    let toolbar = $('<div>').addClass('toolbar')

    if (el.tagName === "TEXTAREA") {
      let editor = CodeMirror.fromTextArea(el, _.assign({}, defaults, {
        gutters: ["CodeMirror-lint-markers"],
        lint: { async: true }
      }))

      let boilerplateButton = (label, preset) => {
        return $('<button>').text(label).click(function(e) {
          e.preventDefault()
          editorChannel.push("boilerplate", {
            preset: preset,
            name: name 
          })
          .receive("ok", ({code}) => editor.setValue(code))
        })
      }

      let distractionFree = () => {
        let title = "Distraction Free Mode";
        let button = $('<button>')
        return button.text(title).click(function(e) {
          e.preventDefault()
          let wrapper = $(editor.display.wrapper)
          if (wrapper.hasClass('distraction-free')) {
            wrapper.removeClass('distraction-free');
            toolbar.removeClass('distraction-free');
            button.text(title)
          } else {
            wrapper.addClass('distraction-free');
            toolbar.addClass('distraction-free')
            button.text(`Leave ${title}`)
          }
          editor.refresh()
        })
      }


      toolbar.append([
        boilerplateButton('Series Starter', 'series'),
        boilerplateButton('Firmata Starter', 'firmata'),
        boilerplateButton('Standalone Starter', 'standalone'),
        distractionFree(),
      ])
      $(editor.display.wrapper).before(toolbar)

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
      let name = $(el).data('name');
      console.log(name);
      $(el).remove();
      let editor = CodeMirror(container, _.assign({}, defaults, {
        readOnly: "nocursor",
        value: code
      }));

      let buttonReset = () => {
        return $('<button>').text("Reset").click(function(e) {
          e.preventDefault()
          editorChannel.push("reset_device", {name: name})
        })
      }

      let buttonSend = (title, message) => {
        return $('<button>').text(title).click(function(e) {
          e.preventDefault()
          editorChannel.push("send_thing", {name: name, message: message})
        })
      }

      let buttonCall = (title, message, cb) => {
        return $('<button>').text(title).click(function(e) {
          e.preventDefault()
          editorChannel.push("call_thing", {name: name, message: message})
          .receive("error", err => cb(err))
          .receive("ok", res => cb(null, res.data))
        })
      }

      toolbar.append([
        buttonReset(),
        buttonSend("Send Blink", "blink"),
        buttonCall("Get LED State", "led_state", (err, data) => err ? alert(err) : alert(data))
      ])

      $(editor.display.wrapper).before(toolbar)
    }
  }
}

export default Editor;
