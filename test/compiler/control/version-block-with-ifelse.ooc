version(windows) {
  if (false) {
    // something
    "a" println()
  } else {
    // something else
    "b" println()
  }
} else {
    "c" println()
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
    "c" println()
}
