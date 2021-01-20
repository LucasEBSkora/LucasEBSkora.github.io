// let selectionStart = document.querySelector("#source").selectionStart
// let selectionEnd = document.querySelector("#source").selectionEnd

document.querySelectorAll(".insert_button").forEach((button) => {
  button.onclick = (e) => {
    const textArea = document.querySelector("#source")
    const str = textArea.value
    const start = textArea.selectionStart
    const end = textArea.selectionEnd
    textArea.value = str.slice(0, start) + button.textContent + str.slice(end);
  }
  button.onfocus = (e) => {
    e.preventDefault()
    if (e.relatedTarget) {
      e.relatedTarget.focus()
      // setSelectionRange(e.relatedTarget, selectionStart, selectionEnd)
    }
    else
      e.currentTarget.blur()
  }
})

// function setSelectionRange(input, selectionStart, selectionEnd) {
//   if (input.setSelectionRange) {
//     input.focus();
//     input.setSelectionRange(selectionStart, selectionEnd);
//   }
//   else if (input.createTextRange) {
//     var range = input.createTextRange();
//     range.collapse(true);
//     range.moveEnd('character', selectionEnd);
//     range.moveStart('character', selectionStart);
//     range.select();
//   }
// }
// document.querySelector("#source").onblur = (e) => {
//   e.preventDefault()
//   selectionStart = e.currentTarget.selectionStart
//   selectionEnd = e.currentTarget.selectionEnd
// }

// document.querySelector("#source").onfocus = (e) => {
//   e.preventDefault()
//   console.log(selectionStart)
//   console.log(e.currentTarget.selectionStart)
//   e.currentTarget.setSelectionRange(selectionStart, selectionEnd)
//   console.log(selectionStart)
// }
