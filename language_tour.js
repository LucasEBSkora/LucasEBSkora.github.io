const currentVersion = "0.0"

document.getElementById("pageTitle").innerHTML += currentVersion

const entries = ["what_is_betascript.html", "data_types_and_variable_declaration.html", "control_flow.html", "comments.html", "routines.html", "classes_objects_inheritance.html"]

const section = document.getElementById('contents')


async function initialize(entries, section) {
  
  for (let i = 0; i < entries.length; i++) {
    
    const doc = await fetch("language_tour/" + entries[i])
    const text = await doc.text()

    const element = document.createElement("div")
    element.class = "documentation_part"
    element.innerHTML = text

    const version = element.firstChild.content
    element.removeChild(element.firstChild)
    if (version != currentVersion) {
      const warning = document.createElement("p")
      warning.innerHTML = "Warning! the next section of documentation wasn't updated to version " + currentVersion + 
      "!. Last update was to version " + version + ". This might mean this section is wrong, or just that the developer forgot to" +
      " change the version in the html file."

      element.firstChild.before(warning)
    }

    section.appendChild(element)

  }

}

initialize(entries, section)