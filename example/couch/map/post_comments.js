function(doc){
  if(doc.type == 'Comment'){
    emit(doc._id, doc);
  }
}
