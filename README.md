# HoneyPot 프로젝트
안녕하세요!<br/>
<br/>
본 프로젝트는 Microsoft Azure를 활용하여 VM (일명 Honey Pot)을 구축하고<br/>
<br/>
방화벽을 해제하여 침입을 유도해볼 겁니다. <br/>
<br/>
<br/>
그리고 PowerShell 스크립트를 만들 겁니다. <br/>
<br/>
스크립트는 VM에 로그인 실패하는 Event를 따로 기록하고<br/>
<br/>
해당 로그를 분석하여 IP 주소 별 Geo-location 값을 API로 받아<br/>
<br/>
지도에 Plot 하는 과정을 기술했습니다.<br/>

<br/>


## Objectives:

### 해당 프로젝트의 목표입니다.

  - Microsoft Azure에서 VM 구축하기
  - Azure - Log Analytics에 VM 연결하기
  - Azure Sentinel 설정
  - VM 방화벽 해제 (침입 유도)
  - Geo-location API 키 발급 및 적용
  - PowerShell을 활용하여 침입 (VM에 로그인 실패) 로그 캡쳐
  - 로그 내용을 기반하여 Workbook - Map에 위치 Plot

 <br/>
 
## 개요

본 프로젝트의 Logical 구성은 다음과 같습니다.
<br/>


<div align="center"> 
 
  [comment]: <> (Logical Diagram)
  <img src='https://github.com/HamsterJikJik/HoneyPot/assets/97205557/7339ad3d-d536-4552-9939-62b89a8490c2' width='500'>
  <br/>
  프로젝트의 Logical Diagram
</div>

<br/>

위 Diagram에서 보시다시피 Azure 환경 내에서 프로젝트를 진행할 예정입니다.<br/>
<br/>
VM의 방화벽을 해제하여 전세계의 공격자들에게 VM을 노출시키고<br/>
<br/>
인위적으로 RDP Brute Force 공격을 허용할 계획입니다.<br/>
<br/>
<br/>
그리고 Azure의 Log Analytics Workspace와 Sentinel 기능들을 활용하여<br/>
<br/>
로그온 실패 Event Log들을 수집하고,<br/>
<br/>
최종적으로 공격자의 IP의 위도와 경도를 지도에 자동 Plot 하는 것으로<br/>
<br/>
프로젝트 목표를 설정했습니다.<br/>

<br/>

## 상세과정

본 프로젝트의 주요 과정은 <br/>
<br/>
크게 3가지로 구분 지을 수 있습니다.<br/>
1. VM 구축
2. 로그를 자동으로 수집할 PowerShell 스크립트 생성
3. 수집된 로그를 기반으로 지도에 Plot

<br/>
프로젝트는 약 4일 정도 소요됐습니다. <br/>
<br/>
프로젝트를 진행하며 맞딱드렸던 문제와 그 문제를 해결했던 과정을 기술해보겠습니다. <br/>

<br/>
<br/>
<br/>

### VM 구축

VM 구축은 어렵지 않았습니다. <br/>
<br/>
학교 계정으로 Azure에 가입 후 기본으로 제공되는 크레딧을 활용하여 <br/>
<br/>
Windows 기반의 VM을 성공적으로 구축할 수 있었습니다.<br/>
<br/>
<div align="center"> 
 
  [comment]: <> (VM Overview)
  <img src='https://github.com/HamsterJikJik/HoneyPot/assets/97205557/04531e7c-c3ed-4114-8712-e996f4993a9e' width='700'>
  <br/>
  VM 구축

</div>

물론 마음 같아서는 넉넉한 코어와 RAM을 할당해주고 싶었지만<br/>
<br/>
그럴 경우, 월별 결제되는 금액이 어마무시하길래<br/>
<br/>
약간의 타협이 필수적이었습니다 :( 

<br/>
<br/>
<br/>

### 로그를 자동으로 수집할 PowerShell 스크립트 생성

첫 번째 난관이었습니다.<br/>
<br/>
학교 과제로 몇 번의 PowerShell 스크립트를 짜본 경험이 있었지만,<br/>
<br/>
스스로 진행하는 프로젝트를 위해 다시 많은 것을 공부해야 했습니다.<br/>
<br/>
<br/>
익명의 공격자로부터 침입을 탐지 및 로그화 해주는 기능은 <br/>
<br/>
이미 Windows에서 기본적으로 제공하는 기능입니다.<br/>
<br/>
Windows의 Event Viewer 탭을 활용하면 <br/>

<div align="center"> 
 
  [comment]: <> (Event Viewer)
  <img src='https://github.com/HamsterJikJik/HoneyPot/assets/97205557/46a2397d-89e2-4096-b7b0-9b477e646df6' width='600'>
  <br/>
  Windows의 Event Viewer

</div>

이렇게 제 VM에 원격 로그온 (RDP: Remote Desktop Protocol) 실패 로그들을 확인할 수 있습니다. <br/>
<br/>
Failed RDP의 Event ID는 4625 입니다. <br/>
<br/>
따라서, 4625의 Event ID를 가진 로그들을 몽땅 수집하여 하나의 파일에 기록하는 스크립트를 생성했습니다. <br/>
<br/>
여기저기 구글링하고 레딧 찾아보고 ChatGPT에게 약간의 도움을 받은 결과,<br/>
<br/>
하루 정도 걸린 끝에 스크립트를 생성할 수 있었습니다.<br/>
<br/>
또한 [IPGeolocation](https://ipgeolocation.io/) 에서 API 키를 발급 받아 스크립트에 적용해주었습니다.<br/>
<br/>
무료 버전이라 하루 1,000번의 GET Request만 가능하다는 점이 아쉬웠지만<br/>
<br/>
이게 어딥니까. 공짠데 때땡큐지 ㅋㅋㅋㅋ<br/>
<br/>
<br/>
<a href="https://github.com/HamsterJikJik/HoneyPot/blob/main/Custom_Log_Exporter.ps1">스크립트</a>는 이 곳에서 직접 확인하실 수 있습니다.<br/>
<br/>
만약 직접 따라 하신다면 자유롭게 수정 및 배포하셔도 됩니다!<br/>
<br/>
<br/>
<br/>
<br/>
그리고 스크립트를 실행해줬습니다.<br/>
<br/>
방화벽을 해제한 후 스크립트를 실행하자 얼마 지나지 않아<br/>
<br/>
전세계 공격자들로 부터 무수히 많은 악수 요청이 끊이질 않습니다.<br/>
<br/>

<div align="center"> 
 
  [comment]: <> (Detected Attacks)
  <img src='https://github.com/HamsterJikJik/HoneyPot/assets/97205557/69ea3f6e-1648-45b7-ad87-88a3d0d3243b' width='600'>
  <br/>
  보라색 로그 한 줄 한 줄이 전부 시도된 Brute Forcing Attack 입니다.

</div>

<br/>
고얀놈들...<br/>
<br/>

### 수집된 로그를 기반으로 지도에 Plot

여기가 진짜 헬이었습니다...<br/>
<br/>
<br/>
우선 Log Analytics Workspace에서 새로운 테이블(로그)을 생성하여 Azure가 제 VM의 로그를 수집 및 확인할 수 있게 해주었습니다.<br/>
<br/>
테이블을 VM에 연결해주고 경로를 설정해주면 Azure에서 자동으로 로그 파일을 읽을 수 있는 상태가 됩니다.<br/>

<div align="center"> 
 
  [comment]: <> (New Log Table)
  <img src='https://github.com/HamsterJikJik/HoneyPot/assets/97205557/f32a0229-bb7a-4f20-b66d-6b7c3e897a8f' width='600'>
  <br/>
  생성된 새로운 로그 테이블

</div>

<br/>
생성된 로그 테이블을 출력해봅시다.<br/>
<br/>
<div align="center"> 
 
  [comment]: <> (Log Queries)
  <img src='https://github.com/HamsterJikJik/HoneyPot/assets/97205557/ec7bcc78-2a61-4f58-8a83-22c65e60d19e' width='600'>
  <br/>
  이제 Azure가 RDP 실패 로그를 읽을 수 있게 되었습니다!

</div>

<br/>
눈여겨 볼 부분은 Raw Data 부분입니다. <br/>
<br/>
여기 보이는 이 RawData 값들을 일일히 뜯어 하나씩 Column을 만들어주려 했으나<br/>
<br/>
Custom Fields를 만드는 방법에 관한 마소 공식 매뉴얼을 아무리 잘 읽어봐도<br/>
<br/>
그 방법대로 하는 것에 실패했습니다 ㅠㅠ<br/>
<br/>
<br/>
그리고...<br/>
<br/>

마소 이 양반들이 공식 매뉴얼을 최신화 해주지 않았다는 사실을 깨우치는데만 꼬박 몇 시간이 걸렸습니다...<br/>
<br/>
매뉴얼에는 분명 출력된 로그를 우클릭하면 Custom Fields로 Extract가 가능하다고 나와있었지만,<br/>
<br/>
저는 아무리 우클릭해도 Extract는 커녕 창 하나 뜨지 않아서 처음엔 제 문제인가 싶어<br/>
<br/>
Azure에서 온갖 탭을 뒤져보며 로그의 특정 Field를 Extract 해보려고 생고생을 했습니다 ㅋㅋㅋㅋ<br/>
<br/>
<br/>
하지만 레딧의 한 포스트에서 영웅을 만났습니다.<br/>
<br/>
마소에서 몇 번의 업데이트를 거치면서 로그를 우클릭할 수 있는 기능을 없애고<br/>
<br/>
쿼리문을 직접 기입하여 커스텀 필드를 생성하는 방식으로 바꿨다고 하더라고요?<br/>
<br/>
현 시간부로 애플 >>넘사>> 마소임<br/>
<br/>
아무튼 그럼 ㅇㅇ<br/>
<br/>
<br/>
하여튼 그래서 쿼리문에 extend문을 추가하여 직접 커스텀 필드를 만들어주기 시작했습니다.<br/>
<br/>

제가 사용했던 <a href="https://github.com/HamsterJikJik/HoneyPot/blob/main/Azure_Workbook_Query">쿼리문</a>은:
<br/>

~~~
  FAILED_RDP_WITH_GEO_CL 
  | extend username = extract(@"username:([^,]+)", 1, RawData),
           timestamp = extract(@"timestamp:([^,]+)", 1, RawData),
           latitude = extract(@"latitude:([^,]+)", 1, RawData),
           longitude = extract(@"longitude:([^,]+)", 1, RawData),
           sourcehost = extract(@"sourcehost:([^,]+)", 1, RawData),
           state = extract(@"state:([^,]+)", 1, RawData),
           label = extract(@"label:([^,]+)", 1, RawData),
           destination = extract(@"destinationhost:([^,]+)", 1, RawData),
           country = extract(@"country:([^,]+)", 1, RawData)
  | where destination != "samplehost"
  | where sourcehost != ""
  | summarize event_count=count() by latitude, longitude, sourcehost, label, destination, country
~~~

<br/>
이거 였습니다.<br/>
<br/>
각 로그의 Raw Data를 콤마로 구분지어 놨기 때문에<br/>
<br/>
필드 별로 뜯어서 새로은 필드를 구성해주었습니다.<br/>
<br/>
<br/>
여기서 주로 사용하게 될 필드는:<br/>
<br/>

1. Label
2. Country
3. SourceHost
4. Longitude
5. Latitude

다섯 가지 정도입니다. <br/>
<br/>
<br/>
Label 필드는 Plot 되는 결괏값을 디스플레이 해주기 위한 각 항목별 타이틀입니다.<br/>
<br/>
Azure Workbook에서 Label 필드를 구체적으로 설정해주면 자동으로 인식하고 결괏값을 표시할 수 있게 했습니다.<br/>
<br/>
<br/>
Country 필드는 말 그대로 국가입니다.<br/>
<br/>
SourceHost 필드의 값(IP 주소)을 Geolocation API를 통해 그 위치를 국가로 특정지을 수 있는데,<br/>
<br/>
어느 나라에서 공격이 시도되는지 확인하기 위해서 필수적인 필드입니다.<br/>
<br/>
<br/>
마지막으로 Longitude와 Latitude는 경도와 위도입니다.<br/>
<br/>
국가가 특정된다 한들,<br/>
<br/>
지도상 크기가 큰 나라들(러시아, 중국, 인도)로부터 오는 공격자들의 정확한 위치값을<br/>
<br/>
지도에 Plot 해주기 위해 Geolocation API를 활용하여 위도와 경도를<br/>
<br/>
추출할 수 있게 해주었습니다.<br/>
<br/>
<br/>

## 공격 위치를 지도에 Plot 해주기

<br/>
성공적으로 RDP 실패 로그를 수집하고 내용을 추출하는 과정까지 왔습니다.<br/>
<br/>
이제 그 로그로부터 얻은 다양한 값들을 활용해 지도에 공격자의 위치를 찍어주는 일만 남았네요.<br/>
<br/>

<div align="center"> 
 
  [comment]: <> (Creating a Workbook)
  <img src='https://github.com/HamsterJikJik/HoneyPot/assets/97205557/6e82822a-4792-4c63-9ac3-60bb4d17abff' width='600'>
  <br/>
  Azure Sentinel에서 새로운 Workbook을 생성했습니다.

</div>

<br/>
이제 이 Workbook을 적절히 Configure 해주면 공격자의 위치가 지도 상에 표시될 겁니다.<br/>
<br/>
우선 아까 완성한 쿼리문을 Workbook에 입력했습니다.<br/>
<br/>

<div align="center"> 
 
  [comment]: <> (Entering the Query to the Workbook)
  <img src='https://github.com/HamsterJikJik/HoneyPot/assets/97205557/db4e9158-9c3a-4f6b-91f2-21865308f390' width='600'>
  <br/>
  생성된 Workbook에 쿼리문을 입력.

</div>

<br/>
그 후, Map Setting 버튼을 눌러 쿼리문으로부터 추출된 값을 지도에 Plot할 수 있게 지도 설정을 해줍니다.<br/>
<br/>

<div align="center"> 
 
  [comment]: <> (Map Setting 1)
  <img src='https://github.com/HamsterJikJik/HoneyPot/assets/97205557/5a74e0f9-3a38-4dcf-9f64-2f394cfc34b0' width='400'>
  <br/>
  로그의 위도와 경도, 그리고 빈도수를 기반하여 Plot할 수 있게 설정.

</div>

<br/>
먼저 기본적인 위도와 경도 기반의 값을 기입해주고,<br/>
<br/>
<br/>

<div align="center"> 
 
  [comment]: <> (Map Setting 2)
  <img src='https://github.com/HamsterJikJik/HoneyPot/assets/97205557/0d52c604-310a-4a02-baff-c1b95da7b5d0' width='400'>
  <br/>
  빈도수가 많을 수록 빨갛게 보일 수 있게, 그리고 지도 하단에 그 수를 표시할 수 있게 설정.

</div>

<br/>
이렇게 설정한 후, 저장해주었습니다.<br/>
<br/>
또한, 지도가 5분마다 업데이트 될 수 있도록 Auto Refresh를 5분으로 설정했습니다.<br/>
<br/>
이렇게 되면 제가 일일히 새로고침하지 않아도 5분마다 지도가 최신 결과를 보여주겠죠.<br/>
<br/>
<br/>
<br/>

## 최종 결과

자 이제 스크립트를 켜둔 채로 여유있게 기다리면서 어느 나라가 제일 못된 나라인지 확인하면 됩니다.<br/>
<br/>
스크립트를 약 15분 정도 돌려본 결과,<br/>
<br/>
<br/>

<div align="center"> 
 
  [comment]: <> (Final Result)
  <img src='https://github.com/HamsterJikJik/HoneyPot/assets/97205557/ba2c7124-4690-4c88-9998-e2e4ef50fd58' width='600'>
  <br/>
  잡았다 요놈들!

</div>

지도에 잘 반영이 되는 모습을 확인할 수 있었습니다.<br/>
<br/>
<br/>
<br/>
보아하니 아랍 에미리트, 프랑스, 인도 순으로 공격이 많이 들어오네요.<br/>
<br/>
물론 Source IP는 프록시나 VPN 등을 사용하여 변조됐을 가능성이 크지만,<br/>
<br/>
이렇게 공격들이 주로 어느 나라에서 오는지 확인하는 것은 참 신기합니다.<br/>
<br/>
한국에서도 공격이 들어오나 좀 더 지켜봤지만,<br/>
<br/>
단 한 건도 없었습니다 ㅋㅋㅋ<br/>
<br/>
펄-럭<br/>
<br/>
<br/>
궁금해서 약 1시간 정도 더 기다려봤습니다.<br/>
<br/>
TO BE UPDATED
<br/>
<br/>

## 결과 분석 및 개선점

계획했던 프로젝트를 마무리하며 느낀 점은<br/>
<br/>
TO BE UPDATED<br/>
<br/>
<br/>
<br/>
또한 개선점이 막 떠올랐습니다.<br/>
<br/>
현재 지도에서 보이는 통계는 IP를 기준으로 나라를 식별합니다.<br/>
<br/>
때문에 스크린샷에서 보시다시피 같은 캄보디아로부터 들어온 공격이라 해도<br/>
<br/>
IP 주소가 다르면 다른 나라처럼 통계가 표시되는 것이 아쉽더라구요.<br/>
<br/>
추후에 시간이 나면 IP 주소가 다르더라도 같은 나라로부터 오는 공격이라면<br/>
<br/>
하나로 합쳐서 IP 주소를 하나씩 띄워줄 수 있게 업데이트를 해보고 싶습니다.<br/>
<br/>
또한, 스크립트를 조금 더 다듬어서 특정 IP 주소로 오는 공격이라던지,<br/>
<br/>
특정 나라에서 오는 공격들만 그 로그를 수집할 수 있게 변형하는 것도 재미있을 것 같습니다.<br/>
<br/>
사실 한국으로부터 오는 공격이 있나 참 보고 싶었는데 아쉽게도 오지 않더라고요... ㅠ<br/>
<br/>
<br/>
<br/>
이상입니다.<br/>
<br/>
긴 리포트 읽어주셔서 감사합니다.<br/>

