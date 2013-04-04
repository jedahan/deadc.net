DeadC.net lets you create one-click expiring links.

in `node_modules/short/models/shortURL.js`:
  s/findOne/findOneAndRemove
  s/updateHitsById(URL, options, callback)/callback(null, URL)
