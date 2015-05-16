request = require 'request'
async   = require 'async'
fs      = require 'fs'
mkdirp  = require 'mkdirp'

LINKS = JSON.parse fs.readFileSync('files.json', 'utf-8')
try
  completed = JSON.parse fs.readFileSync('completed.json', 'utf-8')
catch e
  completed = []
mkdirp.sync 'downloads'

downloadAudioFiles = (link, title, level, callback) ->
  if title in completed
    console.log '[Skipping]', title
    callback null, title
  else
    console.log '[Downloading]', title
    request link
      .pipe fs.createWriteStream("downloads/[DL]#{title}.download")
      .on 'finish', ->
        console.log '[Finished]', title
        completed.push title
        fs.writeFileSync 'completed.json', JSON.stringify(completed, null, 2)
        fs.renameSync "downloads/[DL]#{title}.download",
          "downloads/#{level} - #{title}.mp3"
        callback null, title
      .on 'error', (err) ->
        console.log err
        callback err

methods = for link in LINKS
  async.retry 3,
    downloadAudioFiles.bind(null, link.link, link.title, link.level)

async.parallelLimit methods, 4, (err, results) ->
  if err
    console.log err
