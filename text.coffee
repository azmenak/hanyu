fs     = require 'fs'
_      = require 'lodash'
mkdirp = require 'mkdirp'

data = JSON.parse fs.readFileSync('combined.json', 'utf-8')

groupedByLevel = _.groupBy(data, 'level')

for level, lessons of groupedByLevel
  mkdirp.sync "./txt/#{level}"
  for lesson in lessons
    txt = """
      # #{lesson.title}
      ## *#{lesson.level}* level

      ### Chinese Text
      #{lesson.pasteboard}

      ### Pinyin and Translation
    """
    for sentence in lesson.transcript
      l   = sentence.speaker.length
      pad = if l >= 1 then (l*2)+2 else 0
      txt += "\n\n#{if l >= 1 then sentence.speaker+': ' else ''}#{sentence.chinese}"
      txt += "\n#{_.repeat(' ', pad)}#{sentence.pinyin}"
      txt += "\n#{_.repeat(' ', pad)}#{sentence.translation}"

    txt += "\n### Vocab"
    for word in lesson.vocab
      txt += "\n-#{word.hanzi} (#{word.pinyin}) [#{word.partOfSpeach}] #{word.definition}"

    fs.writeFileSync "./txt/#{level}/#{lesson.title}.txt", txt
