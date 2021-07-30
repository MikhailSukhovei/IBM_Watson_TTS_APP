## About

This application uses the IBM Watson Text-to-Speech API to convert your text to speech in one of several languages.
    
## How to use

To get started, select the language and one of the available voices in the settings panel.
Then enter the text in the window on the right and click the "submit" button.

## How to run

This shinyapp can be run locally or in shinyapps.io server.

To run you need:

1. Clone this repository

2. Create account on https://cloud.ibm.com

3. Configure tts instance on https://cloud.ibm.com/catalog/services/text-to-speech

4. Add your instance url and api key to .Renviron file

*On windows:*

Click on start and open powershell. Copy this code into powershell

`Add-Content c:\path-to-app-root-dir\.Renviron "TEXT_TO_SPEECH_URL=xxx"`

`Add-Content c:\path-to-app-root-dir\.Renviron "TEXT_TO_SPEECH_APIKEY=yyy"`

5. Run application locally or thought rsconnect package
