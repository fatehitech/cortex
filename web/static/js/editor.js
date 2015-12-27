$(function() {
  let el = document.getElementById('thing_code')
  if (el) 
    CodeMirror.fromTextArea(el, {
      lineNumbers: true,
    });
})
