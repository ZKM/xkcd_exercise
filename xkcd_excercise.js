var txtFile = new XMLHttpRequest();
txtFile.open("GET", "menu.txt", true);
txtFile.onreadystatechange = function() {
  if (txtFile.readyState === 4) {  // Makes sure the document is ready to parse.
    if (txtFile.status === 200) {  // Makes sure it's found the file.
      allText = txtFile.responseText; 
      lines = txtFile.responseText.split("\n"); // Will separate each line into an array
    }
  }
}
txtFile.send(null);