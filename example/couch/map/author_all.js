function(doc){
  if(doc.type == 'Author'){
    emit(doc._id, doc);
  }
}
