#!/usr/bin/env node
const target = process.argv[2]
const { exception } = require('console')
const fs = require('fs')
const replaceString = require('replace-string')
let firmwareFolder
let rawdata
console.log('*** Running config replacer ***')
console.log('===> Target ', target)
switch (target){
    case 'board':
        firmwareFolder = '../Firmware/Board/Marlin/Marlin_2.0.x-bugfix/Marlin/'
        rawdata = fs.readFileSync('./changes_marlin.json')
        break;
    case 'display':
        firmwareFolder = '../Firmware/Display/BIGTREETECH/TouchScreenFirmware/TFT/src/User/'
        rawdata = fs.readFileSync('./changes_btt_display.json')
        break;
    default:
        throw new exception('Unsupported target')
}
const replacements = JSON.parse( rawdata )
replacements.files.forEach(function( filereplacements ) {
    console.log('Replaceing in ' + filereplacements.filename )
    console.log('Key follower is ' + filereplacements.keyfollowup )
    let configFile = fs.readFileSync( firmwareFolder + filereplacements.filename, 'utf8' )
    let moddedConfigFile = configFile
    let keyFollowUp = filereplacements.keyfollowup
    let changeMarker = filereplacements.marker
    filereplacements.changes.forEach( function( linereplaces ) {
        configFile = moddedConfigFile
        moddedConfigFile = replaceString( configFile, linereplaces.search.trim() + keyFollowUp , linereplaces.replace + ' ' + changeMarker )
    })
    fs.writeFile( firmwareFolder + filereplacements.filename, moddedConfigFile, err => {
        if (err) {
            console.error(err)
            return
        }
        })
})
console.log('*** Config replacer Done ***')
