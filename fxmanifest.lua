fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'A versatile standalone countdown timer with a modern UI for RedM'
author 'Blaze Scripts'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
    'html/images/*.svg',
    'html/fonts/*',
    'html/sounds/*.mp3'
}

ui_page 'html/index.html'

exports {
    'startTimer',
    'stopTimer',
    'isTimerRunning'
}
