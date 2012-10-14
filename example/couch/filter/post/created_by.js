 function(doc, req) {
  if (doc.type && doc.type == "Post") {	  
    return req.query.author == doc.author;
  } else {
    return false;
  }
}