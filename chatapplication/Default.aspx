<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="chatapplication.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>My Chat Application</title>
    <script src="scripts/jquery-1.10.2.min.js"></script>
    <script src="scripts/jquery.signalR-2.1.2.min.js"></script>
    <script src="signalr/hubs"></script>  

</head>
<body>
     Enter Name: <input id="txtName" type="text" />
     <input id="btnSetName" type="button" value="Set Name" /> <br /><br />

    Enter Message: <input id="txtMessage" type="text"  style="width:400px;" />
    <input id="btnGiveCommand" type="button" value="Give voice Command" />
    <br /><br />

    <input id="btnSend" type="button" value="Send Message" />

    <div id="divName" style="display:block;margin: 5px auto;font-size:20px;width:200px;text-align-center;"></div>
    <div id="divMessages" style="display:block;width:500px;margin: 0 auto;border:1px solid black;height:1000px;"></div>

    <script>
        $(function () {
            let txtName = document.querySelector("#txtName");
            let txtMessage = document.querySelector("#txtMessage");
            let btnSetName = document.querySelector("#btnSetName");
            let btnSend = document.querySelector("#btnSend");
            let divName = document.querySelector("#divName");
            let divMessages = document.querySelector("#divMessages");

            let chat = $.connection.myHub1;

            btnSetName.onclick = function () {
                divName.innerText = ` Name: ${txtName.value}`;
            }

            chat.client.sendMessage = function (name, message) {
                $(divMessages).append($(`<div style='border:1px solid black;padding:5px;'><b>${name}: </b> ${message}</div>`))
            }

            $.connection.hub.start().done(function () {

                btnSend.onclick = function () {
                    chat.server.send(`${txtName.value}`, `${txtMessage.value}`);
                };
            });



            if (!('webkitSpeechRecognition' in window)) {
                upgrade();
            } else {

                var webkitSpeechRecognition = window.webkitSpeechRecognition;
                var webkitSpeechGrammarList = window.webkitSpeechGrammarList;

                var grammar = '#JSGF V1.0;'

                var recognition = new webkitSpeechRecognition();
                var webkitSpeechGrammarList = new webkitSpeechGrammarList();


               // var recognition = new webkitSpeechRecognition();
                recognition.continuous = true;
            //    recognition.interimResults = true;




                webkitSpeechGrammarList.addFromString(grammar, 1);
                recognition.grammars = webkitSpeechGrammarList;
                recognition.lang = 'en-US';
                recognition.interimResults = true;

                recognition.onresult = function (event) {
                    let command = event.results[0][0].transcript;
                    let isfinal = event.results[0].isFinal;
                    txtMessage.value = command;
                    if (isfinal) {
                        chat.server.send(txtName.value, command);
                    }
                }

                document.querySelector('#btnGiveCommand').onclick = function () {
                    recognition.start();
                };

                recognition.onspeechend = function () {
                    recognition.stop();
                };

                recognition.onerror = function (event) {
                    txtMessage.value = 'Error occured in recognition: ' + event.error;
                };

                }

        })
    </script>

</body>
</html>
