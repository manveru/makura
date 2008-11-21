function(doc){
  if(doc.type == 'Post' && doc.user){
    emit(doc.user, doc);
  }
}
