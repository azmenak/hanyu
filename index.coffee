request = require 'request'
cheerio = require 'cheerio'
async   = require 'async'
_       = require 'lodash'
fs      = require 'fs'

BASEURL = 'http://popupchinese.com/podcasts/'
LEVELS =
  'absolute-beginners': 7
  elementary: 9
  intermediate: 9
  advanced: 4

collectedData = []

getNamesAndLinks = (level, page, callback) ->
  console.log '### > Starting request for ', level, ", page #{page}"
  url = BASEURL + level + '?page=' + page
  request url, (err, res, body) ->
    unless err
      $ = cheerio.load(body)
      names = for tag in $('.archive_teaser')
        $link = $(tag).find('.archive_title a')
        href = $link.attr('href')
        title = $link.text()
        {href, title, level, page}
      callback(null, names)
    else
      console.log 'Request error', err
      callback(err)

methods = for level, pages of LEVELS
  for page in [1..pages]
    getNamesAndLinks.bind null, level, page
methods = _.flatten(methods)

async.parallel methods, (err, results) ->
  results = _.flatten(results)
  unless err
    fs.writeFileSync 'data.json', JSON.stringify(results, null, 2)
