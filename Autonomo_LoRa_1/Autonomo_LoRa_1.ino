#include <Sodaq_RN2483.h>
#include "DHT.h"


// ----------------------------------------------------------------------
//
// Preamble
//
// ----------------------------------------------------------------------

// MBili / Tatu
//#define debugSerial Serial
// Autonomo
#define debugSerial SerialUSB
#define loraSerial Serial1

#define DHTPIN 10 // what pin we're connected to

#define DHTTYPE DHT11 // DHT 11

DHT dht(DHTPIN, DHTTYPE);

//These constants are used for reading the battery voltage
#define ADC_AREF 3.3
#define BATVOLTPIN BAT_VOLT 
#define BATVOLT_R1 4.7
#define BATVOLT_R2 10

// USE YOUR OWN KEYS!
const uint8_t devAddr[4] =
{
  0x02, 0x03, 0x05, 0x92
};

// USE YOUR OWN KEYS!
const uint8_t appSKey[16] =
{
  0x2B, 0x7E, 0x15, 0x16, 0x28, 0xAE, 0xD2, 0xA6, 0xAB, 0xF7, 0x15, 0x88, 0x09, 0xCF, 0x4F, 0x3C
};

// USE YOUR OWN KEYS!
const uint8_t nwkSKey[16] =
{
  0x2B, 0x7E, 0x15, 0x16, 0x28, 0xAE, 0xD2, 0xA6, 0xAB, 0xF7, 0x15, 0x88, 0x09, 0xCF, 0x4F, 0x3C
};

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------




// ----------------------------------------------------------------------
//
// Setup (run once on startup)
//
// ----------------------------------------------------------------------
void setup()
{
  //Set power on the LoRa BEE
  digitalWrite(BEE_VCC, HIGH);

  
  while ((!debugSerial) && (millis() < 10000)){
    //Wait for SerialUSB or 10 seconds
  };
  
  
  // init serial communication
  debugSerial.begin(57600);
  loraSerial.begin(LoRaBee.getDefaultBaudRate());
  LoRaBee.setDiag(debugSerial); // optional

  // for bright LED
  pinMode(LED_BUILTIN, OUTPUT);
  
  dht.begin();

  blinkLED(3, 200);

  delay(1000);
  setupNetwork();
};

// ----------------------------------------------------------------------
//
// Loop (runs continuously after setup)
//
// ----------------------------------------------------------------------

void loop()
{
  if (debugSerial){
    debugSerial.println();
    debugSerial.println("Gathering data...");
  };
  
  // Gather data 
  // String reading = THRead(50, 1000); // runs about 1 minute
  String reading = THRead(50, 8900); // runs for ~7.5 minutes
  reading += ", " + String(getRealBatteryVoltageMV());
  
  // Double check that lora antenna is turned on
  digitalWrite(BEE_VCC, HIGH); // because it tends to turn off if data gathering takes too long
  
  // Print Debug before sending
  if (debugSerial){
    debugSerial.println("Sending payload: Humidity, Temperature, Voltage");
    debugSerial.println(reading);    
  };

  // Send the data
	sendData(reading, 0);

   
  // Delay between readings
  // 60 000 = 1 minute
	// delay(1000); // not necessary if the data gathering takes long
	  
 };

// ----------------------------------------------------------------------
//
// Function Definitions
//
// ----------------------------------------------------------------------

String THRead(int i, int ms){
  // Reading temperature or humidity takes about 250 milliseconds!
  // initialise arrays for the mean of the temp & humidity
  float tmp[i];
  float hmd[i];
  
  // fill the arrays with readings
  int k = i;
  while (k > 0){
    tmp[k-1] = dht.readTemperature();
    hmd[k-1] = dht.readHumidity();
    blinkLED(1,100); // for debugging purposes
    delay(ms); // delay between readings
    // for debug
    // debugSerial.println(String(tmp[k-1]) +" "+ String(hmd[k-1]));
    k--;
  }

  // once the loop has run, calculate averages
  // first we need the sum
  float sumt = 0;
  float sumh = 0;
  for (int j = 0; j < i; j++ ){
    sumt += tmp[j];
    sumh += hmd[j];
  }

  
  // then we can calculate the average
  float t = sumt / i;
  float h = sumh / i;

  // then we can output it to a string
  String data = String(h)  + ", ";
  data += String(t);

  // and return the data
  return data;
};

// ----------------------------------------------------------------------

void blinkLED(int n, int ms){
  while (n > 0){
    digitalWrite(LED_BUILTIN, HIGH);
    delay(ms);
    digitalWrite(LED_BUILTIN, LOW);
    delay(ms);
    n--;
  }
};

// ----------------------------------------------------------------------

void setupNetwork(){
    if (LoRaBee.initABP(loraSerial, devAddr, appSKey, nwkSKey, false))
  {
    if (debugSerial){
      debugSerial.println("Connection to the network was successful.");
    };
    blinkLED(3, 500);
  }
  else
  {
    if (debugSerial){
      debugSerial.println("Connection to the network failed!");
    };
    blinkLED(6, 250);
  }
};

// ----------------------------------------------------------------------

float getRealBatteryVoltageMV()
{
  uint16_t batteryVoltage = analogRead(BATVOLTPIN);
  return (ADC_AREF / 1.023) * (BATVOLT_R1 + BATVOLT_R2) / BATVOLT_R2 * batteryVoltage;
};

// ----------------------------------------------------------------------

void sendData(String reading, int errors){
  switch (LoRaBee.send(1, (uint8_t*)reading.c_str(), reading.length()))
    {
    case NoError:
      if (debugSerial){
        debugSerial.println("Successful transmission.");
      };
      blinkLED(2,200);
      break;
    case NoResponse:
      if (debugSerial){
        debugSerial.println("There was no response from the device.");
      };
      break;
    case Timeout:
      errors++;
      if (debugSerial){
        debugSerial.println("Connection timed-out. Check your serial connection to the device! Retry after 20sec.");
        debugSerial.println(errors);
      };
      delay(20000);
      if (errors < 10) 
        sendData(reading, errors);
      else
        resetFunc();
      break;
    case PayloadSizeError:
      errors++;
      if (debugSerial){
        debugSerial.println("The size of the payload is greater than allowed. Transmission failed!");
        debugSerial.println(errors);
      };
      break;
    case InternalError:
      errors++;
      if (debugSerial){
        debugSerial.println("Oh No! This shouldn't happen. Something is really wrong! Try restarting the device!\r\nThe device will now restart.");
        debugSerial.println(errors);
      };
      // while (1) {}; // pause without resetting
      resetFunc();
      break;
    case Busy:
      errors++;
      if (debugSerial){
        debugSerial.println("The device is busy. Retry after 10 extra seconds.");
        debugSerial.println(errors);
      };
      delay(10000);
      if (errors < 10) 
        sendData(reading, errors);
      else 
        resetFunc();
      break;
    case NetworkFatalError:
      errors++;
      if (debugSerial){
        debugSerial.println("There is a non-recoverable error with the network connection. You should re-connect.\r\nThe program will now halt.");
        debugSerial.println(errors);
      };
      // while (1) {}; // pause without resetting
      resetFunc();
      break;
    case NotConnected:
      errors++;
      if (debugSerial){
        debugSerial.println("The device is not connected to the network. Please connect to the network before attempting to send data.\r\nThe program will now halt.");
        debugSerial.println(errors);
      };
      // while (1) {}; // pause without resetting
      resetFunc();
      break;
    case NoAcknowledgment:
      errors++;
      if (debugSerial){
        debugSerial.println("There was no acknowledgment sent back!");
        debugSerial.println(errors);
      };
      delay(10000);
      if (errors < 10) 
        sendData(reading, errors);
      else 
        resetFunc();
      break;
    default:
      break;
    };
};

// ----------------------------------------------------------------------

void resetFunc(){ // Reset the Autonomo
  debugSerial.println("Device reset initiated.");
  __DSB();
  SCB->AIRCR  = 0x05FA0004;
  __DSB();
  while(1); 
}  

// ----------------------------------------------------------------------

