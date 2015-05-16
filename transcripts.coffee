request = require 'request'
cheerio = require 'cheerio'
async   = require 'async'
fs      = require 'fs'

BASEURL = 'http://popupchinese.com'
DATA    = JSON.parse fs.readFileSync('data.json', 'utf-8')

try
  transcripts = JSON.parse fs.readFileSync('transcripts.json', 'utf-8')
catch e
  transcripts = []
completedTitles = (c.title for c in transcripts)

getTranscripts = (uri, title, level, callback) ->
  if title in completedTitles
    console.log '[Skipping]'
    callback null, title
  else
    console.log '### > Extracting', title
    url = BASEURL + uri + '?stage=transcript'
    request url, (err, res, body) ->
      unless err
        $ = cheerio.load(body)
        lesson = for sentence in $('tr.lesson_sentence')
          $sentence = $(sentence)
          speaker = $sentence.find('.lesson_sentence_speaker').text().trim()
          chinese = $sentence.find('.lesson_sentence_source').text().trim()
          pinyin = $sentence.find('.lesson_sentence_pinyin').text().trim()
          translation = $sentence.find('.lesson_sentence_trans').text().trim()
          {speaker, chinese, pinyin, translation}
        tr = {lesson, title, level}
        transcripts.push tr
        fs.writeFileSync 'transcripts.json', JSON.stringify(transcripts, null, 2)
        callback null, {lesson, title, level}
      else
        console.log 'Request error', err
        callback err

methods = for page in DATA
  async.retry 3, getTranscripts.bind(null, page.href, page.title, page.level)

async.parallelLimit methods, 4, (err, results) ->
  if err
    console.log err
