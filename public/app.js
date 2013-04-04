function getShort() {
  console.log('getShort');
  var url = qwery('#url')[0].value;
  reqwest('/shorten', {url: url}, function (res) {
    qwery('#link')[0].value = res;
  })
  return false;
}