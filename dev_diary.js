const entries = ["11_06_2020.html", "17_06_2020.html","19_06_2020.html","20_06_2020.html","27_06_2020.html", "29_06_2020.html"]

const section = document.getElementById('contents')


async function initialize(entries, section) {
  for (let i = 0; i < entries.length; i++) {
    const doc = await fetch("dev_diary/" + entries[i])
    const text = await doc.text()
    
    const element = document.createElement("div")
    element.class = "diary_entry"
    element.innerHTML = text
    section.appendChild(element)

  }
}

initialize(entries, section)