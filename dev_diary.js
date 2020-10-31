const entries = [
  "2020_06_11.html",
  "2020_06_17.html",
  "2020_06_19.html",
  "2020_06_20.html",
  "2020_06_27.html",
  "2020_06_29.html",
  "2020_06_30.html",
  "2020_07_04.html",
  "2020_07_15.html",
  "2020_08_21.html",
  "2020_08_29.html",
  "2020_10_29.html",
  "2020_10_31.html",
]

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