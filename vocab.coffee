request = require 'request'
cheerio = require 'cheerio'
async   = require 'async'
fs      = require 'fs'

BASEURL = 'http://popupchinese.com'
DATA    = JSON.parse fs.readFileSync('data.json', 'utf-8')

try
  vocab = JSON.parse fs.readFileSync('vocab.json', 'utf-8')
catch e
  vocab = []
completedVocab = (c.title for c in vocab)

getVocab = (uri, title, level, callback) ->
  if title in completedVocab
    console.log '[Skipping]'
    callback null, title
  else
    console.log '### > Extracting', title
    url = BASEURL + uri + '?stage=vocab'
    request url, (err, res, body) ->
      unless err
        $ = cheerio.load(body)
        lesson = for word in $('tr.lesson_word_row')
          $word = $(word)
          hanzi = $word.find('.lesson_word_field1').text().trim()
          pinyin = $word.find('.lesson_word_field3').text().trim()
          definition = $word.find('.lesson_word_field4').text().trim()
          partOfSpeach = $word.find('.lesson_word_field5').text().trim()

          {hanzi, pinyin, definition, partOfSpeach}
        tr = {lesson, title, level}
        vocab.push tr
        fs.writeFileSync 'vocab.json', JSON.stringify(vocab, null, 2)
        callback null, {lesson, title, level}
      else
        console.log 'Request error', err
        callback err

methods = for page in DATA
  async.retry 3, getVocab.bind(null, page.href, page.title, page.level)

async.parallelLimit methods, 4, (err, results) ->
  if err
    console.log err
