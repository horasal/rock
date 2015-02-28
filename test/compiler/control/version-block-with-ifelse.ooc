version(windows) {
  if (false) {
    // something
    "a" println()
  } else {
    // something else
    "b" println()
  }
} else {
    if(true){
        "c" println()
    } else {
        "d" println()
    }
}

version(!windows) {
  if (false) {
    // something
    "a" println()
  } else {
    // something else
    "b" println()
  }
} else {
    if(true){
        "c" println()
    } else {
        "d" println()
    }
}
