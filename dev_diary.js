let entries = ["11_06_2020.html", "17_06_2020.html"]

let section = document.getElementById('contents')

for (let entry in entries) {
  
  let doc = fetch("dev_diary/" + entries[entry]).then((value) => value.text()).then((text) => {

    let element = document.createElement("div")
    element.class = "diary_entry"
    element.innerHTML = text
    section.appendChild(element)
  })
}