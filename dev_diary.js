let entries = ["11_06_2020.html", "17_06_2020.html"]

let section = document.getElementById('contents')


async function initialize(entries, section) {
  for (let i = 0; i < entries.length; i++) {
    let doc = await fetch("dev_diary/" + entries[i])
    let text = await doc.text()
    
    let element = document.createElement("div")
    element.class = "diary_entry"
    element.innerHTML = text
    section.appendChild(element)

  }
}


initialize(entries, section)