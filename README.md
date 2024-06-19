# iosProject - FreshNyam

### 프레시냠

냉장고 정리 어플

### 주요 기능

1. **식품 추가 및 관리**
    - 식품명을 입력하고, 카테고리와 보관 장소를 선택할 수 있습니다.
    - 아이템의 이미지를 선택할 수 있습니다.
    - 소비기한을 설정할 수 있습니다.
    - 아이템이 추가되면 자동으로 1일 전 알림이 예약됩니다.

2. **카테고리 관리**
    - 기본 제공되는 카테고리 외에 새로운 카테고리를 추가할 수 있습니다.
    - 카테고리를 삭제하거나 이름을 변경할 수 있습니다.

3. **아이템 정렬 및 검색**
    - 이름, 소비기한, 카테고리 순으로 정렬할 수 있습니다.
    - 검색 기능을 통해 아이템을 검색할 수 있습니다.

4. **알림 기능**
    - 아이템의 소비기한 1일 전에 알림을 받습니다.
    - 아이템을 삭제하면 해당 아이템에 대한 알림도 함께 제거됩니다.

5. **데이터 내보내기 및 가져오기**
    - 앱의 데이터를 JSON 파일로 내보내고 가져올 수 있습니다.
  
#### 메인 화면

- **아이템 확인 기능**
    - 그리드뷰: 아이콘, 아이템 이름, 디데이 확인 가능
    - 리스트뷰:  아이콘, 아이템 이름, 디데이 및 등록일과 만료일 확인 가능
    - 보관 장소: 냉장실, 냉동실, 실온보관
 
<div style="display: flex; flex-wrap: wrap;">
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/ccdbc96c-9737-4a13-af9c-e71bccad97cf" width="250" />
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/f592b254-b589-403c-b694-cf0a41de79df" width="250" />
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/ba879ccc-875a-47e1-a5c8-c1d2a8333444" width="250" />
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/9d260898-d201-4333-9cee-4665f7d5499b" width="250" />
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/ef206f60-af7c-4a9b-81d2-d6df3ba32841" width="250" />
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/74a1f321-ac6b-4860-9c25-8a27342ee17e" width="250" />
   
</div>


- **아이템 수정 및 삭제 기능**
    - 식품명, 카테고리, 아이콘 선택, 보관 장소, 소비기한, 등록날짜 수정 가능
 
- **정렬 기능**
    - 이름순, 디데이순으로 정렬 가능
 
<div style="display: flex; flex-wrap: wrap;">
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/39e51943-fb43-46fc-b1d8-0fa0f22fe91e" width="250"/>
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/fcb4017c-0088-4acc-8884-a3a1716023e8" width="250"/>
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/61d16e6b-02df-4ab7-bcbf-cf7ce4f06a38" width="250"/>
</div>


- **네비게이션 바**
    - 왼쪽 상단: 검색, 그리드뷰/리스트뷰 보기, 공유하기, 불러오기 기능 사용 가능
    - 오른쪽 상단: 추가 버튼을 통해 아이템 추가 가능
- **설정**
    - 카테고리 편집 가능
    - 라이트/다크 모드 변경 가능

<div style="display: flex; flex-wrap: wrap;">
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/50609b02-aec3-4462-9438-fd346124b647" width="250" />
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/fdb8ad78-5dbc-4f0d-88b7-ef0933adf8da" width="250" />
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/be94db79-a70d-47e0-bd62-7837a59ee038" width="250" />
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/acb34494-30f1-433d-8f7f-537445f03cea" width="250" />
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/2eb4b980-10c8-40a4-bd96-0d9ec97b1a4a" width="250" />
</div>
     


#### 아이템 추가 화면

- **아이템 추가 기능**
    - 식품명, 카테고리, 아이콘 선택, 보관 장소, 소비기한을 선택 후 추가 가능
- **아이콘 선택 기능**
    - 다양한 아이콘 선택 및 검색 가능
      
<div style="display: flex; flex-wrap: wrap;">
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/e222a65b-710f-494a-ab75-723f66dda595" width="250" />
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/4a86b99e-a1e1-47e9-b5f8-dc3a432b60c6" width="250" />
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/8c7026df-c1cc-4683-8438-92e8f7810ad5" width="250" />
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/bea9afb7-1726-4f50-8479-1d8cc8f257a8" width="250" />
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/988db0ab-eeec-4125-baa8-a14b031398c1" width="250" />
    <img src="https://github.com/yeonjae1/iosProject-FreshNyam/assets/100851180/aa1d1e0e-201f-4535-a17d-d442f322615f" width="250" />
</div>
