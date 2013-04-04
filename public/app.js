var shorten = function() {
  var url = document.getElementById('url').value;
  console.log('getShort ' + url);

  reqwest('/shorten', {url: url}, function (res) {
    document.getElementById('link').value = res;
  })
  return false;
}