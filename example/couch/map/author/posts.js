function(doc){
  if(doc.type == 'Post' && doc.author){
    emit(doc.author, doc);
  }
}
