{exec} = require 'child_process'

task 'deploy_staging', 'deploy to aneeshb.com', ->
    exec 'scp -r _site/* aneeshbc@50.22.11.7:~/www/portfolio_staging', (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr

task 'deploy_staging', 'deploy to aneeshb.com', ->
    exec 'scp -r _site/* aneeshbc@50.22.11.7:~/www', (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
