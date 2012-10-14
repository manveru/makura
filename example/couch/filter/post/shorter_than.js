 function(doc, req) {
  if (doc.type && doc.type == "Post") {	  
    return doc.text.length < req.query.max;
  } else {
    return false;
  }
}