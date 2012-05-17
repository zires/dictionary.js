{print, log} = require 'util'
{spawn}      = require 'child_process'

task 'build', 'Build coffeescript srouce files into lib/', ->
  log '== Start building =='
  coffee = spawn 'coffee', ['-c', '-o', 'lib', 'src']
  
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()

  coffee.stdout.on 'data', (data) ->
    print data.toString()

  coffee.on 'exit', (code) ->
    callback?() if code is 0

task 'watch', 'Watch src/ for changes', ->
  log '== Start watching =='
  coffee = spawn 'coffee', ['-w', '-c', '-o', 'lib', 'src']

  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  
  coffee.stdout.on 'data', (data) ->
    print data.toString()
