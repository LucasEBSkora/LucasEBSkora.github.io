let currentVersion = "0.0"

document.getElementById("pageTitle").innerHTML += currentVersion

let entries = ["what_is_betascript.html", "data_types_and_variable_declaration.html", "control_flow.html", "comments.html", "routines.html", "classes_objects_inheritance.html"]

let section = document.getElementById('contents')

for (let entry in entries) {
  
  let doc = fetch("language_tour/" + entries[entry]).then((value) => value.text()).then((text) => {

    let element = document.createElement("div")
    element.class = "documentation_part"
    element.innerHTML = text

    let version = element.firstChild.content
    element.removeChild(element.firstChild)
    if (version != currentVersion) {
      let warning = document.createElement("p")
      warning.innerHTML = "Warning! the next section of documentation wasn't updated to version " + currentVersion + 
      "!. Last update was to version " + version + ". This might mean this section is wrong, or just that the developer forgot to" +
      " change the version in the html file."

      element.firstChild.before(warning)
    }
    section.appendChild(element)
  })
}