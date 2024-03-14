# https://ipgeolocation.io/ 에서 API 키를 받아서 아래에 입력합니다.
# 큰 따옴표 안 값을 바꾸시면 됩니다.
$API_KEY      = "#####################################"
$LOGFILE_NAME = "failed_rdp.log" # 로그 파일의 이름을 지정합니다.
$LOGFILE_PATH = "C:\ProgramData\$($LOGFILE_NAME)" # 로그 파일이 저장될 경로를 지정합니다.


# Windows Event Viewer에서 RDP 이벤트를 필터링 해주는 필터
$XMLFilter = @'
<QueryList> 
   <Query Id="0" Path="Security">
         <Select Path="Security">
              *[System[(EventID='4625')]]
          </Select>
    </Query>
</QueryList> 
'@

<#
    이 함수는 Log Analytics 작업 공간에서 '추출' 기능을 훈련시키는 데 사용되는 샘플 로그 파일들을 생성합니다.
    충분한 로그 파일이 없으면, 일부 필드를 "학습"하는 데 실패할 수 있습니다.
    "samplehost"라는 목적지 호스트를 필터링함으로써 이 가짜 기록들을 지도에서 제외할 수 있습니다.
#>
Function write-Sample-Log() {
    # 샘플 로그 데이터를 로그 파일에 추가합니다. 각 줄은 다음 정보를 포함합니다:
    # 위도, 경도, 목적지 호스트, 사용자 이름, 출처 호스트, 주/도, 국가, 레이블(국가 - IP), 타임스탬프
    "latitude:47.91542,longitude:-120.60306,destinationhost:samplehost,username:fakeuser,sourcehost:24.16.97.222,state:Washington,country:United States,label:United States - 24.16.97.222,timestamp:2021-10-26 03:28:29" | Out-File $LOGFILE_PATH -Append -Encoding utf8
    "latitude:-22.90906,longitude:-47.06455,destinationhost:samplehost,username:lnwbaq,sourcehost:20.195.228.49,state:Sao Paulo,country:Brazil,label:Brazil - 20.195.228.49,timestamp:2021-10-26 05:46:20" | Out-File $LOGFILE_PATH -Append -Encoding utf8
    "latitude:52.37022,longitude:4.89517,destinationhost:samplehost,username:CSNYDER,sourcehost:89.248.165.74,state:North Holland,country:Netherlands,label:Netherlands - 89.248.165.74,timestamp:2021-10-26 06:12:56" | Out-File $LOGFILE_PATH -Append -Encoding utf8
    "latitude:40.71455,longitude:-74.00714,destinationhost:samplehost,username:ADMINISTRATOR,sourcehost:72.45.247.218,state:New York,country:United States,label:United States - 72.45.247.218,timestamp:2021-10-26 10:44:07" | Out-File $LOGFILE_PATH -Append -Encoding utf8
    "latitude:33.99762,longitude:-6.84737,destinationhost:samplehost,username:AZUREUSER,sourcehost:102.50.242.216,state:Rabat-Salé-Kénitra,country:Morocco,label:Morocco - 102.50.242.216,timestamp:2021-10-26 11:03:13" | Out-File $LOGFILE_PATH -Append -Encoding utf8
    "latitude:-5.32558,longitude:100.28595,destinationhost:samplehost,username:Test,sourcehost:42.1.62.34,state:Penang,country:Malaysia,label:Malaysia - 42.1.62.34,timestamp:2021-10-26 11:04:45" | Out-File $LOGFILE_PATH -Append -Encoding utf8
    "latitude:41.05722,longitude:28.84926,destinationhost:samplehost,username:AZUREUSER,sourcehost:176.235.196.111,state:Istanbul,country:Turkey,label:Turkey - 176.235.196.111,timestamp:2021-10-26 11:50:47" | Out-File $LOGFILE_PATH -Append -Encoding utf8
    "latitude:55.87925,longitude:37.54691,destinationhost:samplehost,username:Test,sourcehost:87.251.67.98,state:null,country:Russia,label:Russia - 87.251.67.98,timestamp:2021-10-26 12:13:45" | Out-File $LOGFILE_PATH -Append -Encoding utf8
    "latitude:52.37018,longitude:4.87324,destinationhost:samplehost,username:AZUREUSER,sourcehost:20.86.161.127,state:North Holland,country:Netherlands,label:Netherlands - 20.86.161.127,timestamp:2021-10-26 12:33:46" | Out-File $LOGFILE_PATH -Append -Encoding utf8
    "latitude:17.49163,longitude:-88.18704,destinationhost:samplehost,username:Test,sourcehost:45.227.254.8,state:null,country:Belize,label:Belize - 45.227.254.8,timestamp:2021-10-26 13:13:25" | Out-File $LOGFILE_PATH -Append -Encoding utf8
    "latitude:-55.88802,longitude:37.65136,destinationhost:samplehost,username:Test,sourcehost:94.232.47.130,state:Central Federal District,country:Russia,label:Russia - 94.232.47.130,timestamp:2021-10-26 14:25:33" | Out-File $LOGFILE_PATH -Append -Encoding utf8
}

# 로그 파일이 존재하지 않으면 새로운 로그 파일을 생성합니다.
if ((Test-Path $LOGFILE_PATH) -eq $false) {
    New-Item -ItemType File -Path $LOGFILE_PATH
    write-Sample-Log
}

# 이벤트 뷰어 로그를 지속적으로 체크하기 위한 무한 루프입니다.
while ($true)
{
    # API의 요청 한도를 초과하지 않기 위해 1초간 대기합니다.
    Start-Sleep -Seconds 1
    
    # XML 필터를 사용하여 이벤트를 추출합니다.
    $events = Get-WinEvent -FilterXml $XMLFilter -ErrorAction SilentlyContinue
    if ($Error) {
       # 로그인 실패 이벤트를 찾지 못한 경우의 처리. 스크립트를 재실행하라는 안내 메시지를 표시할 수 있습니다.
    }

   # 수집된 각 이벤트에 대해 반복 처리합니다.
   # IP 주소의 지리적 위치를 조회하고  새 이벤트를 사용자 정의 로그에 추가합니다.
    foreach ($event in $events) {
        
        # $event.properties[19]는 실패한 로그온 시도에서 출처 IP 주소.
        # IP 주소가 존재하는 경우에만 처리를 진행.
        if ($event.properties[19].Value.Length -ge 5) {

            # 이벤트에서 필요한 정보를 추출합니다. 추출된 정보는 새 사용자 정의 로그에 삽입될 예정입니다.
            # 여기에는 타임스탬프, 이벤트 ID, 목적지 호스트, 사용자 이름, 출처 호스트, 출처 IP가 포함됩니다.

            $timestamp = $event.TimeCreated
            $year = $event.TimeCreated.Year

            $month = $event.TimeCreated.Month
            if ("$($event.TimeCreated.Month)".Length -eq 1) {
                $month = "0$($event.TimeCreated.Month)"
            }

            $day = $event.TimeCreated.Day
            if ("$($event.TimeCreated.Day)".Length -eq 1) {
                $day = "0$($event.TimeCreated.Day)"
            }
            
            $hour = $event.TimeCreated.Hour
            if ("$($event.TimeCreated.Hour)".Length -eq 1) {
                $hour = "0$($event.TimeCreated.Hour)"
            }

            $minute = $event.TimeCreated.Minute
            if ("$($event.TimeCreated.Minute)".Length -eq 1) {
                $minute = "0$($event.TimeCreated.Minute)"
            }


            $second = $event.TimeCreated.Second
            if ("$($event.TimeCreated.Second)".Length -eq 1) {
                $second = "0$($event.TimeCreated.Second)"
            }

            $timestamp = "$($year)-$($month)-$($day) $($hour):$($minute):$($second)"
            $eventId = $event.Id
            $destinationHost = $event.MachineName# Workstation Name (Destination)
            $username = $event.properties[5].Value # Account Name (Attempted Logon)
            $sourceHost = $event.properties[11].Value # Workstation Name (Source)
            $sourceIp = $event.properties[19].Value # IP Address
        

            # 로그 파일의 현재 내용을 조회합니다.
            $log_contents = Get-Content -Path $LOGFILE_PATH

            # 로그가 아직 존재하지 않는 경우에만 로그 파일에 새로운 항목을 추가합니다.
            if (-Not ($log_contents -match "$($timestamp)") -or ($log_contents.Length -eq 0)) {
            
                # 지리적 위치 데이터를 수집하고, API의 요청 한도를 고려하여 잠시 대기합니다.
                Start-Sleep -Seconds 1

                # 지리적 위치 정보를 조회하기 위해 API에 요청을 보냅니다.
                # For more info: https://ipgeolocation.io/documentation/ip-geolocation-api.html
                $API_ENDPOINT = "https://api.ipgeolocation.io/ipgeo?apiKey=$($API_KEY)&ip=$($sourceIp)"
                $response = Invoke-WebRequest -UseBasicParsing -Uri $API_ENDPOINT

                # API 응답에서 필요한 데이터를 추출하여 변수에 저장합니다.
                $responseData = $response.Content | ConvertFrom-Json
                $latitude = $responseData.latitude
                $longitude = $responseData.longitude
                $state_prov = $responseData.state_prov
                if ($state_prov -eq "") { $state_prov = "null" }
                $country = $responseData.country_name
                if ($country -eq "") {$country -eq "null"}

                # 수집된 모든 데이터를 사용자 정의 로그 파일에 기록합니다.
                "latitude:$($latitude),longitude:$($longitude),destinationhost:$($destinationHost),username:$($username),sourcehost:$($sourceIp),state:$($state_prov), country:$($country),label:$($country) - $($sourceIp),timestamp:$($timestamp)" | Out-File $LOGFILE_PATH -Append -Encoding utf8

                Write-Host -BackgroundColor Black -ForegroundColor Magenta "latitude:$($latitude),longitude:$($longitude),destinationhost:$($destinationHost),username:$($username),sourcehost:$($sourceIp),state:$($state_prov),label:$($country) - $($sourceIp),timestamp:$($timestamp)"
            }
            else {
                # 이미 로그 파일에 해당 이벤트가 존재하면 아무런 작업도 수행하지 않습니다.
            }
        }
    }
}
