#include <WiFi.h>
#include <WebServer.h>
#include <time.h>

// WiFi credentials (from your ESPHome config)
const char* ssid = "NH2";
const char* password = "seawolfpilot01";

// NTP server and time zone settings
const char* ntpServer = "pool.ntp.org";
const char* ntpServer2 = "time.nist.gov";
const char* ntpServer3 = "time.google.com";
const long gmtOffset_sec = -28800; // GMT-8 (Pacific Time) = -8 * 3600
const int daylightOffset_sec = 3600; // Daylight saving time offset (+1 hour)

WebServer server(80);
bool timeSync = false;
String lastSyncTime = "Not synchronized";

void handleRoot() {
  struct tm timeinfo;
  String html = "<!DOCTYPE html><html><head><title>ESP32 NTP Test</title>";
  html += "<meta http-equiv='refresh' content='5'></head><body>";
  html += "<h1>ESP32 NTP Time Test</h1>";
  html += "<p><strong>WiFi Status:</strong> Connected</p>";
  html += "<p><strong>IP Address:</strong> " + WiFi.localIP().toString() + "</p>";
  html += "<p><strong>NTP Servers:</strong> " + String(ntpServer) + ", " + String(ntpServer2) + ", " + String(ntpServer3) + "</p>";
  html += "<p><strong>GMT Offset:</strong> " + String(gmtOffset_sec) + " seconds</p>";
  html += "<p><strong>DST Offset:</strong> " + String(daylightOffset_sec) + " seconds</p>";
  
  if (getLocalTime(&timeinfo)) {
    char timeStr[100];
    strftime(timeStr, sizeof(timeStr), "%A, %B %d %Y %H:%M:%S", &timeinfo);
    html += "<p><strong>Time Sync Status:</strong> <span style='color:green'>SUCCESS</span></p>";
    html += "<p><strong>Current Time:</strong> " + String(timeStr) + "</p>";
    html += "<p><strong>Unix Timestamp:</strong> " + String(mktime(&timeinfo)) + "</p>";
    html += "<p><strong>Year:</strong> " + String(timeinfo.tm_year + 1900) + "</p>";
    html += "<p><strong>Month:</strong> " + String(timeinfo.tm_mon + 1) + "</p>";
    html += "<p><strong>Day:</strong> " + String(timeinfo.tm_mday) + "</p>";
    html += "<p><strong>Hour:</strong> " + String(timeinfo.tm_hour) + "</p>";
    html += "<p><strong>Minute:</strong> " + String(timeinfo.tm_min) + "</p>";
    html += "<p><strong>Second:</strong> " + String(timeinfo.tm_sec) + "</p>";
  } else {
    html += "<p><strong>Time Sync Status:</strong> <span style='color:red'>FAILED</span></p>";
    html += "<p><strong>Current Time:</strong> Unable to get time</p>";
  }
  
  html += "<p><strong>Last Sync Attempt:</strong> " + lastSyncTime + "</p>";
  html += "<br><a href='/sync'><button>Force Time Sync</button></a>";
  html += "<br><br><a href='/debug'><button>Debug Info</button></a>";
  html += "</body></html>";
  
  server.send(200, "text/html", html);
}

void handleSync() {
  Serial.println("Manual time sync requested...");
  lastSyncTime = "Sync requested at " + String(millis()) + "ms";
  
  // Reinitialize NTP
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer, ntpServer2, ntpServer3);
  
  String html = "<!DOCTYPE html><html><head><title>Time Sync</title>";
  html += "<meta http-equiv='refresh' content='3; url=/'></head><body>";
  html += "<h1>Time Sync Requested</h1>";
  html += "<p>Attempting to synchronize time with NTP servers...</p>";
  html += "<p>Redirecting to main page in 3 seconds...</p>";
  html += "</body></html>";
  
  server.send(200, "text/html", html);
}

void handleDebug() {
  String html = "<!DOCTYPE html><html><head><title>Debug Info</title></head><body>";
  html += "<h1>ESP32 Debug Information</h1>";
  html += "<p><strong>Chip Model:</strong> " + String(ESP.getChipModel()) + "</p>";
  html += "<p><strong>Chip Revision:</strong> " + String(ESP.getChipRevision()) + "</p>";
  html += "<p><strong>CPU Frequency:</strong> " + String(ESP.getCpuFreqMHz()) + " MHz</p>";
  html += "<p><strong>Free Heap:</strong> " + String(ESP.getFreeHeap()) + " bytes</p>";
  html += "<p><strong>WiFi RSSI:</strong> " + String(WiFi.RSSI()) + " dBm</p>";
  html += "<p><strong>WiFi Channel:</strong> " + String(WiFi.channel()) + "</p>";
  html += "<p><strong>MAC Address:</strong> " + WiFi.macAddress() + "</p>";
  html += "<p><strong>Uptime:</strong> " + String(millis()) + " ms</p>";
  
  // DNS test
  html += "<h2>Network Tests</h2>";
  IPAddress ip;
  if (WiFi.hostByName("pool.ntp.org", ip)) {
    html += "<p><strong>DNS Resolution (pool.ntp.org):</strong> <span style='color:green'>SUCCESS</span> - " + ip.toString() + "</p>";
  } else {
    html += "<p><strong>DNS Resolution (pool.ntp.org):</strong> <span style='color:red'>FAILED</span></p>";
  }
  
  html += "<br><a href='/'><button>Back to Main</button></a>";
  html += "</body></html>";
  
  server.send(200, "text/html", html);
}

void setup() {
  Serial.begin(115200);
  Serial.println("\n=== ESP32 NTP Test Starting ===");

  // Configure static IP
  IPAddress local_IP(192, 168, 0, 243);
  IPAddress gateway(192, 168, 0, 1);
  IPAddress subnet(255, 255, 255, 0);
  IPAddress primaryDNS(8, 8, 8, 8);   // Google DNS
  IPAddress secondaryDNS(8, 8, 4, 4); // Google DNS
  
  if (!WiFi.config(local_IP, gateway, subnet, primaryDNS, secondaryDNS)) {
    Serial.println("Static IP configuration failed!");
  }

  // Connect to Wi-Fi
  Serial.print("Connecting to WiFi: ");
  Serial.print(ssid);
  WiFi.begin(ssid, password);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi connected!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
    Serial.print("Signal Strength: ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
  } else {
    Serial.println("\nWiFi connection failed!");
    return;
  }

  // Initialize web server
  server.on("/", handleRoot);
  server.on("/sync", handleSync);
  server.on("/debug", handleDebug);
  server.begin();
  Serial.println("Web server started on port 80");
  Serial.print("Access at: http://");
  Serial.println(WiFi.localIP());

  // Initialize time synchronization with NTP
  Serial.println("Initializing NTP time synchronization...");
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer, ntpServer2, ntpServer3);
  
  Serial.println("Waiting for NTP time synchronization...");
  int syncAttempts = 0;
  while (!getLocalTime(nullptr) && syncAttempts < 10) {
    delay(1000);
    Serial.print(".");
    syncAttempts++;
  }
  
  struct tm timeinfo;
  if (getLocalTime(&timeinfo)) {
    Serial.println("\nTime synchronized successfully!");
    char timeStr[100];
    strftime(timeStr, sizeof(timeStr), "%A, %B %d %Y %H:%M:%S", &timeinfo);
    Serial.print("Current time: ");
    Serial.println(timeStr);
    timeSync = true;
    lastSyncTime = "Initial sync successful";
  } else {
    Serial.println("\nTime synchronization failed!");
    timeSync = false;
    lastSyncTime = "Initial sync failed";
  }
}

void loop() {
  server.handleClient();
  
  // Print time every 10 seconds
  static unsigned long lastPrint = 0;
  if (millis() - lastPrint > 10000) {
    lastPrint = millis();
    
    struct tm timeinfo;
    if (getLocalTime(&timeinfo)) {
      char timeStr[100];
      strftime(timeStr, sizeof(timeStr), "%Y-%m-%d %H:%M:%S", &timeinfo);
      Serial.print("Current time: ");
      Serial.println(timeStr);
    } else {
      Serial.println("Failed to obtain time");
    }
  }
  
  delay(100);
}
