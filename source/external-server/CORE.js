/*
    Developer:      Warren Seto
    Description:    Handles requests between client uploads from the field to the
                    destination research server
*/

"use strict"

const express = require('express'),
      server = express(),
      bodyParser = require('body-parser')

server.use(bodyParser.json({limit: '5mb'}));

const io = require('http').Server(server),
      socket = require('socket.io')(io)

var socketInstance;

socket.of('/upload').on('connection', function (connectedDevice) {

    console.log('>>>>> Connected to Destinaton Research Server (' + connectedDevice.handshake.query.auth + ')')
    
    socketInstance = connectedDevice
});


/*
    Send payload -> {'name':<classifcation label>, 'data':<base64 JPEG encoding>, 'score':<probability float> }
*/
server.post('/', function(request, response)
{
    socketInstance.emit('upload_image', {
        'name': request.body.name,
        'data': request.body.image,
        'score': request.body.score
    });
    
    response.sendStatus(200)
});

io.listen(process.env.PORT || 3000);
