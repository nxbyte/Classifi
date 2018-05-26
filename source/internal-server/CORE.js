/*
    Developer:      Warren Seto
    Description:    Recieves socket payloads from external-server
                    which writes the input image into a local folder
*/

"use strict"

const SERVER_ENDPOINT_URL = ""

const fs = require('fs'),
      socket = require('socket.io-client').connect(SERVER_ENDPOINT_URL, {
          reconnect: true,
          query: 'auth=' + 'R.E.S.E.A.R.C.H'
})

socket.on('connect', function () {
    console.log('Connected!')
});


/*
    Expected payload -> {'name':<classifcation label>, 'data':<base64 JPEG encoding>, 'score':<probability float> }
*/
socket.on('upload_image', function (input) {
    const classification_label = input.name,
          base64Data = input.data.replace(/^data:([A-Za-z-+/]+);base64,/, ''),
          file_name = './' + classification_label + '/' + (new Date).getTime() + '___(' + input.score + ').jpg'
    
    if (!fs.existsSync(classification_label)) {
        fs.mkdirSync(classification_label);
    }
    
    fs.writeFile(file_name, base64Data, 'base64', (err) => {
        if (err) {
            console.log(err);
        }
        else {
            console.log('>>>>> Successfully Wrote ' + file_name)
        }
    });
});

socket.on('disconnect', function () {
    console.log('Disconnected...')
});
