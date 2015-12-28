import "./elixir"

function getOpts(el) {
  return {
    lineNumbers: true,
    indentWithTabs: false,
    tabSize: 2,
    indentUnit: 2,
    mode: "elixir",
    theme: "tomorrow-night-bright",
    readOnly: $(el).attr('readonly') ? "nocursor" : false
  }
}

$(function() {
  let el = $('.editor').get(0)
  if (el) {
    if (el.tagName === "TEXTAREA") {
      CodeMirror.fromTextArea(el, getOpts(el));
    } else {
      let code = $(el).text() 
      let container = $(el).parent().get(0);
      $(el).remove();
      let opts = getOpts(el);
      opts.value = code;
      console.log(opts)
      CodeMirror(container, opts);
    }
  }
})
