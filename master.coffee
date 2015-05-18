fs = require 'fs'
_ = require 'lodash'

load = (file) ->
  JSON.parse fs.readFileSync(file, 'utf-8')

data        = _.sortBy load('data.json'), 'title'
transcripts = _.sortBy load('transcripts.json'), 'title'
vocab       = _.sortBy load('vocab.json'), 'title'
files       = _.sortBy load('files.json'), 'title'

transcripts = for t in transcripts
  pasteboard = ''
  for sentence in t.lesson
    speaker = if sentence.speaker.length >= 1 then sentence.speaker+'：' else ''
    pasteboard += "\n#{speaker}#{sentence.chinese}"
  transcript: t.lesson
  title: t.title
  pasteboard: pasteboard.trim()

combined = for i in [0...data.length]
  title: data[i].title
  level: data[i].level
  page: data[i].page
  link: 'http://popupchinese.com' + data[i].href
  audio: files[i].link
  transcript: transcripts[i].transcript
  pasteboard: transcripts[i].pasteboard
  vocab: vocab[i].lesson

fs.writeFileSync 'combined.json', JSON.stringify(combined, null, 2)
