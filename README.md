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
인위적으로 침투를 허용할 계획입니다.<br/>
<br/>
<br/>
그리고 Azure의 Log Analytics Workspace와 Sentinel 기능들을 활용하여<br/>
<br/>
로그온 실패 Event Log들을 수집하고,<br/>
<br/>
최종적으로 공격자의 IP의 위도와 경도를 지도에 Plot 하는 것으로<br/>
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
월별 결제되는 금액이 어마무시하길래<br/>
<br/>
약간의 타협이 필수적이었습니다. :( 

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
만약 직접 따라 하신다면 자유롭게 수정 및 배포하셔도 됩니다! <br/>
<br/>



















To be updated
