{exec} = require 'child_process'
{inspect} = require 'util'
{log, dir} = console
path = require 'path'
fs = require 'fs'
_ = require '../node_modules/underscore'
fileExists = fs.exists || path.exists

r = 
  execute: (files, options={}, callback)->
    files = _.flatten [files]
    [callback, options] = [options, {}] unless callback?
    
    cmd = "./node_modules/.bin/coffee ./bin/ready.coffee #{files.join ' '}"
    cwd = path.resolve './'
    args = r.optionsToArgs options
    #log "CMD : #{cmd} #{args}"
    exec "#{cmd} #{args}", {cwd:cwd}, (err, stdout, stderr)->
      err = null if err is ''
      stdout = null if stdout is ''
      stderr = null if stderr is ''
      
      #log "STDOUT : #{stdout}" if stdout?
      #log "STDERR : #{stderr}"  if stderr?
      
      # Read 'test/all.js' for stdout
      fileExists 'tests/minified/all.js', (exists)->
        if exists
          fs.readFile 'tests/minified/all.js', (err, data)->
            throw err if err?
            callback null, data.toString()
        else              
          callback stderr, stdout
      
  optionsToArgs: (options)->
    # if options is a string, use it as a json config
    if typeof options is 'string'
      "-c #{options}"
    else
      args = _.map _.pairs(options), (option)->
        switch option[0]
          when 'recursive'
            if option[1] then '' else '--no-recursive'
          when 'analyze' 
            if option[1] then '' else '--no-analyze'
          when 'output'
            "--output #{option[1]}"
          when 'ignore'
            values = _.flatten [option[1]]
            "--ignore '#{values.join ' '}'"
          
          else throw "Option `#{option[0]}` not mapped"
          
      args.join ' '
      
  optionsToJson: (options, callback)->
    json = JSON.stringify(options)
    fs.writeFile 'tests/minified/readyjs.json', json, (err)->
      return callback(err) if err?
      callback()
  
module.exports = r
