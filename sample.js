this.map = function(item) {
  var text = item.text.split(" ");
  for(var i=0; i < text.length; ++i ) {
    this.emit(text[i].trim(), 1);
  }  
};

this.reduce = function(key, values) {
  return {"key": key, "count": values.length};
};



this.map = function(item) {
  if (item.count > 100) {
    this.emit(item.key, item);
  }
}

this.reduce = function(key, values) {
  return values[0];
}