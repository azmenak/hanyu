fs     = require 'fs'
_      = require 'lodash'
mkdirp = require 'mkdirp'

data = JSON.parse fs.readFileSync('combined.json', 'utf-8')

groupedByLevel = _.groupBy(data, 'level')

for level, lessons of groupedByLevel
  mkdirp.sync "./md/#{level}"
  for lesson in lessons
    md = """
      # #{lesson.title}
      **#{_.startCase(lesson.level)}** level

    """
    if lesson.transcript.length >= 1
      md += """
        ### Chinese Text
        #{lesson.pasteboard.replace '\n', '<br />'}

        ### Pinyin and Translation
        |说人|句子|
        |----|----|
      """
      for sentence in lesson.transcript
        md += "\n|#{sentence.speaker}|#{sentence.chinese}\
          <blockquote>#{sentence.pinyin}<br />\
          #{sentence.translation}</blockquote>|"
    else
      md += 'No Transcript Available'

    md += """

      ### Vocab
      |汉子|拼音|英文|词类|
      |----|----|----|----|
    """
    for word in lesson.vocab
      md += "\n|#{word.hanzi}|#{word.pinyin}|#{word.definition}|#{word.partOfSpeach}|"

    fs.writeFileSync "./md/#{level}/#{lesson.title}.md", md
