let entries = ["11_06_2020.html"]

let section = document.getElementById('contents')

for (entry in entries) {
  let doc = fetch(entry)
  let element = Element()
  element.class = "diary_entry"
  element.innerHTML = doc
  section.appendChild(element)
}