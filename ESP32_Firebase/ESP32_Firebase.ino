#include <WiFi.h>
#include <Firebase_ESP_Client.h>

/* 1. Define the WiFi credentials */
#define WIFI_SSID "LBueno"
#define WIFI_PASSWORD "Bueno302"

/* 2. Define the API Key */
#define API_KEY "AIzaSyAsOIsupK_QGLmMCUQVKF9JQ-qiFpYneK4"

/* 3. Define the RTDB URL */
#define DATABASE_URL "https://pontoponto-79f6e-default-rtdb.firebaseio.com/"

/* 4. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL "1@gmail.com"
#define USER_PASSWORD "123456"

// Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

unsigned long lastFirebaseUpdate = 0;
unsigned long firebaseUpdateInterval = 1000; // Atualizar a cada 30 segundos
String currentAccessCode = ""; // Código atual recebido do Firebase

void setup(){
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED){
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  // Enable network reconnection
  Firebase.reconnectNetwork(true);

  fbdo.setBSSLBufferSize(4096, 1024); // Configura o buffer SSL
  fbdo.setResponseSize(2048); // Limita o tamanho da resposta

  Firebase.begin(&config, &auth);

  config.timeout.serverResponse = 10 * 1000;
}

void loop()
{
  // Atualiza o código de acesso do Firebase a cada 30 segundos
  if (Firebase.ready() && (millis() - lastFirebaseUpdate > firebaseUpdateInterval)){
    lastFirebaseUpdate = millis();

    if (Firebase.RTDB.getString(&fbdo, "/accessCodes/currentCode/code")){
      currentAccessCode = fbdo.stringData();
      //Serial.println("Código de acesso atualizado do Firebase: " + currentAccessCode);
    }
    else{
      Serial.println("Erro ao acessar o Firebase: " + fbdo.errorReason());
    }
  }

  // Verifica entrada no monitor serial
  if (Serial.available() > 0){
    String userInput = Serial.readStringUntil('\n'); // Lê a entrada até o caractere de nova linha

    Serial.println("Código inserido pelo usuário: " + userInput);

    if (userInput == currentAccessCode){
      Serial.println("Código correto! Acesso autorizado.");
    }
    else{
      Serial.println("Código incorreto! Tente novamente.");
    }
  }
}