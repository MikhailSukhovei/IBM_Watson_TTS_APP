library(shiny)
library(magrittr)
library(curl)
library(jsonlite)
library(splitstackshape)


text_audio <- function(
    text,
    userpwd,
    keep_data = "true",
    directory,
    voice = "en-US_AllisonVoice",
    accept = "audio/ogg;codecs=opus"
) {
    instance <- TEXT_TO_SPEECH_URL
    service <- "/v1/synthesize?"
    parameters <- paste("voice", voice, sep = "=", collapse = "&")
    url <- paste0(instance, service, parameters)
    
    format <- substr(accept, 7, 9)
    invisible(lapply(
        seq_along(text),
        function(index) {
            file_name <- paste0(index, ".", format)
            path <- file.path(directory, file_name)
            postfields <- toJSON(list(text = text[index]), auto_unbox = TRUE)
            handle <- new_handle(url = url) %>%
                handle_setopt(
                    "userpwd" = userpwd,
                    "postfields" = postfields,
                    "failonerror" = 0
                ) %>%
                handle_setheaders(
                    "X-Watson-Learning-Opt-Out"= keep_data,
                    "Content-Type" = "application/json",
                    "Accept" = accept
                )
            curl_download(url, path, handle = handle)
        }
    ))
    invisible(TRUE)
}


listvoices <- function() {
    url.voice <- "v1/voices"
    voices <- httr::GET(
        url = paste(TEXT_TO_SPEECH_URL, url.voice, sep = "/"),
        httr::authenticate("apikey", TEXT_TO_SPEECH_APIKEY)
    )
    data <- httr::content(voices, "text", encoding = "UTF-8")
    data <- as.data.frame(strsplit(as.character(data), "name"))
    data <- data[-c(1:2), ] # remove dud first row
    data <- strsplit(as.character(data), ",")
    data <- data.frame(matrix(data))
    colnames(data) <- "V1"
    data <- cSplit(data, 'V1', sep="\"", type.convert = FALSE)
    data <- data.frame(data$V1_04)
    data[,1]  <- gsub("\\\\", "", data[,1])
    
    return(data)
}


get.language <- function(code) {
    strsplit(code, split = "_")[[1]][1]
}

get.voice <- function(code) {
    strsplit(code, split = "_")[[1]][2]
}


TEXT_TO_SPEECH_URL = Sys.getenv("TEXT_TO_SPEECH_URL")
TEXT_TO_SPEECH_APIKEY = Sys.getenv("TEXT_TO_SPEECH_APIKEY")
TEXT_TO_SPEECH_USERNAME_PASSWORD = paste0("apikey", ":", TEXT_TO_SPEECH_APIKEY)


shinyServer(function(input, output, session) {
    observe({
        showNotification(
            "This application uses the IBM Watson Text-to-Speech API to convert
             your text to speech in one of several languages.
             To get started, select the language and one of the available
             voices in the settings panel.
             Then enter the text in the window on the right and click the
             \"submit\" button.", duration = 60)
    })
    
    voice_codes <- listvoices()
    voice_table <- data.frame(code = unlist(voice_codes, use.names = FALSE))
    voice_table$language <- sapply(voice_table$code, get.language)
    voice_table$voice <- sapply(voice_table$code, get.voice)
    
    updateSelectInput(
        session,
        "language",
        choices = sort(unique(voice_table$language)),
        selected = 1
    )
    
    observeEvent(input$language, {
        lang <- input$language
        updateSelectInput(
            session,
            "voice",
            choices = sort(unique(
                voice_table[voice_table$language == lang, ]$voice
            )),
            selected = 1
        )
    })
    
    observeEvent(input$gobutton, {
        unlink("www/*.wav")
        lang <- input$language
        voice <- input$voice
        text <- input$caption
        text_audio(
            text,
            TEXT_TO_SPEECH_USERNAME_PASSWORD,
            directory = 'www',
            voice = voice_table[
                (voice_table$language == lang) & (voice_table$voice == voice)
            , ]$code,
            accept = "audio/wav"
        )
        file.rename("www/1.wav", paste0("www/number", input$gobutton, ".wav"))
        output$play <- renderUI(
            tags$audio(src = paste0("temp.wav"),
            type = "audio/wav",
            controls = NA
        ))
        output$play <- renderUI(tags$audio(
            src = paste0("number", input$gobutton, ".wav"),
            type = "audio/wav",
            controls = NA)
        )
    })
})
