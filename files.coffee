request = require 'request'
cheerio = require 'cheerio'
async   = require 'async'
fs      = require 'fs'

BASEURL = 'http://popupchinese.com'
DATA    = JSON.parse fs.readFileSync('data.json', 'utf-8')

getAudioFileLinks = (uri, title, level, callback) ->
  console.log '### > Searching', title
  url = BASEURL + uri
  request url, (err, res, body) ->
    unless err
      $ = cheerio.load(body)
      link = $('audio source').attr('src')
      callback null, {link, title, level}
    else
      console.log 'Request error', err
      callback err

methods = for page in DATA
  async.retry 3, getAudioFileLinks.bind(null, page.href, page.title, page.level)

async.parallelLimit methods, 8, (err, results) ->
  unless err
    fs.writeFileSync 'files.json', JSON.stringify(results, null, 2)
  else
    console.log err
